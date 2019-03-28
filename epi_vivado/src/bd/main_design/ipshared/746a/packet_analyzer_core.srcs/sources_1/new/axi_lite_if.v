//-----------------------------------------------------------------------------
// Project      : General module
// File         : axi_lite_if.v
// Version      : 1.0
//
// Description  : AXI Lite Slave control interface.
//
//------------------------------------------------------------------------------


module axi_lite_if#(
                    parameter C_S_AXI_DATA_WIDTH                = 32,           // AXI data bus width
                    parameter C_S_AXI_ADDR_WIDTH                = 32,           // AXI address bus width
                    parameter C_S_SLV_ALWAYS_RDY                = 1,            // Slave is always ready by default
                    parameter TCQ                               = 1
                    )
                   (  
                    // System Signals
                    input   wire                                S_AXI_ACLK,     // AXI clock signal
                    input   wire                                S_AXI_ARESETN,  // AXI active low reset signal

                    // Slave Interface Write Address channel Ports
                    input   wire    [C_S_AXI_ADDR_WIDTH - 1:0]  S_AXI_AWADDR,   // Write address (issued by master, acceped by Slave)
                    input   wire                                S_AXI_AWVALID,  // Write address valid and control information
                    output  wire                                S_AXI_AWREADY,  // Write address ready issued by slave

                    // Slave Interface Write Data channel Ports
                    input   wire    [C_S_AXI_DATA_WIDTH - 1:0]  S_AXI_WDATA,    // Write data (issued by master, acceped by Slave)
                    input   wire    [C_S_AXI_DATA_WIDTH/8-1:0]  S_AXI_WSTRB,    // Write strobes - 1 bit for every 8 bits of valid data
                    input   wire                                S_AXI_WVALID,   // Write valid data and strobes
                    output  wire                                S_AXI_WREADY,   // Write ready - slave can accept write data 

                    // Slave Interface Write Response channel Ports
                    output  wire    [1:0]                       S_AXI_BRESP,    // Write response - indicates the status of write transaction
                    output  wire                                S_AXI_BVALID,   // Write response is valid
                    input   wire                                S_AXI_BREADY,   // Response ready - master can accept a write response

                    // Slave Interface Read Address channel Ports
                    input   wire    [C_S_AXI_ADDR_WIDTH - 1:0]  S_AXI_ARADDR,   // Read address (issued by master, acceped by Slave)
                    input   wire                                S_AXI_ARVALID,  // Read address valid and control information
                    output  wire                                S_AXI_ARREADY,  // Read address ready issued by slave

                    // Slave Interface Read Data channel Ports
                    output  wire    [C_S_AXI_DATA_WIDTH - 1:0]  S_AXI_RDATA,    // Read data (issued by slave)
                    output  wire                                S_AXI_RVALID,   // Read valid issued by slave - data is valid
                    input   wire                                S_AXI_RREADY,   // Read ready - master can accept the read data and response
                    output  wire    [1:0]                       S_AXI_RRESP,    // Read response - indicates the status of read transfer

                    // AXI Slave User signals
                  //output  reg     [C_S_AXI_ADDR_WIDTH - 1:C_S_AXI_DATA_WIDTH/32 + 1]
                  //output  reg     [C_S_AXI_ADDR_WIDTH - C_S_AXI_DATA_WIDTH/32 - 2:0] 
                  //                                            slv_araddr,     // Slave read address
                    output  reg    [C_S_AXI_ADDR_WIDTH - C_S_AXI_DATA_WIDTH/32 - 2:0] 
                                                                slv_araddr,     // Slave read address
                    input           [C_S_AXI_DATA_WIDTH - 1:0]  slv_rdata,      // Slave read data
                    output                                      slv_rden,       // Slave read enable

                  //output  reg     [C_S_AXI_ADDR_WIDTH - 1:C_S_AXI_DATA_WIDTH/32 + 1]
                    output  reg     [C_S_AXI_ADDR_WIDTH - C_S_AXI_DATA_WIDTH/32 - 2:0]
                                                                slv_awaddr,     // Slave write address
                    output          [C_S_AXI_DATA_WIDTH - 1:0]  slv_wdata,      // Slave write data     
                    output                                      slv_wren,       // Slave write enable    
                    output          [C_S_AXI_DATA_WIDTH/8-1:0]  slv_wstrb,      // Slave write strobe
                    input                                       slv_rdy,        // Slave read/write ready
                    input                                       slv_rdvalid     // Slave vadlid data on read bus
                    );



// Parameters for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
// ADDR_LSB is used for addressing 32/64 bit registers/memories
// ADDR_LSB = 2 for 32 bits (n downto 2)
// ADDR_LSB = 3 for 64 bits (n downto 3)



localparam SLV_ADDR_LSB  = (C_S_AXI_DATA_WIDTH/32) + 1;
localparam SLV_ADDR_MSB  = C_S_AXI_ADDR_WIDTH-1 ;
localparam SLV_ADDR_SIZE = C_S_AXI_ADDR_WIDTH - SLV_ADDR_LSB;



// AXI4 Lite internal signals
reg [ 1:0]                      axi_rresp=2'd0;                         // Read response
reg [ 1:0]                      axi_bresp=2'd0;                         // Write response
reg                             axi_awready=1'b0;                       // Write address acceptance
reg                             axi_wready=1'b0;                        // Write data acceptance
reg                             axi_bvalid=1'b0;                        // Write response valid
reg                             axi_rvalid=1'b0;                        // Read data valid
reg                             axi_arready=1'b0;                       // Read address acceptance
//reg [ADDR_MSB - 1:0]          axi_awaddr={ADDR_MSB{1'b0}};            // Write address
//reg [ADDR_MSB - 1:0]          axi_araddr={ADDR_MSB{1'b0}};            // Read address valid
//reg [C_S_AXI_DATA_WIDTH - 1:0]axi_rdata={C_S_AXI_DATA_WIDTH{1'b0}};   // Read data
//wire                          slv_reg_rden;   // Slave register read enable
//wire                          slv_reg_wren;   // Slave register write enable

wire                            axi_slv_rdy;

initial begin
    slv_araddr={SLV_ADDR_SIZE{1'b0}};  // Slave read address
    slv_awaddr={SLV_ADDR_SIZE{1'b0}};  // Slave write address
end



// I/O Connections assignments

//Write Address Ready (AWREADY)
assign #TCQ S_AXI_AWREADY = axi_awready;

// Write Data Ready(WREADY)
assign #TCQ S_AXI_WREADY = axi_wready;

// Write Response (BResp)and response valid (BVALID)
assign #TCQ S_AXI_BRESP  = axi_bresp;
assign #TCQ S_AXI_BVALID = axi_bvalid;

// Read Address Ready(AREADY)
assign #TCQ S_AXI_ARREADY = axi_arready;

// Read and Read Data (RDATA), Read Valid (RVALID) and Response (RRESP)
assign #TCQ S_AXI_RDATA  = slv_rdata;
assign #TCQ S_AXI_RVALID = axi_rvalid;
assign #TCQ S_AXI_RRESP  = axi_rresp;

// Slave data assigns
assign #TCQ slv_wdata = S_AXI_WDATA;
assign #TCQ slv_wstrb = S_AXI_WSTRB;

// Slave is ready to read/write data from AXI Lite
assign #TCQ axi_slv_rdy = C_S_SLV_ALWAYS_RDY ? 1'b1 : slv_rdy;


// Implement axi_awready generation
//
// axi_awready is asserted for one S_AXI_ACLK clock cycle 
// when both S_AXI_AWVALID and S_AXI_WVALID are asserted.
// axi_awready is de-asserted when reset is low.
//
always @(posedge S_AXI_ACLK)
begin
    if(!S_AXI_ARESETN) begin
        axi_awready <= #TCQ 1'b0;
    end
    else begin
        if(~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && axi_slv_rdy) begin
            // Slave is ready to accept write address when there is a valid write
            // address and write data on the write address and data bus.
            // This design expects no outstanding transactions.
            axi_awready <= #TCQ 1'b1;
        end
        else begin
            axi_awready <= #TCQ 1'b0;
        end
    end
end



// Implement slv_awaddr latching
//
// This process is used to latch the address when both
// S_AXI_AWVALID and S_AXI_WVALID are valid.
//
always @(posedge S_AXI_ACLK)
begin
    if(!S_AXI_ARESETN) begin
        slv_awaddr <= #TCQ {SLV_ADDR_SIZE{1'b0}};
    end
    else begin
        if(~axi_awready && S_AXI_AWVALID && S_AXI_WVALID) begin
            // Address latching
            slv_awaddr <= #TCQ S_AXI_AWADDR[SLV_ADDR_MSB:SLV_ADDR_LSB];
        end
    end
end



// Implement axi_wready generation
//
// axi_wready is asserted for one S_AXI_ACLK clock cycle 
// when both S_AXI_AWVALID and S_AXI_WVALID are asserted.
// axi_wready is de-asserted when reset is low.
//
always @(posedge S_AXI_ACLK)
begin
    if(!S_AXI_ARESETN) begin
        axi_wready <= #TCQ 1'b0;
    end
    else begin  
        if(~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && axi_slv_rdy) begin
            // Slave is ready to accept write data when there is a valid write 
            // address and write data on the write address and data bus.
            // This design expects no outstanding transactions.
            axi_wready <= #TCQ 1'b1;
        end
        else begin
            axi_wready <= #TCQ 1'b0;
        end
    end
end



// Implement write response logic generation
//
//  The write response and response valid signals are asserted by the slave
//  when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.
//  This marks the acceptance of address and indicates the status of
//  write transaction.
//
always @(posedge S_AXI_ACLK)
begin
    if(!S_AXI_ARESETN) begin
        axi_bvalid  <= #TCQ 1'b0;
        axi_bresp   <= #TCQ 2'd0;
    end
    else begin
        if(axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID) begin     
            // Indicates a valid write response is available
            axi_bvalid <= #TCQ 1'b1;
            axi_bresp  <= #TCQ 2'd0;    // 'OKAY' response
        end                             /* Work error responses in future??????? crs */
        else begin
            if(S_AXI_BREADY && axi_bvalid) begin
                // Check if bready is asserted while bvalid is high)
                //(There is a possibility that bready is always asserted high)
                axi_bvalid <= #TCQ 1'b0;
            end
        end
    end
end



// Implement axi_arready generation
//
// axi_arready is asserted for one S_AXI_ACLK clock cycle when
// S_AXI_ARVALID is asserted. axi_awready is
// de-asserted when reset (active low) is asserted.
// The read address is also latched when S_AXI_ARVALID is
// asserted. slv_araddr is reset to zero on reset assertion.
//
always @(posedge S_AXI_ACLK)
begin
    if(!S_AXI_ARESETN) begin
        axi_arready <= #TCQ 1'b0;
        slv_araddr  <= #TCQ {SLV_ADDR_SIZE{1'b0}};
    end
    else begin
        if(~axi_arready && S_AXI_ARVALID) begin
            // Indicates that the slave has acceped the valid read address
            axi_arready <= #TCQ 1'b1;
            slv_araddr  <= #TCQ S_AXI_ARADDR[SLV_ADDR_MSB:SLV_ADDR_LSB];
        end
        else begin
            axi_arready <= #TCQ 1'b0;
        end
    end
end

// assign #TCQ slv_araddr = S_AXI_ARVALID ? S_AXI_ARADDR[SLV_ADDR_MSB:SLV_ADDR_LSB] : {SLV_ADDR_SIZE{1'b0}};


// Implement memory mapped register select and read logic generation
//
// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both
// S_AXI_ARVALID and axi_arready are asserted. The slave registers
// data are available on the slv_rdata bus at this instance. The
// assertion of axi_rvalid marks the validity of read data on the
// bus and axi_rresp indicates the status of read transaction.axi_rvalid
// is deasserted on reset (active low). axi_rresp and slv_rdata are
// cleared to zero on reset (active low).
//
reg wait_slv_rdvalid = 1'b0;

always @(posedge S_AXI_ACLK)
begin
    if(!S_AXI_ARESETN) begin
        axi_rvalid          <= #TCQ 1'b0;
        axi_rresp           <= #TCQ 2'd0;
        wait_slv_rdvalid    <= #TCQ 1'b0;
    end
    else begin

        if(wait_slv_rdvalid) begin
            axi_rvalid       <= #TCQ slv_rdvalid;
            wait_slv_rdvalid <= #TCQ ~slv_rdvalid;
        end
        else if(axi_arready && S_AXI_ARVALID && ~axi_rvalid) begin   
            // Valid read data is available at the read data bus
            axi_rvalid       <= #TCQ slv_rdvalid;
            wait_slv_rdvalid <= #TCQ ~slv_rdvalid;
            axi_rresp        <= #TCQ 2'd0; // 'OKAY' response
        end
        else if(axi_rvalid && S_AXI_RREADY) begin
            // Read data is accepted by the master
            axi_rvalid <= #TCQ 1'b0;
        end
    end
end


// Slave register write enable is asserted when valid address and data are available
// and the slave is ready to accept the write address and write data.
//
assign #TCQ slv_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;


// Slave register read enable is asserted when valid address is available
// and the slave is ready to accept the read address.
//
assign #TCQ slv_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;



endmodule