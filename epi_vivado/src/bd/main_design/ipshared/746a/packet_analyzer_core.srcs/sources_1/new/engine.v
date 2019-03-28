`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Andrei Nicolae Georgian 
// 
// Create Date: 07/09/2018 19:32:11 PM
// Design Name: Ethernet Packet Inspection
// Module Name: engine
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

/*! 
 * \brief &nbsp; The algorith use for string mathching is Knuth–Morris–Pratt.
 *
 *  &nbsp;
 */
module engine#(
    parameter ADDR_SIZE           = 8,      // Write/read address bus width
    parameter TCQ                 = 1
)(

    input wire    CLOCK,
    input wire    RESETN,

    // Bus to access the RAM
    input   wire [7:0]              WDATA,
    input   wire [ADDR_SIZE-1: 0]   WADDR,
    input   wire                    WEN,
    output  wire [7:0]              RDATA,
    input   wire [ADDR_SIZE-1:0]    RADDR,
    input   wire                    REN,


    // Axi-Stream MASTER interface: connected to the AXI Ethernet STATUS interface
    input   wire [7:0]            s_axis_tdata,       //% Write data      
    input   wire                  s_axis_tvalid,      //% Read ready - master can accept the read data and response
    input   wire                  transfer_active,       //% Indicates the last transfer of data
 
    output  reg                   PATTERN_FOUNDED = 1'b0    // Indicate that the engine has founded a match
);

localparam DATA_SIZE           = 8;      // Write/read data bus width
    
// Memory size in bits
localparam MEMORY_SIZE       = (2**ADDR_SIZE) * DATA_SIZE;
localparam MAX_PATTERN_LEN   = (2**ADDR_SIZE) - 4; // 4 bytes are used for configuration
localparam START_ADDRESS     = {{(ADDR_SIZE-3){1'b0}}, 3'h4}; // Because 4 bytes are used for control, start address is not 0
localparam ADDRESS_INCREMENT = {{(ADDR_SIZE-1){1'b0}}, 1'b1};

// Address use to access the RAM in order to find the 
// pattern in the s_axis_* stream transfer
reg  [ADDR_SIZE-1: 0] ram_addra = {ADDR_SIZE{1'b0}};

// The RAM address bus is used to READ/WRITE operation
// for configuration and also in string match algorithm.
// From this reason when WEN or REN are active then RAM
// nets are routed accordingly
wire [ADDR_SIZE-1: 0] _ram_addra;
wire [DATA_SIZE-1: 0] _ram_dina;
wire [DATA_SIZE-1: 0] _ram_douta;
wire                  _ram_wea;
//
// Port used in string match algorithm
reg  [ADDR_SIZE-1: 0] _ram_addrb = {ADDR_SIZE{1'b0}};
wire [DATA_SIZE-1: 0] _ram_doutb;


/*! 
 * Configuration register.
 *      bit 0        :     R/W - Enable. Must be 1'b1 to enable the engine
 *      bit 1        :     R - Correct lenth: if the bits [23:8] are not greater than MAX_PATTERN_LEN then this bit is 1'b1
 *      bits[7:2]    :     Reserved
 *      bits[23:8]   :     R/W - Search pattern lenght in bytes. Can not be greater than MAX_PATTERN_LEN
 *      bits[31:24]  :     Reserved
 */
reg [DATA_SIZE*4-1:0] config_reg = {(DATA_SIZE*4){1'b0}};

localparam config_regb0_addr   = {{(ADDR_SIZE-2){1'b0}}, 2'b00};
localparam config_regb1_addr   = {{(ADDR_SIZE-2){1'b0}}, 2'b01};
localparam config_regb2_addr   = {{(ADDR_SIZE-2){1'b0}}, 2'b10};
localparam config_regb3_addr   = {{(ADDR_SIZE-2){1'b0}}, 2'b11};
localparam start_val_addr      = {{(ADDR_SIZE-3){1'b0}}, 3'b100};

// Assign the RAM access bus based on config_area
assign #TCQ _ram_addra = WEN ? WADDR : REN ? RADDR : ram_addra;
assign #TCQ _ram_dina  = WEN ? WDATA : ram_addra;
assign #TCQ _ram_wea   = WEN;


wire [16:0] pattern_lenght;  // Bits [23:0] of config_reg
assign #TCQ pattern_lenght = config_reg[23:8];
//
wire        engine_enabled;  // Bit 1 of config_reg
assign #TCQ engine_enabled = config_reg[0];

// Assign the RDATA bus
assign #TCQ RDATA   = (RADDR == 8'h01) ? config_reg[7:0]   :
                      (RADDR == 8'h02) ? config_reg[15:8]  :
                      (RADDR == 8'h03) ? config_reg[23:16] :
                      _ram_douta;

reg                   src_in_progress = 1'b0;
reg  [DATA_SIZE-1:0]  start_value = {DATA_SIZE{1'b0}};   // the first value in pattern
reg  [DATA_SIZE-1:0]  back_value  = {DATA_SIZE{1'b0}};   // when is found a mismatch this is the compared prefix

////////////////////////////////////////////////////////////////////////////
localparam [2:0]	SEARCH_PATTERN  = 3'b000;
localparam [2:0]	WAIT_FIN      = 3'b001;
//
reg [2:0] sm_state = SEARCH_PATTERN; 
////////////////////////////////////////////////////////////////////////////
/*! \brief &nbsp; This state machine implements the string mathching algorithm.
 */
////////////////////////////////////////////////////////////////////////////
always@(posedge CLOCK) begin
if(RESETN == 1'b0) begin
    
    src_in_progress     <= #TCQ 1'b0;

    back_value          <= #TCQ start_value;
    _ram_addrb          <= #TCQ START_ADDRESS + ADDRESS_INCREMENT;
    ram_addra           <= #TCQ START_ADDRESS;

    sm_state            <= #TCQ SEARCH_PATTERN;
    //
end
else begin

    case(sm_state)

        SEARCH_PATTERN: begin
            
            PATTERN_FOUNDED <= #TCQ 1'b0;
            src_in_progress <= #TCQ ~transfer_active ? 1'b0 : src_in_progress;

            // Check if the engine is enabled
            if(~engine_enabled & s_axis_tvalid) begin

                 sm_state        <= #TCQ WAIT_FIN;
            end
            else if(ram_addra == pattern_lenght & src_in_progress) begin
                
                // pattern was founded
                sm_state        <= #TCQ transfer_active ? WAIT_FIN : SEARCH_PATTERN;
                PATTERN_FOUNDED <= #TCQ 1'b1;
                src_in_progress <= #TCQ 1'b0;
            end if(s_axis_tvalid) begin

                // Search is over on s_axis_tlast signal
                src_in_progress    <= #TCQ 1'b1;

                // Check for match
                if(s_axis_tdata == _ram_douta) begin

                    ram_addra  <= #TCQ ram_addra + ADDRESS_INCREMENT;                    
                end
                else if(s_axis_tdata == back_value) begin

                    ram_addra  <= #TCQ _ram_addrb;
                end
                else if(s_axis_tdata == start_value) begin

                    ram_addra  <= #TCQ START_ADDRESS + ADDRESS_INCREMENT;
                end
                else begin

                    ram_addra  <= #TCQ START_ADDRESS;
                end

                // Update back value
                if( (_ram_douta == back_value)      & 
                    (s_axis_tdata == _ram_douta)    &
                    (_ram_addra != START_ADDRESS)
                ) begin

                    back_value    <= #TCQ _ram_doutb;
                    _ram_addrb    <= #TCQ _ram_addrb + ADDRESS_INCREMENT;
                end
                else begin

                    back_value    <= #TCQ start_value;
                    _ram_addrb    <= #TCQ START_ADDRESS + ADDRESS_INCREMENT;
                end
                //
            end
            else if(~src_in_progress) begin

                ram_addra     <= #TCQ START_ADDRESS;
                back_value    <= #TCQ start_value;
                _ram_addrb    <= #TCQ START_ADDRESS + ADDRESS_INCREMENT;
            end
            //
        end

        WAIT_FIN: begin
            
            src_in_progress <= #TCQ 1'b0;

            if(transfer_active) begin
                sm_state    <= #TCQ WAIT_FIN;                
            end
            else begin
                sm_state    <= #TCQ SEARCH_PATTERN;
            end
        end

        default: begin
            sm_state    <= #TCQ SEARCH_PATTERN;
        end

    endcase
    //
end // RESET 
end // ALWAYS
////////////////////////////////////////////////////////////////////////////

reg pattern_lenght_changed = 1'b0;

////////////////////////////////////////////////////////////////////////////
/*! \brief &nbsp; This process monitors the transfer bus to RAM in order to
 * set the configuration 4 bytes register.
 *
 *  &nbsp; The first 4 bytes region in RAM is for configuration. To have more 
 * efficient access to this register the bus is monitorized and if the WADDR
 * is 0x0, 0x1, 0x2 or 0x3 then config_reg will be set.
 *
 *  &nbsp; The bit 0 of config_reg is engine enable bit. But any transaction
 * to the RAM using REN or WEN events it will set the enable bit to LOW. This
 * is done because there is a single access bus to RAM and if there is a string 
 * search in progress and REN or WEN events apear then the search is not valid!
 */
////////////////////////////////////////////////////////////////////////////
always@(posedge CLOCK) begin
if(RESETN == 1'b0) begin
    
    config_reg              <= #TCQ {(DATA_SIZE*4-1){1'b0}};
    pattern_lenght_changed  <= #TCQ 1'b0;
    //
end
else begin

    if(WEN) begin

        case(WADDR)
            config_regb0_addr: config_reg[7:0]    <= #TCQ WDATA;
            config_regb1_addr: begin
                config_reg[15:8]        <= #TCQ WDATA;
                pattern_lenght_changed  <= #TCQ 1'b1;
            end
            config_regb2_addr: begin
                config_reg[23:16]       <= #TCQ WDATA;
                pattern_lenght_changed  <= #TCQ 1'b1;
            end
            config_regb3_addr: config_reg[31:24]  <= #TCQ WDATA;
            start_val_addr   : start_value        <= #TCQ WDATA;
            default:           config_reg[0]      <= #TCQ 1'b0;      // Disable the engine
        endcase
        //
    end
    else begin

        // Check if pattern length is not greater than MAX_PATTERN_LEN
        if(pattern_lenght > MAX_PATTERN_LEN) begin

            config_reg[1]   <= #TCQ 1'b0;    // Invalidate pattern length OK bit
            config_reg[0]   <= #TCQ 1'b0;    // Disable engine
        end
        else if(pattern_lenght_changed) begin
            config_reg[23:8]        <= #TCQ config_reg[23:8] + 16'h0004;
            pattern_lenght_changed  <= #TCQ 1'b0;
        end
    end
    //
end // RESET 
end // ALWAYS
////////////////////////////////////////////////////////////////////////////

xpm_memory_tdpram # (

  // Common module parameters
  .MEMORY_SIZE        (MEMORY_SIZE),         //positive integer    (in bits)
  .MEMORY_PRIMITIVE   ("auto"),              //string; "auto", "distributed", "block" or "ultra";
  .CLOCKING_MODE      ("common_clock"),      //string; "common_clock", "independent_clock" 
  .MEMORY_INIT_FILE   ("none"),              //string; "none" or "<filename>.mem"
  .MEMORY_INIT_PARAM  (""    ),          //string;
  .USE_MEM_INIT       (1),               //integer; 0,1
  .WAKEUP_TIME        ("disable_sleep"), //string; "disable_sleep" or "use_sleep_pin" 
  .MESSAGE_CONTROL    (0),               //integer; 0,1
  .ECC_MODE           ("no_ecc"),        //string; "no_ecc", "encode_only", "decode_only" or "both_encode_and_decode" 
  .AUTO_SLEEP_TIME    (0),               //Do not Change

  // Port A module parameters
  .WRITE_DATA_WIDTH_A (DATA_SIZE),              //positive integer
  .READ_DATA_WIDTH_A  (DATA_SIZE),              //positive integer
  .BYTE_WRITE_WIDTH_A (DATA_SIZE),              //integer; 8, 9, or WRITE_DATA_WIDTH_A value
  .ADDR_WIDTH_A       (ADDR_SIZE),              //positive integer
  .READ_RESET_VALUE_A ("0"),             //string
  .READ_LATENCY_A     (1),               //non-negative integer
  .WRITE_MODE_A       ("read_first"),    //string; "write_first", "read_first", "no_change" 

  // Port B module parameters
  .WRITE_DATA_WIDTH_B (DATA_SIZE),              //positive integer
  .READ_DATA_WIDTH_B  (DATA_SIZE),              //positive integer
  .BYTE_WRITE_WIDTH_B (DATA_SIZE),              //integer; 8, 9, or WRITE_DATA_WIDTH_B value
  .ADDR_WIDTH_B       (ADDR_SIZE),              //positive integer
  .READ_RESET_VALUE_B ("0"),             //vector of READ_DATA_WIDTH_B bits
  .READ_LATENCY_B     (1),               //non-negative integer
  .WRITE_MODE_B       ("read_first")     //string; "write_first", "read_first", "no_change" 

) xpm_memory_tdpram_inst (

  // Common module ports
  .sleep          (1'b0),

  // Port A module ports
  .clka           (CLOCK),
  .rsta           (1'b0),
  .ena            (1'b1),
  .regcea         (1'b1),
  .wea            (_ram_wea),
  .addra          (_ram_addra),
  .dina           (_ram_dina),
  .injectsbiterra (1'b0),
  .injectdbiterra (1'b0),
  .douta          (_ram_douta),
  .sbiterra       (),
  .dbiterra       (),

  // Port B module ports
  .clkb           (CLOCK),
  .rstb           (1'b0),
  .enb            (1'b1),
  .regceb         (1'b1),
  .web            (1'b0), // there are no writes from port B
  .addrb          (_ram_addrb),
  .dinb           ({DATA_SIZE{1'b0}}), // there are no writes from port B
  .injectsbiterrb (1'b0),
  .injectdbiterrb (1'b0),
  .doutb          (_ram_doutb),
  .sbiterrb       (),
  .dbiterrb       ()

);

// xpm_memory_spram #(
//     .ADDR_WIDTH_A       (ADDR_SIZE),              // DECIMAL
//     .AUTO_SLEEP_TIME    (0),           // DECIMAL
//     .BYTE_WRITE_WIDTH_A (DATA_SIZE),       // DECIMAL
//     .ECC_MODE           ("no_ecc"),           // String
//     .MEMORY_INIT_FILE   ("none"),     // String
//     .MEMORY_INIT_PARAM  ("0"),       // String
//     .MEMORY_OPTIMIZATION("true"),  // String
//     .MEMORY_PRIMITIVE   ("auto"),     // String
//     .MEMORY_SIZE        (MEMORY_SIZE),            // DECIMAL
//     .MESSAGE_CONTROL    (0),           // DECIMAL
//     .READ_DATA_WIDTH_A  (DATA_SIZE),        // DECIMAL
//     .READ_LATENCY_A     (1),            // DECIMAL
//     .READ_RESET_VALUE_A ("0"),      // String
//     .USE_MEM_INIT       (1),              // DECIMAL
//     .WAKEUP_TIME        ("disable_sleep"), // String
//     .WRITE_DATA_WIDTH_A (DATA_SIZE),       // DECIMAL
//     .WRITE_MODE_A       ("read_first")    // String
// )
// xpm_memory_spram_inst (
//     .dbiterra(),             // 1-bit output: Status signal to indicate double bit error occurrence
//                                     // on the data output of port A.

//     .douta  (_ram_douta),                   // READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
//     .sbiterra(),             // 1-bit output: Status signal to indicate single bit error occurrence
//                                     // on the data output of port A.

//     .addra  (_ram_addra),                   // ADDR_WIDTH_A-bit input: Address for port A write and read operations.
//     .clka   (CLOCK),                     // 1-bit input: Clock signal for port A.
//     .dina   (_ram_dina),                     // WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
//     .ena    (1'b1),                       // 1-bit input: Memory enable signal for port A. Must be high on clock
//                                     // cycles when read or write operations are initiated. Pipelined
//                                     // internally.

//     .injectdbiterra(1'b0), // 1-bit input: Controls double bit error injection on input data when
//                                     // ECC enabled (Error injection capability is not available in
//                                     // "decode_only" mode).

//     .injectsbiterra(1'b0), // 1-bit input: Controls single bit error injection on input data when
//                                     // ECC enabled (Error injection capability is not available in
//                                     // "decode_only" mode).

//     .regcea(1'b1),                 // 1-bit input: Clock Enable for the last register stage on the output
//                                     // data path.

//     .rsta(~RESETN),                     // 1-bit input: Reset signal for the final port A output register stage.
//                                     // Synchronously resets output port douta to the value specified by
//                                     // parameter READ_RESET_VALUE_A.

//     .sleep  (1'b0),                   // 1-bit input: sleep signal to enable the dynamic power saving feature.
//     .wea    (_ram_wea)                       // WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input
//                                     // data port dina. 1 bit wide when word-wide writes are used. In
//                                     // byte-wide write configurations, each bit controls the writing one
//                                     // byte of dina to address addra. For example, to synchronously write
//                                     // only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be
//                                     // 4'b0010.

// );

endmodule