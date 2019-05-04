`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  Andrei Nicolae Georgian
// 
// Create Date: 06/13/2018 10:39:44 PM
// Design Name: Ethernet Packet Inspection
// Module Name: inspection_unit
// Project Name: Ethernet packet inspection
// Target Devices: Zynq700
// Tool Versions: 
// Description: Test bench for inspection_unit module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module system_tb(

);

// PIC: Packet Inspection CORE

localparam TCQ = 1; // Delay used in simulation: used to show gates propagation delay
localparam S_AXI_LITE_DATA_WIDTH           = 32;           // AXI data bus width
localparam S_AXI_LITE_ADDR_WIDTH           = 32;           // AXI address bus width

localparam AXIS_DATA_WIDTH = 32;


/////////////////////////////////////////////////////////////////////////////////////////////////////
//AXI Lite Slave interface 
// System Signals
wire                                     S_AXI_LITE_ACLK;     // AXI clock signal
wire                                     S_AXI_LITE_ARESETN;  // AXI active low reset signal

// Slave Interface Write Address channel Ports
wire    [S_AXI_LITE_ADDR_WIDTH - 1:0]  S_AXI_LITE_AWADDR;   // Write address (issued by master, acceped by Slave)
wire                                     S_AXI_LITE_AWVALID;  // Write address valid and control information
wire                                     S_AXI_LITE_AWREADY;  // Write address ready issued by slave

// Slave Interface Write Data channel Ports
wire    [S_AXI_LITE_DATA_WIDTH - 1:0]  S_AXI_LITE_WDATA;    // Write data (issued by master, acceped by Slave)
wire    [S_AXI_LITE_DATA_WIDTH/8-1:0]  S_AXI_LITE_WSTRB;    // Write strobes - 1 bit for every 8 bits of valid data
wire                                     S_AXI_LITE_WVALID;   // Write valid data and strobes
wire                                     S_AXI_LITE_WREADY;   // Write ready - slave can accept write data 

// Slave Interface Write Response channel Ports
wire    [1:0]                            S_AXI_LITE_BRESP;    // Write response - indicates the status of write transaction
wire                                     S_AXI_LITE_BVALID;   // Write response is valid
wire                                     S_AXI_LITE_BREADY;   // Response ready - master can accept a write response

// Slave Interface Read Address channel Ports
wire    [S_AXI_LITE_ADDR_WIDTH - 1:0]  S_AXI_LITE_ARADDR;   // Read address (issued by master, acceped by Slave)
wire                                     S_AXI_LITE_ARVALID;  // Read address valid and control information
wire                                     S_AXI_LITE_ARREADY;  // Read address ready issued by slave

// Slave Interface Read Data channel Ports
wire    [S_AXI_LITE_DATA_WIDTH - 1:0]  S_AXI_LITE_RDATA;    // Read data (issued by slave)
wire                                     S_AXI_LITE_RVALID;   // Read valid issued by slave - data is valid
wire                                     S_AXI_LITE_RREADY;   // Read ready - master can accept the read data and response
wire    [1:0]                            S_AXI_LITE_RRESP;    // Read response - indicates the status of read transfer
/////////////////////////////////////////////////////////////////////////////////////////////////////      

//////////////////////////////////////////////////
// Signals used to communicate with PIC using AXI LITE 
reg  [S_AXI_LITE_ADDR_WIDTH-1:0]    
           PIC_LITE_AWADDR;	// Write address register for AXI Lite master interface 	(User signal)
reg  [S_AXI_LITE_DATA_WIDTH-1:0]    
           PIC_LITE_WDATA;		// Write data register for AXI Lite master interface  		(User signal)
reg  [S_AXI_LITE_ADDR_WIDTH-1:0]    
           PIC_LITE_ARADDR;	// Read address register for AXI Lite master interface  	(User signal)
wire [S_AXI_LITE_DATA_WIDTH-1:0]    
           PIC_LITE_RDATA;		// Read data register for AXI Lite master interface  		(User signal)
reg        PIC_LITE_START_WRITE = 1'b0;	// Signal asserted to start writing on AXI Lite master interface	(User signal)
reg        PIC_LITE_START_READ  = 1'b0;	// Signal asserted to start reading on AXI Lite master interface	(User signal)
wire       PIC_LITE_WCOMPLETE;		// Signal from AXI Lite master IP interface that indicates when the write is completed		(User signal)
wire       PIC_LITE_WRITE_RESP_ERROR;// Signal from AXI Lite master IP interface that indicates when a write error is detected 	(User signal)
wire       PIC_LITE_READ_RESP_ERROR;	// Signal from AXI Lite master IP interface that indicates when a read error is detected 	(User signal)
wire       PIC_LITE_RCOMPLETE;		// Signal from AXI Lite master IP interface that indicates when the read is completed 		(User signal)
//////////////////////////////////////////////////

// Generate AXI clock: 100 MHz for both AXI Lite and AXI interfaces
reg       AXI_CLK = 1'b0;
initial   AXI_CLK <= 1'b0;
always #5 AXI_CLK = ~AXI_CLK;
// Generate AXI reset (active low) for both AXI Lite and AXI interfaces
reg      AXI_ARESETN = 1'b0;
initial begin
    @(posedge AXI_CLK);
    @(posedge AXI_CLK);
    @(posedge AXI_CLK);
    AXI_ARESETN <= 1'b1;
end
//
assign S_AXI_LITE_ACLK = AXI_CLK;
assign S_AXI_LITE_ARESETN = AXI_ARESETN;

wire axis_clk;
wire axis_aresetn;
assign axis_clk     = AXI_CLK;
assign axis_aresetn = AXI_ARESETN;

// Generate Engine clock: 200 MHz
reg       engine_clock = 1'b0;
initial   engine_clock <= 1'b0;
always #5 engine_clock = ~engine_clock;
// Generate AXI Stream reset (active low) for both AXI Lite and AXI interfaces
reg       engine_aresetn = 1'b0;
initial begin
    @(posedge engine_clock);
    @(posedge engine_clock);
    @(posedge engine_clock);
    engine_aresetn <= 1'b1;
end
//

reg  [S_AXI_LITE_ADDR_WIDTH-1:0]  write_address;
reg  [S_AXI_LITE_DATA_WIDTH-1:0]  write_data = {S_AXI_LITE_DATA_WIDTH{1'b0}};
reg                               start_write = 1'b0;
reg                               write_done = 1'b0;

reg  [S_AXI_LITE_ADDR_WIDTH-1:0]  read_address;
reg                               start_read = 1'b0;
reg                               read_done = 1'b0;

localparam DMA_TRANSACTIONS = 18;
localparam DMA_TRANS_LEN    = 56*8;
localparam RESPONSE_DROP  = {{(AXIS_DATA_WIDTH-2){1'b0}}, 2'b01};
localparam RESPONSE_CLEAN = {{(AXIS_DATA_WIDTH-2){1'b0}}, 2'b10};
reg        dma_enable = 1'b0;
//
// Axi-Stream MASTER interface: connected to the DMA Tx channel
wire [AXIS_DATA_WIDTH-1:0] m_axis_tdata;       //% Write data      
wire [3:0]                 m_axis_tkeep;       //% Keep octets - 1 bit for every 8 bits of valid data
wire                       m_axis_tlast;       //% Indicates the last transfer of data
wire                       m_axis_tready;      //% Read ready - master can accept the read data and response
wire                       m_axis_tvalid;      //% Read valid issued by master - data is valid
//
// Axi-Stream SLAVE interface: connected to the DMA Rx channel
wire [AXIS_DATA_WIDTH-1:0] s_axis_tdata;       //% Write data      
wire [3:0]                 s_axis_tkeep;       //% Keep octets - 1 bit for every 8 bits of valid data
wire                       s_axis_tlast;       //% Indicates the last transfer of data
reg                        s_axis_tready = 1'b1;      //% Read ready - master can accept the read data and response
wire                       s_axis_tvalid;      //% Read valid issued by master - data is valid
//
integer i = 0;

initial begin

    wait(AXI_ARESETN == 1'b1);
    $display("\n");
    $display("Packet inspection unit test bench");

    ////////////////////////////////////////////////////////////////////////////
    // Make a write the read test
    $display("Start write-then-read test");
    // write_address = {{(S_AXI_LITE_ADDR_WIDTH-3){1'b0}}, 4'h4};
    write_address = 32'h00000010;
    write_data    = 32'h00000801;
    @(posedge AXI_CLK);
    start_write = 1'b1;
    @(posedge write_done);
    start_write = 1'b0;
    $display("Write %x on address %x ", write_data, write_address);
    #200        

    // read_address = {{(S_AXI_LITE_ADDR_WIDTH-3){1'b0}}, 4'h4};
    read_address = 32'h00000010;
    @(posedge AXI_CLK);
    start_read  = 1'b1;
    @(posedge read_done);
    start_read  = 1'b0;
    $display("Read %x on address %x ", PIC_LITE_RDATA, read_address);

    if(PIC_LITE_RDATA != write_data) begin
        $display("Test failed");
        $stop;
    end
    else begin
        $display("Test pass!");
    end
    $display("\n");
    ////////////////////////////////////////////////////////////////////////////
    $stop();

    // Debug
    // for(i = 0; i < 5; i = i + 1) begin
            
    //     read_address = 32'h000000ec + i*4;
    //     @(posedge AXI_CLK);
    //     start_read = 1'b1;
    //     @(posedge read_done);
    //     start_read = 1'b0;

    //     $display("Debug read: address %x, value %x", read_address, PIC_LITE_RDATA);
    // end


    ////////////////////////////////////////////////////////////////////////////
    // Read engines number and maximum engine length
    read_address = { {(S_AXI_LITE_ADDR_WIDTH-4){1'b1}}, 4'hC};
    @(posedge AXI_CLK);
    start_read = 1'b1;
    @(posedge read_done);
    start_read = 1'b0;
    $display("Engines number: %d", PIC_LITE_RDATA[15:0]);
    $display("Max engine size: %d", PIC_LITE_RDATA[31:16]);
    $display("\n");
    ////////////////////////////////////////////////////////////////////////////
    $stop();
    
    
    ////////////////////////////////////////////////////////////////////////////
    // Configure engine 0 with string "where is Groot"
    $display("Configure engine 0 with string 'where is Groot'");
    write_address = {{(S_AXI_LITE_ADDR_WIDTH-12){1'b0}}, 12'h004};
    write_data    = "rehw";
    @(posedge AXI_CLK);
    start_write = 1'b1;
    @(posedge write_done);
    start_write = 1'b0;
    #200
        //
    write_address = {{(S_AXI_LITE_ADDR_WIDTH-12){1'b0}}, 12'h008};
    write_data    = "si e";
    @(posedge AXI_CLK);
    start_write = 1'b1;
    @(posedge write_done);
    start_write = 1'b0;
    #200
        //
    write_address = {{(S_AXI_LITE_ADDR_WIDTH-12){1'b0}}, 12'h00C};
    write_data    = "orG ";
    @(posedge AXI_CLK);
    start_write = 1'b1;
    @(posedge write_done);
    start_write = 1'b0;
    #200
        //
    write_address = {{(S_AXI_LITE_ADDR_WIDTH-12){1'b0}}, 12'h010};
    write_data    = "XXto";
    @(posedge AXI_CLK);
    start_write = 1'b1;
    @(posedge write_done);
    start_write = 1'b0;
    #200
    // Enable the engine
    write_address = {{(S_AXI_LITE_ADDR_WIDTH-12){1'b0}}, 12'h000};
    write_data    = { {24'h00000E}, // "where is Groot" has 14 characters
                      {8'h01}
                    };
    @(posedge AXI_CLK);
    start_write = 1'b1;
    @(posedge write_done);
    start_write = 1'b0;
    #200
    $display("Configure engine 0 done");
    ////////////////////////////////////////////////////////////////////////////
    
    ////////////////////////////////////////////////////////////////////////////
    // Configure engine 1 with string "ABCDABD"
    $display("Configure engine 1 with string bytes 'ABCDABD'");
    write_address = {{(S_AXI_LITE_ADDR_WIDTH-12){1'b0}}, 12'h104};
    // write_data    = 32'h0D0C0B0A;
    write_data    = "DCBA";
    @(posedge AXI_CLK);
    start_write = 1'b1;
    @(posedge write_done);
    start_write = 1'b0;
    #200
        //
    write_address = {{(S_AXI_LITE_ADDR_WIDTH-12){1'b0}}, 12'h108};
    // write_data    = 32'h110D0B0A;
    write_data    = "XDBA";
    @(posedge AXI_CLK);
    start_write = 1'b1;
    @(posedge write_done);
    start_write = 1'b0;
    #200
        //
    // Enable the engine
    write_address = {{(S_AXI_LITE_ADDR_WIDTH-12){1'b0}}, 12'h100};
    write_data    = { {24'h000007}, // "ABCDABD" has 7 characters
                      {8'h01}
                    };
    @(posedge AXI_CLK);
    start_write = 1'b1;
    @(posedge write_done);
    start_write = 1'b0;
    $display("Configure engine 1 done");
    ////////////////////////////////////////////////////////////////////////////
    

    // Wait for engine to receive all data
    #100;
    $display("\n");

    ////////////////////////////////////////////////////////////////////////////
    // Send DMA AXI Stream packets to the inspection unit
    $display("Send DMA AXI Stream packets to the inspection unit");
    dma_enable  = 1'b1;
    for(i = 0; i < DMA_TRANSACTIONS; i = i + 1) begin
        
        @(negedge m_axis_tlast);
        @(posedge s_axis_tlast);

        if(s_axis_tdata == RESPONSE_DROP) begin
            $display("Inspection unit response: DROP packet      index: %d", i);
        end
        else begin
            $display("Inspection unit response: packet CLEAN     index: %d", i);
        end
    end
    ////////////////////////////////////////////////////////////////////////////
    
end


////////////////////////////////////////////////////////////////////////////
// State machine to configure and access PIC
localparam [3:0] WAIT		       = 4'b0000;     // Wait for a new command
localparam [3:0] WRITE_TO_UNIT     = 4'b0001;     // In this state a dummy write is made to test the communication on AXI Lite

localparam [3:0] READ_FROM_UNIT    = 4'b0010;     // In this state a read of what was write into WRITE_TO_UNIT 
                                                    // is made to test the communication on AXI Lite
localparam [3:0] COM_ERR           = 4'b0011;     // Dummy write and then read failed

reg [3:0] pic_lite_state = WAIT;	//% Current state of the HDMI configuration state machine
////////////////////////////////////////////////////////////////////////////
    //
////////////////////////////////////////////////////////////////////////////
/*! \brief &nbsp; Test communication on AXI Lite with the PIC and then
 * executes commands.
 */
////////////////////////////////////////////////////////////////////////////
//
always@(posedge S_AXI_LITE_ACLK) begin
if (S_AXI_LITE_ARESETN == 1'b0) begin
    ////////////////////////////////////////////////////////////////////////////
    // reset condition

    pic_lite_state      <= #TCQ WAIT;
end
else begin

    case (pic_lite_state)

        WAIT: begin
        ////////////////////////////////////////////////////////////////////////////
        // Wait for a new command
            read_done       <= #TCQ 1'b0;
            write_done      <= #TCQ 1'b0;

            if(start_read) begin
                pic_lite_state  <= #TCQ READ_FROM_UNIT;
            end
            else if(start_write) begin
                pic_lite_state  <= #TCQ WRITE_TO_UNIT;
            end
            else begin
                pic_lite_state  <= #TCQ WAIT;
            end
            //
        end

        WRITE_TO_UNIT: begin
            ////////////////////////////////////////////////////////////////////////////
            // In this state a dummy write is made to test the communication on AXI Lite

            PIC_LITE_AWADDR 		<= #TCQ write_address;
            PIC_LITE_WDATA  		<= #TCQ write_data;         
            PIC_LITE_START_WRITE    <= #TCQ (PIC_LITE_WCOMPLETE) ? 1'b0 : 1'b1;		

            if(PIC_LITE_WCOMPLETE) begin

                write_done          <= #TCQ 1'b1;
                pic_lite_state      <= #TCQ WAIT;
            end
            else if(PIC_LITE_WRITE_RESP_ERROR) begin
                pic_lite_state      <= #TCQ COM_ERR;
            end
            else begin
                pic_lite_state      <= #TCQ WRITE_TO_UNIT;
            end
            //
        end

        READ_FROM_UNIT: begin
        ////////////////////////////////////////////////////////////////////////////
        // In this state a read of what was write into WRITE_TO_UNIT 
        // is made to test the communication on AXI Lite

            PIC_LITE_ARADDR 		<= #TCQ read_address;
            PIC_LITE_START_READ 	<= #TCQ (PIC_LITE_RCOMPLETE) ? 1'b0 : 1'b1;  
                
            if(PIC_LITE_RCOMPLETE) begin

                read_done           <= #TCQ 1'b1;
                pic_lite_state      <= #TCQ WAIT;
            end 
            else if(PIC_LITE_WRITE_RESP_ERROR) begin
                pic_lite_state     <= #TCQ COM_ERR;
            end
            else begin
                pic_lite_state     <= #TCQ READ_FROM_UNIT;
            end
        //
        end

        COM_ERR: begin
        ////////////////////////////////////////////////////////////////////////////
        // I Dummy write and then read failed
            pic_lite_state  <= #TCQ COM_ERR;
        end

        default : begin
            pic_lite_state  <= #TCQ WRITE_TO_UNIT;
        end

    endcase
    //
end
end 
////////////////////////////////////////////////////////////////////////////

// Top module of the Packet Inspection CORE
inspection_unit#(

    .DATA_WIDTH           (S_AXI_LITE_DATA_WIDTH),
    .ADDR_WIDTH           (S_AXI_LITE_ADDR_WIDTH),
    .TCQ                  (TCQ)
)PIC_inst(
    // AXI Lite interface used to configure the core
    .S_AXI_LITE_ACLK          (S_AXI_LITE_ACLK),
    .S_AXI_LITE_ARESETN       (S_AXI_LITE_ARESETN),

    .S_AXI_LITE_AWADDR        (S_AXI_LITE_AWADDR),   
    .S_AXI_LITE_AWVALID       (S_AXI_LITE_AWVALID),
    .S_AXI_LITE_AWREADY       (S_AXI_LITE_AWREADY),

    .S_AXI_LITE_WDATA         (S_AXI_LITE_WDATA),    
    .S_AXI_LITE_WSTRB         (S_AXI_LITE_WSTRB),
    .S_AXI_LITE_WVALID        (S_AXI_LITE_WVALID),
    .S_AXI_LITE_WREADY        (S_AXI_LITE_WREADY),

    .S_AXI_LITE_BRESP         (S_AXI_LITE_BRESP),
    .S_AXI_LITE_BVALID        (S_AXI_LITE_BVALID),
    .S_AXI_LITE_BREADY        (S_AXI_LITE_BREADY),
 
    .S_AXI_LITE_ARADDR        (S_AXI_LITE_ARADDR),
    .S_AXI_LITE_ARVALID       (S_AXI_LITE_ARVALID),
    .S_AXI_LITE_ARREADY       (S_AXI_LITE_ARREADY),

    .S_AXI_LITE_RDATA         (S_AXI_LITE_RDATA),
    .S_AXI_LITE_RVALID        (S_AXI_LITE_RVALID),
    .S_AXI_LITE_RREADY        (S_AXI_LITE_RREADY),
    .S_AXI_LITE_RRESP         (S_AXI_LITE_RRESP),

    .axis_aresetn   (axis_aresetn),
    .axis_clk       (axis_clk),

    // .engine_aresetn (engine_aresetn),
    // .engine_clock   (engine_clock),
    .engine_aresetn (axis_aresetn),
    .engine_clock   (axis_clk),

    .s_axis_tdata   (m_axis_tdata ),       //% Write data      
    .s_axis_tkeep   (m_axis_tkeep ),       //% Keep octets - 1 bit for every 8 bits of valid data
    .s_axis_tlast   (m_axis_tlast ),       //% Indicates the last transfer of data
    .s_axis_tready  (m_axis_tready),       //% Read ready - master can accept the read data and response
    .s_axis_tvalid  (m_axis_tvalid),       //% Read valid issued by master - data is valid

    .m_axis_tdata   (s_axis_tdata ),       //% Write data      
    .m_axis_tkeep   (s_axis_tkeep ),       //% Keep octets - 1 bit for every 8 bits of valid data
    .m_axis_tlast   (s_axis_tlast ),       //% Indicates the last transfer of data
    .m_axis_tready  (s_axis_tready),       //% Read ready - master can accept the read data and response
    .m_axis_tvalid  (s_axis_tvalid)        //% Read valid issued by master - data is valid

);

// Used to simulate DMA transfers
pu_requests#(

    .AXI_DATA_WIDTH       (S_AXI_LITE_DATA_WIDTH),
    .TRANSACTION_FILE     ("pu_trans.mem"),
    .TRANSACTIONS_NR      (DMA_TRANSACTIONS),
    .TRANSACTION_WIDTH    (DMA_TRANS_LEN),
    .TCQ                  (TCQ)
)DMA_inst(

    .axis_aresetn   (dma_enable),
    .axis_clk       (AXI_CLK),

    
    .m_axis_data_tdata   (m_axis_tdata ),
    .m_axis_data_tkeep   (m_axis_tkeep ),
    .m_axis_data_tlast   (m_axis_tlast ),
    .m_axis_data_tready  (m_axis_tready),
    .m_axis_data_tvalid  (m_axis_tvalid),

    .m_axis_sts_tready   (1'b1)
);


// AXI Lite master interface used to access Packet Inspection CORE
axi_lite_master_if #(
	.TCQ					( TCQ ),
	.C_M_AXI_ADDR_WIDTH		( S_AXI_LITE_ADDR_WIDTH ),
	.C_M_AXI_DATA_WIDTH		( S_AXI_LITE_DATA_WIDTH )
) PIC_LITE_MASTER_IF (
	
	.M_AXI_ACLK					( S_AXI_LITE_ACLK ),
	.M_AXI_ARESETN				( S_AXI_LITE_ARESETN ),
	
	.M_AXI_AWADDR				( S_AXI_LITE_AWADDR ),
	.M_AXI_AWVALID				( S_AXI_LITE_AWVALID ),
	.M_AXI_AWREADY				( S_AXI_LITE_AWREADY ),
	.M_AXI_WDATA				( S_AXI_LITE_WDATA ),
	.M_AXI_WSTRB				( S_AXI_LITE_WSTRB ),
	.M_AXI_WVALID				( S_AXI_LITE_WVALID ),
	.M_AXI_WREADY				( S_AXI_LITE_WREADY ),
	.M_AXI_BRESP				( S_AXI_LITE_BRESP ),
	.M_AXI_BVALID				( S_AXI_LITE_BVALID ),
	.M_AXI_BREADY				( S_AXI_LITE_BREADY ),
	
	.M_AXI_ARADDR				( S_AXI_LITE_ARADDR ),
	.M_AXI_ARVALID				( S_AXI_LITE_ARVALID ),
	.M_AXI_ARREADY				( S_AXI_LITE_ARREADY ),
	.M_AXI_RDATA				( S_AXI_LITE_RDATA ),
	.M_AXI_RRESP				( S_AXI_LITE_RRESP ),
	.M_AXI_RVALID				( S_AXI_LITE_RVALID ),
	.M_AXI_RREADY				( S_AXI_LITE_RREADY ),
	
	// User signals
	.USR_AWADDR				( PIC_LITE_AWADDR ),	
	.USR_WDATA				( PIC_LITE_WDATA ),	
	.USR_START_WRITE		( PIC_LITE_START_WRITE ),	
	.USR_WRITE_ERROR		( PIC_LITE_WRITE_RESP_ERROR ),	
	.USR_WCOMPLETE			( PIC_LITE_WCOMPLETE ),
	.USR_ARADDR				( PIC_LITE_ARADDR ),	
	.USR_RDATA				( PIC_LITE_RDATA ),	
	.USR_START_READ			( PIC_LITE_START_READ ),
	.USR_RCOMPLETE			( PIC_LITE_RCOMPLETE ),	
	.USR_READ_ERROR			( PIC_LITE_READ_RESP_ERROR )
);

endmodule
