//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/28/2017 10:55:23 AM
// Design Name: 
// Module Name: axi_lite_master_if
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi_lite_master_if#(
        parameter   TCQ  = 1'b1,
        ////////////////////////////////////////////////////////////////////////////
        // Width of M_AXI address bus. The master generates the read and write addresses
        // of width specified as C_M_AXI_ADDR_WIDTH.
        parameter   C_M_AXI_ADDR_WIDTH  = 32,        
        ////////////////////////////////////////////////////////////////////////////
        // Width of M_AXI data bus. The master issues write data and accept read data
        // where the width of the data bus is C_M_AXI_DATA_WIDTH
        parameter   C_M_AXI_DATA_WIDTH  = 32
    )(
        ////////////////////////////////////////////////////////////////////////////
        // System Signals
        input wire M_AXI_ACLK,
        input wire M_AXI_ARESETN,
        
        ////////////////////////////////////////////////////////////////////////////
        // Master Interface Write Address Channel ports
        // Write address (issued by master)
        output wire [C_M_AXI_ADDR_WIDTH-1:0] M_AXI_AWADDR,
        
        ////////////////////////////////////////////////////////////////////////////
        // Write channel Protection type. This signal indicates the
        // privilege and security level of the transaction, and whether
        // the transaction is a data access or an instruction access.
        output wire [2:0] M_AXI_AWPROT,
        
        ////////////////////////////////////////////////////////////////////////////
        //Write address valid. This signal indicates that the master signaling
        // valid write address and control information.
        output wire M_AXI_AWVALID,
        
        ////////////////////////////////////////////////////////////////////////////
        // Write address ready. This signal indicates that the slave is ready
        // to accept an address and associated control signals.
        input wire M_AXI_AWREADY,
        
        ////////////////////////////////////////////////////////////////////////////
        // Master Interface Write Data Channel ports
        
        ////////////////////////////////////////////////////////////////////////////
        // Write data (issued by master)
        output wire [C_M_AXI_DATA_WIDTH-1:0] M_AXI_WDATA,
        
        ////////////////////////////////////////////////////////////////////////////
        // Write strobes. This signal indicates which byte lanes hold
        // valid data. There is one write strobe bit for each eight
        // bits of the write data bus.
        output wire [C_M_AXI_DATA_WIDTH/8-1:0] M_AXI_WSTRB,
        
        ////////////////////////////////////////////////////////////////////////////
        //Write valid. This signal indicates that valid write
        // data and strobes are available.
        output wire M_AXI_WVALID,
        
        ////////////////////////////////////////////////////////////////////////////
        // Write ready. This signal indicates that the slave
        // can accept the write data.
        input wire M_AXI_WREADY,
        
        ////////////////////////////////////////////////////////////////////////////
        // Master Interface Write Response Channel ports
        
        ////////////////////////////////////////////////////////////////////////////
        // Write response. This signal indicates the status
        // of the write transaction.
        input wire [1:0] M_AXI_BRESP,
        
        ////////////////////////////////////////////////////////////////////////////
        // Write response valid. This signal indicates that the channel
        // is signaling a valid write response.
        input wire M_AXI_BVALID,
        
        ////////////////////////////////////////////////////////////////////////////
        // Response ready. This signal indicates that the master
        // can accept a write response.
        output wire M_AXI_BREADY,
        
        ////////////////////////////////////////////////////////////////////////////
        // Master Interface Read Address Channel ports
        
        ////////////////////////////////////////////////////////////////////////////
        // Read address (issued by master)
        output wire [C_M_AXI_ADDR_WIDTH-1:0] M_AXI_ARADDR,
        
        ////////////////////////////////////////////////////////////////////////////
        // Protection type. This signal indicates the privilege
        // and security level of the transaction, and whether the
        // transaction is a data access or an instruction access.
        output wire [2:0] M_AXI_ARPROT,
        
        ////////////////////////////////////////////////////////////////////////////
        // Read address valid. This signal indicates that the channel
        // is signaling valid read address and control information.
        output wire M_AXI_ARVALID,
        
        ////////////////////////////////////////////////////////////////////////////
        // Read address ready. This signal indicates that the slave is
        // ready to accept an address and associated control signals.
        input wire M_AXI_ARREADY,
        
        ////////////////////////////////////////////////////////////////////////////
        // Master Interface Read Data Channel ports
        
        ////////////////////////////////////////////////////////////////////////////
        // Read data (issued by slave)
        input wire [C_M_AXI_DATA_WIDTH-1:0]  M_AXI_RDATA,
        
        ////////////////////////////////////////////////////////////////////////////
        // Read response. This signal indicates the status of the
        // read transfer.
        input wire [1:0] M_AXI_RRESP,
        
        ////////////////////////////////////////////////////////////////////////////
        // Read valid. This signal indicates that the channel is
        // signaling the required read data.
        input wire M_AXI_RVALID,
        
        ////////////////////////////////////////////////////////////////////////////
        // Read ready. This signal indicates that the master can
        // accept the read data and response information.
        output wire M_AXI_RREADY,
        
        ////////////////////////////////////////////////////////////////////////////
        // write address
        input   wire [C_M_AXI_ADDR_WIDTH-1:0] USR_AWADDR,
        
        ////////////////////////////////////////////////////////////////////////////
        // write data
        input   wire [C_M_AXI_DATA_WIDTH-1:0] USR_WDATA,
        
        ////////////////////////////////////////////////////////////////////////////
        // read addresss
        input   wire [C_M_AXI_ADDR_WIDTH-1:0] USR_ARADDR,
                
        ////////////////////////////////////////////////////////////////////////////
        // Read data (interface output)
        output wire [C_M_AXI_DATA_WIDTH-1:0]  USR_RDATA,
        
        ////////////////////////////////////////////////////////////////////////////
        // Write can start: user signal
        input   wire USR_START_WRITE,
        
        ////////////////////////////////////////////////////////////////////////////
        // Read can start: user signal
        input   wire USR_START_READ,
        
        ////////////////////////////////////////////////////////////////////////////
        // Asserts when write transactions are complete
        output wire USR_WCOMPLETE,
		
        ////////////////////////////////////////////////////////////////////////////
        // Asserts when read transactions are complete
        output wire USR_RCOMPLETE,
		
        ////////////////////////////////////////////////////////////////////////////
        // Asserts when there is a write response error
        output      USR_WRITE_ERROR,
        
		////////////////////////////////////////////////////////////////////////////
        // Asserts when there is a read response error
        output      USR_READ_ERROR
		
		// (* X_INTERFACE_INFO = "topex.ro:interface:axi_lite_master_if:1.0 INTR INTERRUPT" *)		
);

////////////////////////////////////////////////////////////////////////////
// AXI4 Lite internal signals

////////////////////////////////////////////////////////////////////////////
// write address valid
reg axi_awvalid;
////////////////////////////////////////////////////////////////////////////
// write data valid
reg axi_wvalid;
////////////////////////////////////////////////////////////////////////////
// read address valid
reg axi_arvalid;
////////////////////////////////////////////////////////////////////////////
// read data acceptance
reg axi_rready;
////////////////////////////////////////////////////////////////////////////
// write response acceptance
reg axi_bready;

////////////////////////////////////////////////////////////////////////////
//Example-specific design signals
// All the following wire/reg are used in the current example.
// for demonstation.

////////////////////////////////////////////////////////////////////////////
// A pulse to initiate a write transaction
reg start_write;
////////////////////////////////////////////////////////////////////////////
// A pulse to initiate a read transaction
reg start_read;

////////////////////////////////////////////////////////////////////////////
// Asserts when a single beat write transaction is issued and
// remains asserted till the completion of write trasaction.
reg write_issued;

////////////////////////////////////////////////////////////////////////////
// Asserts when a single beat read transaction is issued and
// remains asserted till the completion of read trasaction.
reg read_issued;

////////////////////////////////////////////////////////////////////////////
// flag that marks the completion of write trasactions. The number of
// write transaction is user selected by the parameter C_TRANSACTIONS_NUM
(* mark_debug = "true" *) reg write_done;

////////////////////////////////////////////////////////////////////////////
// flag that marks the completion of read trasactions. The number of read
// transaction is user selected by the parameter C_TRANSACTIONS_NUM
(* mark_debug = "true" *) reg read_done;

////////////////////////////////////////////////////////////////////////////
// index counter to track the number of write transaction issued
reg [7:0] write_index;
////////////////////////////////////////////////////////////////////////////
// index counter to track the number of read transaction issued
reg [7:0] read_index;

////////////////////////////////////////////////////////////////////////////
// Flag marks the completion of comparison of the read
// data with the expected read data
(* mark_debug = "true" *) reg compare_done;

////////////////////////////////////////////////////////////////////////////
// This flag is asserted when there is a mismatch of
// the read data with the expected read data.
(* mark_debug = "true" *) reg read_mismatch;


assign #TCQ   USR_RDATA     = M_AXI_RDATA;
assign #TCQ   WRITE_BRESP   = M_AXI_BRESP;

////////////////////////////////////////////////////////////////////////////
 // Example State machine to initialize counter, initialize write transactions,
 // initialize read transactions and comparison of read data with the
 // written data words.
localparam      WRITE_IDLE  = 1'b0, // This state initializes the counter, ones
                                       // the counter reaches LP_START_COUNT count,
                                       // the state machine changes state to INIT_WRITE
                 READ_IDLE  = 1'b0, // This state initializes the counter, ones
                                      // the counter reaches LP_START_COUNT count,
                                      // the state machine changes state to INIT_WRITE
                 INIT_WRITE = 1'b1, // This state initializes write transaction,
                                       // once writes are done, the state machine
                                       // changes state to INIT_READ          
                 INIT_READ  = 1'b1; // This state initializes read transaction
                                       // once reads are done, the state machine
                                       // changes state to INIT_COMPARE

reg  mst_write_state,  mst_read_state;

////////////////////////////////////////////////////////////////////////////
// I/O Connections //

////////////////////////////////////////////////////////////////////////////
// Write Address (AW)

////////////////////////////////////////////////////////////////////////////
// Adding the offset address to the base addr of the slave
assign #TCQ  M_AXI_AWADDR  =  USR_AWADDR;
////////////////////////////////////////////////////////////////////////////
// AXI 4 write data
assign #TCQ  M_AXI_WDATA   = USR_WDATA;
assign #TCQ  M_AXI_AWPROT  = 3'h0;
assign #TCQ  M_AXI_AWVALID = axi_awvalid;

////////////////////////////////////////////////////////////////////////////
//Write Data(W)
assign #TCQ  M_AXI_WVALID = axi_wvalid;

////////////////////////////////////////////////////////////////////////////
//Set all byte strobes in this example
assign #TCQ  M_AXI_WSTRB  = {C_M_AXI_DATA_WIDTH/8{1'b1}};

////////////////////////////////////////////////////////////////////////////
//Write Response (B)
assign #TCQ  M_AXI_BREADY = axi_bready;

////////////////////////////////////////////////////////////////////////////
//Read Address (AR)
assign #TCQ  M_AXI_ARADDR   = USR_ARADDR;
assign #TCQ  M_AXI_ARVALID  = axi_arvalid;
assign #TCQ  M_AXI_ARPROT   = 3'h0;

////////////////////////////////////////////////////////////////////////////
//Read and Read Response (R)
assign #TCQ  M_AXI_RREADY = axi_rready;

////////////////////////////////////////////////////////////////////////////
//Example design I/O

assign #TCQ  USR_WCOMPLETE  = write_done;
assign #TCQ  USR_RCOMPLETE  = read_done;


////////////////////////////////////////////////////////////////////////////
//Write Address Channel
// The purpose of the write address channel is to request the address and
// command information for the entire transaction.  It is a single beat
// of information.
//
// Note for this example the axi_awvalid/axi_wvalid are asserted at the same
// time, and then each is deasserted independent from each other.
// This is a lower-performance, but simplier control scheme.
//
// AXI VALID signals must be held active until accepted by the partner.
//
// A data transfer is accepted by the slave when a master has
// VALID data and the slave acknoledges it is also READY. While the master
// is allowed to generated multiple, back-to-back requests by not
// deasserting VALID, this design will add rest cycle for
// simplicity.
//
// Since only one outstanding transaction is issued by the user design,
// there will not be a collision between a new request and an accepted
// request on the same clock cycle.

always @(posedge M_AXI_ACLK) begin
  ////////////////////////////////////////////////////////////////////////////
  //Only VALID signals must be deasserted during reset per AXI spec
  //Consider inverting then registering active-low reset for higher fmax
  if (M_AXI_ARESETN == 0 ) begin
    axi_awvalid <= #TCQ  1'b0;
  end else begin
    ////////////////////////////////////////////////////////////////////////////
    //Signal a new address/data command is available by user logic
    if (start_write) begin
      axi_awvalid <= #TCQ  1'b1;
    end else if (M_AXI_AWREADY && axi_awvalid) begin
    ////////////////////////////////////////////////////////////////////////////
    //Address accepted by interconnect/slave (issue of M_AXI_AWREADY by slave)
      axi_awvalid <= #TCQ  1'b0;
    end
  end
end


////////////////////////////////////////////////////////////////////////////
//Write Data Channel
//
// The write data channel is for transfering the actual data.
//
// The data generation is speific to the example design, and
// so only the WVALID/WREADY handshake is shown here
always @(posedge M_AXI_ACLK) begin
  if (M_AXI_ARESETN == 0 ) begin
    axi_wvalid <= #TCQ  1'b0;
  end else if (start_write) begin
    ////////////////////////////////////////////////////////////////////////////
    //Signal a new address/data command is available by user logic
    axi_wvalid <= #TCQ  1'b1;
  end else if (M_AXI_WREADY && axi_wvalid) begin
    ////////////////////////////////////////////////////////////////////////////
    //Data accepted by interconnect/slave (issue of M_AXI_WREADY by slave)
     axi_wvalid <= #TCQ  1'b0;
   end
end

////////////////////////////////////////////////////////////////////////////
//Write Response (B) Channel
//
// The write response channel provides feedback that the write has committed
// to memory. BREADY will occur after both the data and the write address
// has arrived and been accepted by the slave, and can guarantee that no
// other accesses launched afterwards will be able to be reordered before it.
//
// The BRESP bit [1] is used indicate any errors from the interconnect or
// slave for the entire write burst. This example will capture the error.
//
// While not necessary per spec, it is advisable to reset READY signals in
// case of differing reset latencies between master/slave.
always @(posedge M_AXI_ACLK) begin
  if (M_AXI_ARESETN == 0 ) begin
    axi_bready <= #TCQ  1'b0;
  end else if (M_AXI_BVALID && ~axi_bready) begin
  ////////////////////////////////////////////////////////////////////////////
  // accept/acknowledge bresp with axi_bready by the master
  // when M_AXI_BVALID is asserted by slave
    axi_bready <= #TCQ  1'b1;
  end else if (axi_bready) begin
    ////////////////////////////////////////////////////////////////////////////
    // deassert after one clock cycle
    axi_bready <= #TCQ  1'b0;
  end else begin
    ////////////////////////////////////////////////////////////////////////////
    // retain the previous value
    axi_bready <= #TCQ  axi_bready;
  end
end

////////////////////////////////////////////////////////////////////////////
//Flag write errors
assign #TCQ  USR_WRITE_ERROR = (axi_bready & M_AXI_BVALID & M_AXI_BRESP[1]);

////////////////////////////////////////////////////////////////////////////
// A new axi_arvalid is asserted when there is a valid read address
// available by the master. start_read triggers a new read
// transaction
always @(posedge M_AXI_ACLK) begin
  if (M_AXI_ARESETN == 0 ) begin
    axi_arvalid <= #TCQ  1'b0;
  end else if (start_read) begin
  ////////////////////////////////////////////////////////////////////////////
  //Signal a new read address command is available by user logic
    axi_arvalid <= #TCQ  1'b1;
  end else if (M_AXI_ARREADY && axi_arvalid) begin
  ////////////////////////////////////////////////////////////////////////////
  //RAddress accepted by interconnect/slave (issue of M_AXI_ARREADY by slave)
    axi_arvalid <= #TCQ  1'b0;
  end
end

////////////////////////////////////////////////////////////////////////////
//Read Data (and Response) Channel
//
// The Read Data channel returns the results of the read request
// The master will accept the read data by asserting axi_rready
// when there is a valid read data available.
// While not necessary per spec, it is advisable to reset READY signals in
// case of differing reset latencies between master/slave.
always @(posedge M_AXI_ACLK) begin
  if (M_AXI_ARESETN == 0 ) begin
    axi_rready <= #TCQ  1'b0;
  end else if (M_AXI_RVALID && ~axi_rready) begin
  ////////////////////////////////////////////////////////////////////////////
  // accept/acknowledge rdata/rresp with axi_rready by the master
  // when M_AXI_RVALID is asserted by slave
    axi_rready <= #TCQ  1'b1;
  end else if (axi_rready) begin
  ////////////////////////////////////////////////////////////////////////////
  // deassert after one clock cycle
    axi_rready <= #TCQ  1'b0;
  end
end

////////////////////////////////////////////////////////////////////////////
//Flag write errors
assign #TCQ  USR_READ_ERROR = (axi_rready & M_AXI_RVALID & M_AXI_RRESP[1]);


////////////////////////////////////////////////////////////////////////////
//implement master command interface state machine for write process
always @ ( posedge M_AXI_ACLK) begin
  if (M_AXI_ARESETN == 1'b0 ) begin
    ////////////////////////////////////////////////////////////////////////////
    // reset condition
    // All the signals are assigned default values under reset condition
    mst_write_state <= #TCQ  WRITE_IDLE;
    start_write     <= #TCQ  1'b0;
    write_issued    <= #TCQ  1'b0;
  end else begin
  ////////////////////////////////////////////////////////////////////////////
  // state transition
    case (mst_write_state)
      WRITE_IDLE: begin
        ////////////////////////////////////////////////////////////////////////////
        // This state is responsible to wait for user defined LP_START_COUNT
        // number of clock cycles.
          if ( USR_START_WRITE ) begin
            mst_write_state  <= #TCQ  INIT_WRITE;
          end else begin
            mst_write_state  <= #TCQ  WRITE_IDLE;
          end
        end

      INIT_WRITE: begin
        ////////////////////////////////////////////////////////////////////////////
        // This state is responsible to issue start_write pulse to
        // initiate a write transaction. Write transactions will be.
        // write controller
        if (write_done) begin
          mst_write_state <= #TCQ  WRITE_IDLE;
        end else begin
          mst_write_state  <= #TCQ  INIT_WRITE;

          if (~axi_awvalid && ~axi_wvalid && ~M_AXI_BVALID && ~start_write && ~write_issued) begin
            start_write     <= #TCQ  1'b1;
            write_issued    <= #TCQ  1'b1;
          end else if (axi_bready) begin
            write_issued    <= #TCQ  1'b0;
          end else begin
            start_write     <= #TCQ  1'b0; //Negate to generate a pulse
          end
        end
      end
//      default : begin
//        mst_write_state   <= #TCQ  WRITE_IDLE;
//      end
    endcase
  end
end //MASTER_EXECUTION_PROC



////////////////////////////////////////////////////////////////////////////
//implement master command interface state machine for read process
always @ ( posedge M_AXI_ACLK) begin
  if (M_AXI_ARESETN == 1'b0 ) begin
    ////////////////////////////////////////////////////////////////////////////
    // reset condition
    // All the signals are assigned default values under reset condition
    mst_read_state  <= #TCQ  READ_IDLE;
    start_read      <= #TCQ  1'b0;
    read_issued     <= #TCQ  1'b0;
  end else begin
  ////////////////////////////////////////////////////////////////////////////
  // state transition
    case (mst_read_state)
      READ_IDLE: begin
        ////////////////////////////////////////////////////////////////////////////
        // This state is responsible to wait for user defined LP_START_COUNT
        // number of clock cycles.
          if ( USR_START_READ ) begin
            mst_read_state  <= #TCQ  INIT_READ;
          end else begin
            mst_read_state  <= #TCQ  READ_IDLE;
          end
        end

      INIT_READ: begin
        ////////////////////////////////////////////////////////////////////////////
        // This state is responsible to issue start_read pulse to
        // initiate a read transaction.
        // read controller
        if (read_done) begin
          mst_read_state <= #TCQ  READ_IDLE;
        end else begin
          mst_read_state <= #TCQ  INIT_READ;
        
          if (~axi_arvalid && ~M_AXI_RVALID && ~start_read && ~read_issued) begin
            start_read      <= #TCQ  1'b1;
            read_issued     <= #TCQ  1'b1;
          end else if (axi_rready) begin
            read_issued     <= #TCQ  1'b0;
          end else begin
            start_read      <= #TCQ  1'b0; //Negate to generate a pulse
          end
        end
      end
//      default : begin
//        mst_read_state  <= #TCQ  READ_IDLE;
//      end
    endcase
  end
end //MASTER_EXECUTION_PROC

////////////////////////////////////////////////////////////////////////////
//  Check for write completion.
//
//  This demonstrates how to confirm that a write has been
//  committed.

always @(posedge M_AXI_ACLK) begin
  if (M_AXI_ARESETN == 0) begin
    write_done <= #TCQ  1'b0;
  end else if (M_AXI_BVALID && axi_bready) begin
    //The write_done should be associated with a bready response
    write_done <= #TCQ  1'b1;
  end else begin
    write_done <= #TCQ  1'b0;
  end
end


////////////////////////////////////////////////////////////////////////////
// Check for read completion.
//
// This logic is to qualify the last read count with the final read
// response/data.
always @(posedge M_AXI_ACLK) begin
  if (M_AXI_ARESETN == 0) begin
    read_done <= #TCQ  1'b0;
  end else if (M_AXI_RVALID && axi_rready) begin
    ////////////////////////////////////////////////////////////////////////////
    //The read_done should be associated with a read ready response
    read_done <= #TCQ  1'b1;
  end else begin
    read_done <= #TCQ  1'b0;
  end
end
    
    
endmodule























