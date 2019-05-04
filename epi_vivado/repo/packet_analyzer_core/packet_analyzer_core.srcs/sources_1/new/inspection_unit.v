`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Andrei Nicolae Georgian 
// 
// Create Date: 06/13/2018 09:33:40 PM
// Design Name: Ethernet Packet Inspection
// Module Name: inspection_unit
// Project Name: Ethernet packet inspection
// Target Devices: Zynq700
// Tool Versions: 
// Description: Inspects an Ethernet packet
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module inspection_unit#(
    parameter DATA_WIDTH                    = 32, // AXI data bus width
    parameter ADDR_WIDTH                    = 16, // AXI address bus width
    parameter MAX_PACKET_LENGTH             = 2048,  // Maximim packet lenght in bytes
    parameter TCQ                           = 1,
    parameter [15:0] ENGINES_NUMBER         = 16, // The number of pattern search engines
    parameter [15:0] ENGINE_MAX_SIZE        = 256   // The maximum number of bytes that the engine match string can have,
)(
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////
    //AXI Lite Slave interface 
    // System Signals
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 S_AXI_LITE_ARESETN RST" *) 
    input   wire                                     S_AXI_LITE_ARESETN,  // AXI active low reset signal
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 S_AXI_LITE_ACLK CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF S_AXI_LITE, ASSOCIATED_RESET S_AXI_LITE_ARESETN, FREQ_HZ 100000000" *)
    input   wire                                     S_AXI_LITE_ACLK,     // AXI clock signal
    
    // Slave Interface Write Address channel Ports
    input   wire    [ADDR_WIDTH - 1:0]               S_AXI_LITE_AWADDR,   // Write address (issued by master, acceped by Slave)
    input   wire                                     S_AXI_LITE_AWVALID,  // Write address valid and control information
    output  wire                                     S_AXI_LITE_AWREADY,  // Write address ready issued by slave
    
    // Slave Interface Write Data channel Ports
    input   wire    [DATA_WIDTH - 1:0]               S_AXI_LITE_WDATA,    // Write data (issued by master, acceped by Slave)
    input   wire    [DATA_WIDTH/8-1:0]               S_AXI_LITE_WSTRB,    // Write strobes - 1 bit for every 8 bits of valid data
    input   wire                                     S_AXI_LITE_WVALID,   // Write valid data and strobes
    output  wire                                     S_AXI_LITE_WREADY,   // Write ready - slave can accept write data 
    
    // Slave Interface Write Response channel Ports
    output  wire    [1:0]                            S_AXI_LITE_BRESP,    // Write response - indicates the status of write transaction
    output  wire                                     S_AXI_LITE_BVALID,   // Write response is valid
    input   wire                                     S_AXI_LITE_BREADY,   // Response ready - master can accept a write response
    
    // Slave Interface Read Address channel Ports
    input   wire    [ADDR_WIDTH - 1:0]  S_AXI_LITE_ARADDR,   // Read address (issued by master, acceped by Slave)
    input   wire                                     S_AXI_LITE_ARVALID,  // Read address valid and control information
    output  wire                                     S_AXI_LITE_ARREADY,  // Read address ready issued by slave
    
    // Slave Interface Read Data channel Ports
    output  wire    [DATA_WIDTH - 1:0]  S_AXI_LITE_RDATA,    // Read data (issued by slave)
    output  wire                                     S_AXI_LITE_RVALID,   // Read valid issued by slave - data is valid
    input   wire                                     S_AXI_LITE_RREADY,   // Read ready - master can accept the read data and response
    output  wire    [1:0]                            S_AXI_LITE_RRESP,    // Read response - indicates the status of read transfer
    /////////////////////////////////////////////////////////////////////////////////////////////////////

    
    (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 axis_aresetn RST" *)
    input   wire            axis_aresetn,                                       //% AXI active low reset signal
    (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 axis_clk CLK" *)
    (* X_INTERFACE_PARAMETER = "ASSOCIATED_BUSIF m_axis:s_axis, ASSOCIATED_RESET axis_aresetn, FREQ_HZ 100000000" *)
    input   wire            axis_clk,

    ////////////////////////////////////////////
    // Axi-Stream MASTER interface: connected to the DMA Tx channel
    output   reg [DATA_WIDTH-1:0]    m_axis_tdata = {DATA_WIDTH{1'b0}}, //% Write data      
    output   reg [3:0]               m_axis_tkeep = 4'hF,       //% Keep octets - 1 bit for every 8 bits of valid data
    output   reg                     m_axis_tlast = 1'b0,       //% Indicates the last transfer of data
    input    wire                    m_axis_tready,             //% Read ready - master can accept the read data and response
    output   reg                     m_axis_tvalid = 1'b0,      //% Read valid issued by master - data is valid

    
    ////////////////////////////////////////////
    // Axi-Stream SLAVE interface: connected to DMA Rx channel
    input  wire [DATA_WIDTH-1:0]     s_axis_tdata,      //% Write data
    input  wire [3:0]                s_axis_tkeep,      //% Keep octets - 1 bit for every 8 bits of valid data
    input  wire                      s_axis_tlast,      //% Indicates the last transfer of data
    output reg                       s_axis_tready = 1'b0,     //% Read ready - master can accept the read data and response
    input  wire                      s_axis_tvalid,     //% Read valid issued by master - data is valid

    input   wire            engine_aresetn,
    input   wire            engine_clock,
    
    output wire [DATA_WIDTH-1:0] debug_tdata
);

assign debug_tdata = s_axis_tdata;

////////////////////////////////////////////////////////////////////////////
// Nets used for AXI LITE interface 
localparam  SLV_ADDR_SIZE       = ADDR_WIDTH - (DATA_WIDTH/32) - 1;
localparam  SLV_STRB_SIZE       = DATA_WIDTH/8;
localparam  SLV_DATA_SIZE       = DATA_WIDTH;
localparam  AXI_LITE_DATA_BYTES = DATA_WIDTH/8;

reg     [SLV_DATA_SIZE - 1 : 0] slv_rdata = {SLV_DATA_SIZE{1'b0}};
reg     [SLV_DATA_SIZE - 1 : 0] eng_slv_rdata = {SLV_DATA_SIZE{1'b0}};
wire    [SLV_ADDR_SIZE - 1 : 0] slv_araddr;
wire                            slv_rden;

wire    [SLV_DATA_SIZE - 1 : 0] slv_wdata;
reg     [SLV_DATA_SIZE - 1 : 0] eng_data_transfer;
wire    [SLV_ADDR_SIZE - 1 : 0] slv_awaddr;
wire                            slv_wren;
wire    [SLV_STRB_SIZE - 1 : 0] slv_wstrb; 
reg                             slv_rdy = 1'b1;     // Slave read/write ready
reg                             slv_rdvalid = 1'b0; // Svale valid data on read bus
////////////////////////////////////////////////////////////////////////////


localparam MEMORY_SIZE = (MAX_PACKET_LENGTH) * 8;
localparam MEMORY_WADDR_WIDTH = $clog2(MAX_PACKET_LENGTH / (DATA_WIDTH/8));
localparam MEMORY_WADDR_INCR  = {{(MEMORY_WADDR_WIDTH-1){1'b0}}, 1'b1};
localparam MEMORY_RADDR_WIDTH = $clog2((MAX_PACKET_LENGTH));
localparam MEMORY_RADDR_INCR  = {{(MEMORY_RADDR_WIDTH-1){1'b0}}, 1'b1};

localparam ENG_NR_ADDR      = $clog2(ENGINES_NUMBER);
localparam ENG_AL_ADDR_SIZE = $clog2(ENGINE_MAX_SIZE / ((DATA_WIDTH/8))) ;
localparam ENG_DATA_SIZE    = 8;
localparam ENG_ADDR_SIZE    = $clog2(ENGINE_MAX_SIZE);

reg  [ENG_DATA_SIZE  - 1 : 0] ENG_WDATA [0:ENGINES_NUMBER-1];     // Write data registers for engines
reg  [ENG_ADDR_SIZE  - 1 : 0] ENG_WADDR [0:ENGINES_NUMBER-1];     // Write write address bus for engines
reg  [ENGINES_NUMBER - 1 : 0] ENG_WEN;                            // Write enable for engines
wire [ENG_DATA_SIZE  - 1 : 0] ENG_RDATA [0:ENGINES_NUMBER-1];     // Read data registers for engines
reg  [ENG_ADDR_SIZE  - 1 : 0] ENG_RADDR [0:ENGINES_NUMBER-1];     // Read data registers for engines
reg  [ENGINES_NUMBER - 1 : 0] ENG_REN;                            // Read enable for engines

wire [ENGINES_NUMBER-1:0]   engine_match; // One hot encoded register indicating if any engine founded a match
reg                         drop_packet = 1'b0; // If there is a match on an engie then this net is asserted

reg     eng_slv_wren = 1'b0;  // Asserted if a write operation is made
reg     eng_slv_rden = 1'b0;  // Asserted if a read operation is made

reg [DATA_WIDTH - 1:0] configuration_register = {DATA_WIDTH{1'b0}};

reg     start_operation = 1'b0; // Asserted when a read or write operation to an engine must be performed
wire    eng_start_operation;    // Is start_operation signal in engine_clokc domain
reg     eng_al_op_fin = 1'b0;   // Asserted when the read or write operation to an engine finished
wire    al_op_fin;  // Is eng_ap_fin in S_AXI_LITE_ACLK clock domain

////////////////////////////////////////////////////////////////////////////
localparam [1:0]	AL_IDLE             = 2'b00;
localparam [1:0]	AL_WAIT_OP_FIN      = 2'b01;
//
reg [1:0]      al_state = AL_IDLE;
reg [2:0]      debug_reg = 3'd0;
////////////////////////////////////////////////////////////////////////////
/*! \brief &nbsp;  Implements state machine that communicates with the PU on
 * AXI Lite.
 *
 *  &nbsp; Engines and status/configuration registers are accessed on AXI Lite.
 * This process wait that the read and write operation on an engine area to
 * finish and to enble teh slc_rdy signal.
 */
////////////////////////////////////////////////////////////////////////////
always@(posedge S_AXI_LITE_ACLK) begin
if(S_AXI_LITE_ARESETN == 1'b0) begin
    
    slv_rdy         <= #TCQ 1'b1;
    slv_rdvalid     <= #TCQ 1'b0;
    start_operation <= #TCQ 1'b0;
    eng_slv_wren    <= #TCQ 1'b0;
    eng_slv_rden    <= #TCQ 1'b0;

    al_state        <= #TCQ AL_IDLE;
    //
end
else begin

    case(al_state)

        AL_IDLE: begin

            eng_slv_wren    <= #TCQ 1'b0;
            eng_slv_rden    <= #TCQ 1'b0;
            slv_rdy         <= #TCQ 1'b1;
            slv_rdvalid     <= #TCQ 1'b0;
    
            if(slv_wren) begin
                            
                if(slv_awaddr == {(SLV_ADDR_SIZE){1'b1}}) begin
                    configuration_register <= #TCQ slv_wdata;
                end
                else begin

                    al_state        <= #TCQ AL_WAIT_OP_FIN;
                    eng_slv_wren    <= #TCQ 1'b1;
                    start_operation <= #TCQ 1'b1;
                    slv_rdy         <= #TCQ 1'b0;
                end
                //
            end
            else if(slv_rden) begin               
/*
                if(~(|slv_araddr[3:0])) begin

                    al_state        <= #TCQ AL_WAIT_OP_FIN;
                    eng_slv_rden    <= #TCQ 1'b1;
                    start_operation <= #TCQ 1'b1;
                    slv_rdy         <= #TCQ 1'b0;
                    slv_rdvalid     <= #TCQ 1'b0;
                end
                else if(debug_reg == 3'b000) begin
                    slv_rdata       <= #TCQ {last_transfer, search_ready, packet_received, _mem_wea, state, broadcast_state};
                    slv_rdvalid     <= #TCQ 1'b1;
                    debug_reg       <= #TCQ debug_reg + 3'b001;
                end
                else if(debug_reg == 3'b001) begin
                    slv_rdata       <= #TCQ _mem_addra;
                    slv_rdvalid     <= #TCQ 1'b1;
                    debug_reg       <= #TCQ debug_reg + 3'b001;
                end
                else if(debug_reg == 3'b010) begin
                    slv_rdata       <= #TCQ _mem_addrb;
                    slv_rdvalid     <= #TCQ 1'b1;
                    debug_reg       <= #TCQ debug_reg + 3'b001;
                end
                else if(debug_reg == 3'b011) begin
                    slv_rdata       <= #TCQ engine_match[0];
                    slv_rdvalid     <= #TCQ 1'b1;
                    debug_reg       <= #TCQ debug_reg + 3'b001;
                end
                else if(debug_reg == 3'b100) begin
                    slv_rdata       <= #TCQ rec_counter;
                    slv_rdvalid     <= #TCQ 1'b1;
                    debug_reg       <= #TCQ 3'b000;
                end                
*/

                if(slv_araddr == { {(SLV_ADDR_SIZE-2){1'b1}}, 2'b10 }) begin

                    slv_rdata       <= #TCQ MAX_PACKET_LENGTH;
                    slv_rdvalid     <= #TCQ 1'b1;
                end
                else if(slv_araddr == { {(SLV_ADDR_SIZE-2){1'b1}}, 2'b11 }) begin
                    
                    slv_rdata       <= #TCQ {ENGINE_MAX_SIZE, ENGINES_NUMBER};
                    slv_rdvalid     <= #TCQ 1'b1;
                end
                else begin

                    al_state        <= #TCQ AL_WAIT_OP_FIN;
                    eng_slv_rden    <= #TCQ 1'b1;
                    start_operation <= #TCQ 1'b1;
                    slv_rdy         <= #TCQ 1'b0;
                    slv_rdvalid     <= #TCQ 1'b0;
                end
                //
            end
            else begin
                start_operation <= #TCQ 1'b0;
            end
        end

        AL_WAIT_OP_FIN: begin
            
            start_operation <= #TCQ 1'b0;

            if(al_op_fin) begin
                al_state        <= #TCQ AL_IDLE;
                slv_rdy         <= #TCQ 1'b1;
                slv_rdata       <= #TCQ eng_slv_rdata;
                slv_rdvalid     <= #TCQ eng_slv_rden;
            end
            else begin
                al_state   <= #TCQ AL_WAIT_OP_FIN;
            end
            //
        end

        default: begin
            al_state   <= #TCQ AL_IDLE;
        end

    endcase

    
    //
end // RESET 
end // ALWAYS
////////////////////////////////////////////////////////////////////////////

reg  [3:0]  transfer_to_eng_counter = 4'd0; // Counter used to sent the data from AXI Lite to engines on a 8 bit data width

////////////////////////////////////////////////////////////////////////////
localparam [1:0]	ENL_IDLE             = 2'b00;
localparam [1:0]	ENL_WRITE_TO_ENG     = 2'b01;
localparam [1:0]	ENL_READ_FROM_ENG    = 2'b10;
localparam [1:0]	WAIT_SIGNALING       = 2'b11;
//
reg [1:0] eng_alite_state = AL_IDLE; 
////////////////////////////////////////////////////////////////////////////
/*! \brief &nbsp;  Implements state machine that communicates with the PU on
 * AXI Lite.
 *
 *  &nbsp; Engines and status/configuration registers
 * are accessed on AXI Lite. This process implements both read and write
 * cases.
 */
////////////////////////////////////////////////////////////////////////////
always@(posedge engine_clock) begin
if(engine_aresetn == 1'b0) begin
    
    ENG_WEN         <= #TCQ {ENG_DATA_SIZE{1'b0}};
    ENG_REN         <= #TCQ {ENG_DATA_SIZE{1'b0}};
    
    eng_alite_state <= #TCQ ENL_IDLE;
    eng_al_op_fin   <= #TCQ 1'b0;
    transfer_to_eng_counter  <= #TCQ AXI_LITE_DATA_BYTES;
    //
end
else begin

    case(eng_alite_state)

        ENL_IDLE: begin

            transfer_to_eng_counter  <= #TCQ AXI_LITE_DATA_BYTES;
            eng_al_op_fin            <= #TCQ 1'b0;
            ENG_REN    <= #TCQ {ENG_DATA_SIZE{1'b0}};
            ENG_WEN    <= #TCQ {ENG_DATA_SIZE{1'b0}};

            if(eng_slv_wren & eng_start_operation) begin

                eng_data_transfer    <= #TCQ slv_wdata >> 8;
                ENG_WDATA[slv_awaddr[ENG_NR_ADDR + ENG_AL_ADDR_SIZE - 1 : ENG_AL_ADDR_SIZE]] <= #TCQ slv_wdata[7:0];
                ENG_WADDR[slv_awaddr[ENG_NR_ADDR + ENG_AL_ADDR_SIZE - 1 : ENG_AL_ADDR_SIZE]] <= #TCQ slv_awaddr[ENG_AL_ADDR_SIZE - 1 : 0] << 2;
                ENG_WEN  [slv_awaddr[ENG_NR_ADDR + ENG_AL_ADDR_SIZE - 1 : ENG_AL_ADDR_SIZE]] <= #TCQ 1'b1;
                eng_alite_state   <= #TCQ ENL_WRITE_TO_ENG;
                //
            end
            else if(eng_slv_rden  & eng_start_operation) begin               
                
                ENG_RADDR[slv_araddr[ENG_NR_ADDR + ENG_AL_ADDR_SIZE - 1 : ENG_AL_ADDR_SIZE]] <= #TCQ slv_araddr[ENG_AL_ADDR_SIZE - 1 : 0] << 2;
                ENG_REN  [slv_araddr[ENG_NR_ADDR + ENG_AL_ADDR_SIZE - 1 : ENG_AL_ADDR_SIZE]] <= #TCQ 1'b1;
                eng_alite_state   <= #TCQ ENL_READ_FROM_ENG;
                //
            end
        end

        ENL_WRITE_TO_ENG: begin
            
            eng_data_transfer           <= #TCQ eng_data_transfer >> 8;
            transfer_to_eng_counter     <= #TCQ transfer_to_eng_counter - 4'h1;
            ENG_WDATA[slv_awaddr[ENG_NR_ADDR + ENG_AL_ADDR_SIZE - 1 : ENG_AL_ADDR_SIZE]] <= #TCQ eng_data_transfer[7:0];
            ENG_WADDR[slv_awaddr[ENG_NR_ADDR + ENG_AL_ADDR_SIZE - 1 : ENG_AL_ADDR_SIZE]] <= #TCQ 
                                 ENG_WADDR[slv_awaddr[ENG_NR_ADDR + ENG_AL_ADDR_SIZE - 1 : ENG_AL_ADDR_SIZE]] + {{(SLV_ADDR_SIZE-1){1'b0}}, 1'b1};

            if(transfer_to_eng_counter == 4'h1) begin
            
                ENG_WEN  [slv_awaddr[ENG_NR_ADDR + ENG_AL_ADDR_SIZE - 1 : ENG_AL_ADDR_SIZE]] <= #TCQ 1'b0;
                transfer_to_eng_counter <= #TCQ 4'h4;
                eng_alite_state         <= #TCQ WAIT_SIGNALING;
            end
            else begin
                eng_alite_state     <= #TCQ ENL_WRITE_TO_ENG;
            end
            //
        end

        ENL_READ_FROM_ENG: begin
            
            // make more checks!!!
            // if(|transfer_to_eng_counter) begin
            if(transfer_to_eng_counter < AXI_LITE_DATA_BYTES) begin
                eng_slv_rdata  <= #TCQ {ENG_RDATA[slv_araddr[ENG_NR_ADDR + ENG_AL_ADDR_SIZE - 1 : ENG_AL_ADDR_SIZE]], eng_slv_rdata[SLV_DATA_SIZE-1:8]};
            end
            transfer_to_eng_counter     <= #TCQ transfer_to_eng_counter - 4'h1;
            ENG_RADDR[slv_araddr[ENG_NR_ADDR + ENG_AL_ADDR_SIZE - 1 : ENG_AL_ADDR_SIZE]] <= #TCQ 
                                 ENG_RADDR[slv_araddr[ENG_NR_ADDR + ENG_AL_ADDR_SIZE - 1 : ENG_AL_ADDR_SIZE]] + {{(SLV_ADDR_SIZE-1){1'b0}}, 1'b1};

            if(transfer_to_eng_counter == 4'h0) begin
            
                ENG_REN  [slv_araddr[ENG_NR_ADDR + ENG_AL_ADDR_SIZE - 1 : ENG_AL_ADDR_SIZE]] <= #TCQ 1'b0;
                transfer_to_eng_counter <= #TCQ 4'h4;
                eng_alite_state         <= #TCQ WAIT_SIGNALING;
            end
            else begin
                eng_alite_state   <= #TCQ ENL_READ_FROM_ENG;
            end
            //
        end

        WAIT_SIGNALING: begin

            eng_al_op_fin           <= #TCQ 1'b1;
            transfer_to_eng_counter <= #TCQ transfer_to_eng_counter - 4'h1;

            if(transfer_to_eng_counter == 4'h0) begin
                eng_alite_state   <= #TCQ ENL_IDLE;
            end
            else begin
                eng_alite_state   <= #TCQ WAIT_SIGNALING;
            end
        end

        default: begin

            eng_alite_state         <= #TCQ ENL_IDLE;
        end

    endcase
    //
end // RESET 
end // ALWAYS
////////////////////////////////////////////////////////////////////////////

// Write port into RAM
reg [MEMORY_WADDR_WIDTH-1:0] _mem_addra = {MEMORY_WADDR_WIDTH{1'b0}};
reg [DATA_WIDTH-1:0]         _mem_dina  = {DATA_WIDTH{1'b0}};
reg                          _mem_wea   = 1'b0;

// Read port into RAM
reg [MEMORY_RADDR_WIDTH-1:0] _mem_addrb = {MEMORY_RADDR_WIDTH{1'b0}};
wire[7:0]                    _mem_doutb;

reg [MEMORY_RADDR_WIDTH-1:0] rec_counter = {MEMORY_RADDR_WIDTH{1'b0}};    // Counts the number of words received and copyed into RAM
reg                          start_search = 1'b0;   // Asserted when packet starts to be received
reg                          packet_received = 1'b0; // Asserted after all packet was received
wire                         search_ready; // Is eng_search_ready net in axis_clk clock domain

////////////////////////////////////////////////////////////////////////////
localparam [1:0]	IDLE       		= 2'b00;
localparam [1:0]	RECEIVE_PACKET  = 2'b01;
localparam [1:0]	WAIT_SEARCH     = 2'b10;
//
reg [1:0] state = IDLE; 
////////////////////////////////////////////////////////////////////////////
/*! \brief &nbsp; This state machine receives the packet from DMA and
 * push them into reception RAM. Then it send on DMA the response.
 */
////////////////////////////////////////////////////////////////////////////
always@(posedge axis_clk) begin
if(axis_aresetn == 1'b0) begin
    
    _mem_addra  <= #TCQ {MEMORY_WADDR_WIDTH{1'b0}};
    _mem_dina   <= #TCQ {DATA_WIDTH{1'b0}};
    _mem_wea    <= #TCQ 1'b0;

    rec_counter     <= #TCQ {MEMORY_RADDR_WIDTH{1'b0}};
    s_axis_tready   <= #TCQ 1'b0;
    start_search    <= #TCQ 1'b0;
    packet_received <= #TCQ 1'b0;

    state           <= #TCQ IDLE;
    //
end
else begin

    start_search    <= #TCQ 1'b0;
    m_axis_tvalid   <= #TCQ 1'b0;
    m_axis_tlast    <= #TCQ 1'b0;

    case(state)

        IDLE: begin

            if(s_axis_tvalid & s_axis_tready) begin

                _mem_dina       <= #TCQ s_axis_tdata;
                _mem_wea        <= #TCQ 1'b1;
                state           <= #TCQ RECEIVE_PACKET;
                start_search    <= #TCQ 1'b1;
            end
            else begin
                _mem_dina       <= #TCQ {DATA_WIDTH{1'b0}};
                _mem_wea        <= #TCQ 1'b0;
            end

            s_axis_tready   <= #TCQ 1'b1;
            packet_received <= #TCQ 1'b0;
            _mem_addra      <= #TCQ {MEMORY_WADDR_WIDTH{1'b0}};
            rec_counter     <= #TCQ MEMORY_RADDR_INCR*4;
        end

        RECEIVE_PACKET: begin
                        
            if(s_axis_tvalid) begin

                _mem_addra  <= #TCQ _mem_addra + MEMORY_WADDR_INCR;
                _mem_dina   <= #TCQ s_axis_tdata;
                                    
                _mem_wea   <= #TCQ |s_axis_tkeep;
                case(s_axis_tkeep)
                    4'b0001: begin
                        rec_counter     <= #TCQ rec_counter + MEMORY_RADDR_INCR*1;
                    end
                    4'b0011: begin
                        rec_counter     <= #TCQ rec_counter + MEMORY_RADDR_INCR*2;
                    end
                    4'b0111: begin
                        rec_counter     <= #TCQ rec_counter + MEMORY_RADDR_INCR*3;
                    end
                    4'b1111: begin
                        rec_counter     <= #TCQ rec_counter + MEMORY_RADDR_INCR*4;
                    end
                    default: begin
                        rec_counter     <= #TCQ rec_counter;
                    end
                endcase

                if(s_axis_tlast) begin
                    state           <= #TCQ WAIT_SEARCH; // Wait for search to finish
                    s_axis_tready   <= #TCQ 1'b0;
                    packet_received <= #TCQ 1'b1;
                end
                //
            end
            else begin
                _mem_wea    <= #TCQ 1'b0;
            end
        end

        WAIT_SEARCH: begin

            _mem_wea   <= #TCQ 1'b0;

            if(search_ready) begin

                // Send the response to DMA  maybe complete with reg {engine_match}
                m_axis_tdata    <= #TCQ {{(DATA_WIDTH-2){1'b0}}, ~drop_packet, drop_packet};  // 0x01 for drop and 0x02 for clean

                if(m_axis_tvalid & m_axis_tready) begin
                    m_axis_tvalid   <= #TCQ 1'b0;
                    m_axis_tlast    <= #TCQ 1'b0;
                end
                else begin
                    m_axis_tvalid   <= #TCQ 1'b1;
                    m_axis_tlast    <= #TCQ 1'b1;
                end
                state           <= #TCQ IDLE;
            end
            else begin
                state    <= #TCQ WAIT_SEARCH;
            end
        end

        default: begin
            state    <= #TCQ IDLE;
        end

    endcase
    //
end // RESET 
end // ALWAYS
////////////////////////////////////////////////////////////////////////////

wire                          eng_start_search; // Is start_search net in engine_clock clock domain
wire                          eng_packet_received; // Is packet_received net in engine_clock clock domain
reg                           eng_search_ready = 1'b1; // Asserted when data can be searched

wire        last_transfer;  // Asserted on the last transfer on m_axis_eng* interface
assign #TCQ last_transfer = (_mem_addrb == rec_counter) & ~eng_start_search;

// Minimal AXI Stream interface used to broadcast the
// targeted packet to search engines.
// This interface will be routed using internal global buffers (BUFG)
// in order to satisfy the high fanout caused by many engine instances.
wire [7:0]   _m_axis_eng_tdata;
wire         _m_axis_eng_tvalid;
wire         _transfer_active;
//
reg [7:0]   m_axis_eng_tdata = 8'd0;
reg         m_axis_eng_tvalid = 1'b0;
wire        m_axis_eng_tlast;
//
BUFG tdata_buf0(.I(m_axis_eng_tdata[0]), .O(_m_axis_eng_tdata[0])); 
BUFG tdata_buf1(.I(m_axis_eng_tdata[1]), .O(_m_axis_eng_tdata[1]));
BUFG tdata_buf2(.I(m_axis_eng_tdata[2]), .O(_m_axis_eng_tdata[2]));
BUFG tdata_buf3(.I(m_axis_eng_tdata[3]), .O(_m_axis_eng_tdata[3]));
BUFG tdata_buf4(.I(m_axis_eng_tdata[4]), .O(_m_axis_eng_tdata[4]));
BUFG tdata_buf5(.I(m_axis_eng_tdata[5]), .O(_m_axis_eng_tdata[5]));
BUFG tdata_buf6(.I(m_axis_eng_tdata[6]), .O(_m_axis_eng_tdata[6]));
BUFG tdata_buf7(.I(m_axis_eng_tdata[7]), .O(_m_axis_eng_tdata[7]));
BUFG tvalid_buf(.I(m_axis_eng_tvalid),   .O(_m_axis_eng_tvalid));
BUFG tlast_buf (.I(~eng_search_ready),   .O(_transfer_active));
//
assign #TCQ m_axis_eng_tlast = last_transfer & eng_packet_received;

////////////////////////////////////////////////////////////////////////////
localparam [1:0]	WAIT_PACKET      = 2'b00;
localparam [1:0]	SEND_TO_ENGINES  = 2'b01;
localparam [1:0]	WAIT_A_CICLE     = 2'b10;
//
reg [1:0] broadcast_state = WAIT_PACKET; 
////////////////////////////////////////////////////////////////////////////
/*! \brief &nbsp; This state machine get the packet from reception RAM and
 * broadcasts it to the engines.
 */
////////////////////////////////////////////////////////////////////////////
always@(posedge engine_clock) begin
if(engine_aresetn == 1'b0) begin
    
    _mem_addrb          <= #TCQ {MEMORY_RADDR_WIDTH{1'b0}};
    eng_search_ready    <= #TCQ 1'b1;
    m_axis_eng_tdata    <= #TCQ 8'd0;
    m_axis_eng_tvalid   <= #TCQ 1'b0;
    drop_packet         <= #TCQ 1'b0;   

    broadcast_state    <= #TCQ WAIT_PACKET;
    //
end
else begin

    case(broadcast_state)

        WAIT_PACKET: begin

            if(eng_start_search) begin
                broadcast_state     <= #TCQ SEND_TO_ENGINES;
                eng_search_ready    <= #TCQ 1'b0;
            end
            else begin
                eng_search_ready    <= #TCQ 1'b1;
            end
        end

        SEND_TO_ENGINES: begin

            m_axis_eng_tdata    <= #TCQ _mem_doutb;
            m_axis_eng_tvalid   <= #TCQ 1'b1;

            if(~eng_packet_received & last_transfer) begin
                m_axis_eng_tvalid  <= #TCQ 1'b0;
                broadcast_state    <= #TCQ WAIT_A_CICLE;
            end
            else if(m_axis_eng_tlast) begin
                m_axis_eng_tvalid  <= #TCQ 1'b0;
                drop_packet        <= #TCQ |engine_match; 
                broadcast_state    <= #TCQ WAIT_PACKET;
                _mem_addrb         <= #TCQ {MEMORY_RADDR_WIDTH{1'b0}};
                eng_search_ready   <= #TCQ 1'b1;
            end
            else begin
                _mem_addrb         <= #TCQ _mem_addrb + MEMORY_RADDR_INCR;
                broadcast_state    <= #TCQ WAIT_A_CICLE;
            end
        end

        WAIT_A_CICLE: begin
            m_axis_eng_tvalid  <= #TCQ 1'b0;
            broadcast_state    <= #TCQ SEND_TO_ENGINES;
        end

        default: begin
            broadcast_state    <= #TCQ WAIT_PACKET;
        end

    endcase
    //
end // RESET 
end // ALWAYS
////////////////////////////////////////////////////////////////////////////

xpm_memory_sdpram #(

    .ADDR_WIDTH_A               (MEMORY_WADDR_WIDTH),         // DECIMAL
    .ADDR_WIDTH_B               (MEMORY_RADDR_WIDTH),         // DECIMAL
    .AUTO_SLEEP_TIME            (0),                // DECIMAL
    .BYTE_WRITE_WIDTH_A         (DATA_WIDTH),       // DECIMAL
    .CLOCKING_MODE              ("independent_clock"),   // String
    .ECC_MODE                   ("no_ecc"),            // String
    .MEMORY_INIT_FILE           ("none"),      // String
    .MEMORY_INIT_PARAM          ("0"),        // String
    .MEMORY_OPTIMIZATION        ("true"),   // String
    .MEMORY_PRIMITIVE           ("auto"),      // String
    .MEMORY_SIZE                (MEMORY_SIZE),             // DECIMAL
    .MESSAGE_CONTROL            (0),            // DECIMAL
    .READ_DATA_WIDTH_B          (8),            // DECIMAL
    .READ_LATENCY_B             (1),                 // DECIMAL
    .READ_RESET_VALUE_B         ("0"),               // String
    .USE_EMBEDDED_CONSTRAINT    (0),                // DECIMAL
    .USE_MEM_INIT               (1),                // DECIMAL
    .WAKEUP_TIME                ("disable_sleep"),  // String
    .WRITE_DATA_WIDTH_A         (DATA_WIDTH),               // DECIMAL
    .WRITE_MODE_B               ("no_change")       // String
)
xpm_memory_sdpram_inst (

    .clka       (axis_clk),
    .clkb       (engine_clock),
    .rstb       (~engine_aresetn),

    .addrb      (_mem_addrb),
    .doutb      (_mem_doutb),
    .enb        (1'b1),

    .addra      (_mem_addra),
    .dina       (_mem_dina),
    .wea        (_mem_wea),
    .ena        (1'b1),

    .dbiterrb   (),
    .sbiterrb   (),
    .injectdbiterra (1'b0),
    .injectsbiterra (1'b0),

    .regceb     (1'b1),
    .sleep      (1'b0)
);

// Generate the engines instances
genvar i;
generate
    for (i = 0; i< ENGINES_NUMBER; i = i + 1) begin : generate_engines
    engine #(
        .TCQ    (TCQ),
        .ADDR_SIZE (ENG_ADDR_SIZE)
    ) ENGINE_inst (

        .CLOCK      (engine_clock),
        .RESETN     (engine_aresetn),

        .WDATA      (ENG_WDATA[i]),
        .WADDR      (ENG_WADDR[i]),
        .WEN        (ENG_WEN  [i]),
        .RDATA      (ENG_RDATA[i]),
        .RADDR      (ENG_RADDR[i]),
        .REN        (ENG_REN  [i]),

        .s_axis_tdata       (_m_axis_eng_tdata),
        .s_axis_tvalid      (_m_axis_eng_tvalid),
        .transfer_active     (_transfer_active),

        .PATTERN_FOUNDED    (engine_match[i])
    );
end 
endgenerate

axi_lite_if#(

    .C_S_AXI_DATA_WIDTH     (DATA_WIDTH),
    .C_S_AXI_ADDR_WIDTH     (ADDR_WIDTH),
    .C_S_SLV_ALWAYS_RDY     (1'b1),
    .TCQ                    (TCQ)
    
) AXI_LITE_STAVE_inst (
        
    .S_AXI_ACLK          (S_AXI_LITE_ACLK),
    .S_AXI_ARESETN       (S_AXI_LITE_ARESETN),

    .S_AXI_AWADDR        (S_AXI_LITE_AWADDR),   
    .S_AXI_AWVALID       (S_AXI_LITE_AWVALID),
    .S_AXI_AWREADY       (S_AXI_LITE_AWREADY),

    .S_AXI_WDATA         (S_AXI_LITE_WDATA),    
    .S_AXI_WSTRB         (S_AXI_LITE_WSTRB),
    .S_AXI_WVALID        (S_AXI_LITE_WVALID),
    .S_AXI_WREADY        (S_AXI_LITE_WREADY),

    .S_AXI_BRESP         (S_AXI_LITE_BRESP),
    .S_AXI_BVALID        (S_AXI_LITE_BVALID),
    .S_AXI_BREADY        (S_AXI_LITE_BREADY),

    .S_AXI_ARADDR        (S_AXI_LITE_ARADDR),
    .S_AXI_ARVALID       (S_AXI_LITE_ARVALID),
    .S_AXI_ARREADY       (S_AXI_LITE_ARREADY),

    .S_AXI_RDATA         (S_AXI_LITE_RDATA),
    .S_AXI_RVALID        (S_AXI_LITE_RVALID),
    .S_AXI_RREADY        (S_AXI_LITE_RREADY),
    .S_AXI_RRESP         (S_AXI_LITE_RRESP),

    .slv_araddr         (slv_araddr),
    .slv_rdata          (slv_rdata ),
    .slv_rden           (slv_rden  ),
    .slv_awaddr         (slv_awaddr),
    .slv_wdata          (slv_wdata ),
    .slv_wren           (slv_wren  ),
    .slv_wstrb          (slv_wstrb ),
    .slv_rdy            (slv_rdy   ),
    .slv_rdvalid        (slv_rdvalid)
);

xpm_cdc_single #(
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; integer; 0=disable simulation init values, 1=enable simulation init
                        // values
    .SIM_ASSERT_CHK(0), // DECIMAL; integer; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(1)   // DECIMAL; integer; 0=do not register input, 1=register input
)
xpm_cdc_single_inst0 (
    .dest_out   (al_op_fin), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                        // registered.

    .dest_clk   (S_AXI_LITE_ACLK), // 1-bit input: Clock signal for the destination clock domain.
    .src_clk    (engine_clock),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
    .src_in     (eng_al_op_fin)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
);

xpm_cdc_single #(
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; integer; 0=disable simulation init values, 1=enable simulation init
                        // values
    .SIM_ASSERT_CHK(0), // DECIMAL; integer; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(1)   // DECIMAL; integer; 0=do not register input, 1=register input
)
xpm_cdc_single_inst3 (
    .dest_out   (search_ready), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                        // registered.

    .dest_clk   (axis_clk), // 1-bit input: Clock signal for the destination clock domain.
    .src_clk    (engine_clock),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
    .src_in     (eng_search_ready)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
);

xpm_cdc_single #(
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; integer; 0=disable simulation init values, 1=enable simulation init
                        // values
    .SIM_ASSERT_CHK(0), // DECIMAL; integer; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(1)   // DECIMAL; integer; 0=do not register input, 1=register input
)
xpm_cdc_single_inst4 (
    .dest_out   (eng_start_search), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                        // registered.

    .dest_clk   (engine_clock), // 1-bit input: Clock signal for the destination clock domain.
    .src_clk    (axis_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
    .src_in     (start_search)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
);

xpm_cdc_single #(
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; integer; 0=disable simulation init values, 1=enable simulation init
                        // values
    .SIM_ASSERT_CHK(0), // DECIMAL; integer; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(1)   // DECIMAL; integer; 0=do not register input, 1=register input
)
xpm_cdc_single_inst5 (
    .dest_out   (eng_packet_received), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                        // registered.

    .dest_clk   (engine_clock), // 1-bit input: Clock signal for the destination clock domain.
    .src_clk    (axis_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
    .src_in     (packet_received)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
);

xpm_cdc_single #(
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; integer; 0=disable simulation init values, 1=enable simulation init
                        // values
    .SIM_ASSERT_CHK(0), // DECIMAL; integer; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(1)   // DECIMAL; integer; 0=do not register input, 1=register input
)
xpm_cdc_single_inst6 (
    .dest_out   (eng_start_operation), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                        // registered.

    .dest_clk   (engine_clock), // 1-bit input: Clock signal for the destination clock domain.
    .src_clk    (S_AXI_LITE_ACLK),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
    .src_in     (start_operation)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
);


endmodule