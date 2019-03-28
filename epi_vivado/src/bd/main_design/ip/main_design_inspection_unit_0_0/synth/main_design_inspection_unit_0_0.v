// (c) Copyright 1995-2019 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:user:inspection_unit:1.0
// IP Revision: 17

(* X_CORE_INFO = "inspection_unit,Vivado 2018.2" *)
(* CHECK_LICENSE_TYPE = "main_design_inspection_unit_0_0,inspection_unit,{}" *)
(* CORE_GENERATION_INFO = "main_design_inspection_unit_0_0,inspection_unit,{x_ipProduct=Vivado 2018.2,x_ipVendor=xilinx.com,x_ipLibrary=user,x_ipName=inspection_unit,x_ipVersion=1.0,x_ipCoreRevision=17,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,TCQ=1,DATA_WIDTH=32,ADDR_WIDTH=16,MAX_PACKET_LENGTH=2048,ENGINES_NUMBER=16,ENGINE_MAX_SIZE=256}" *)
(* IP_DEFINITION_SOURCE = "package_project" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module main_design_inspection_unit_0_0 (
  S_AXI_LITE_ARESETN,
  S_AXI_LITE_ACLK,
  S_AXI_LITE_AWADDR,
  S_AXI_LITE_AWVALID,
  S_AXI_LITE_AWREADY,
  S_AXI_LITE_WDATA,
  S_AXI_LITE_WSTRB,
  S_AXI_LITE_WVALID,
  S_AXI_LITE_WREADY,
  S_AXI_LITE_BRESP,
  S_AXI_LITE_BVALID,
  S_AXI_LITE_BREADY,
  S_AXI_LITE_ARADDR,
  S_AXI_LITE_ARVALID,
  S_AXI_LITE_ARREADY,
  S_AXI_LITE_RDATA,
  S_AXI_LITE_RVALID,
  S_AXI_LITE_RREADY,
  S_AXI_LITE_RRESP,
  axis_aresetn,
  axis_clk,
  m_axis_tdata,
  m_axis_tkeep,
  m_axis_tlast,
  m_axis_tready,
  m_axis_tvalid,
  s_axis_tdata,
  s_axis_tkeep,
  s_axis_tlast,
  s_axis_tready,
  s_axis_tvalid,
  engine_aresetn,
  engine_clock,
  debug_tdata,
  debug_tlast,
  debug_tready,
  debug_tvalid,
  debug_data,
  debug_search_ready,
  debug_engine_match,
  debug_start_search,
  debug_state
);

(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI_LITE_ARESETN, POLARITY ACTIVE_LOW" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 S_AXI_LITE_ARESETN RST" *)
input wire S_AXI_LITE_ARESETN;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI_LITE_ACLK, ASSOCIATED_BUSIF S_AXI_LITE, ASSOCIATED_RESET S_AXI_LITE_ARESETN, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN main_design_processing_system7_0_0_FCLK_CLK0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 S_AXI_LITE_ACLK CLK" *)
input wire S_AXI_LITE_ACLK;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE AWADDR" *)
input wire [15 : 0] S_AXI_LITE_AWADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE AWVALID" *)
input wire S_AXI_LITE_AWVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE AWREADY" *)
output wire S_AXI_LITE_AWREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE WDATA" *)
input wire [31 : 0] S_AXI_LITE_WDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE WSTRB" *)
input wire [3 : 0] S_AXI_LITE_WSTRB;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE WVALID" *)
input wire S_AXI_LITE_WVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE WREADY" *)
output wire S_AXI_LITE_WREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE BRESP" *)
output wire [1 : 0] S_AXI_LITE_BRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE BVALID" *)
output wire S_AXI_LITE_BVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE BREADY" *)
input wire S_AXI_LITE_BREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE ARADDR" *)
input wire [15 : 0] S_AXI_LITE_ARADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE ARVALID" *)
input wire S_AXI_LITE_ARVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE ARREADY" *)
output wire S_AXI_LITE_ARREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE RDATA" *)
output wire [31 : 0] S_AXI_LITE_RDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE RVALID" *)
output wire S_AXI_LITE_RVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE RREADY" *)
input wire S_AXI_LITE_RREADY;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI_LITE, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 100000000, ID_WIDTH 0, ADDR_WIDTH 16, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 0, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.000, CLK_DOMAIN main_design_processing_system7_0_0_FCLK_CLK0, NUM_REA\
D_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI_LITE RRESP" *)
output wire [1 : 0] S_AXI_LITE_RRESP;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axis_aresetn, POLARITY ACTIVE_LOW, XIL_INTERFACENAME RESETN, POLARITY ACTIVE_LOW" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 axis_aresetn RST, xilinx.com:signal:reset:1.0 RESETN RST" *)
input wire axis_aresetn;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME axis_clk, ASSOCIATED_BUSIF m_axis:s_axis, ASSOCIATED_RESET axis_aresetn, FREQ_HZ 100000000, PHASE 0.000, XIL_INTERFACENAME CLOCK, ASSOCIATED_RESET axis_aresetn, ASSOCIATED_BUSIF m_axis:s_axis, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN main_design_processing_system7_0_0_FCLK_CLK0" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 axis_clk CLK, xilinx.com:signal:clock:1.0 CLOCK CLK" *)
input wire axis_clk;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TDATA" *)
output wire [31 : 0] m_axis_tdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TKEEP" *)
output wire [3 : 0] m_axis_tkeep;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TLAST" *)
output wire m_axis_tlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TREADY" *)
input wire m_axis_tready;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME m_axis, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN main_design_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 m_axis TVALID" *)
output wire m_axis_tvalid;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TDATA" *)
input wire [31 : 0] s_axis_tdata;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TKEEP" *)
input wire [3 : 0] s_axis_tkeep;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TLAST" *)
input wire s_axis_tlast;
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TREADY" *)
output wire s_axis_tready;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME s_axis, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0, HAS_TREADY 1, HAS_TSTRB 0, HAS_TKEEP 1, HAS_TLAST 1, FREQ_HZ 100000000, PHASE 0.000, CLK_DOMAIN main_design_processing_system7_0_0_FCLK_CLK0, LAYERED_METADATA undef" *)
(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 s_axis TVALID" *)
input wire s_axis_tvalid;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME engine_aresetn, POLARITY ACTIVE_LOW" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 engine_aresetn RST" *)
input wire engine_aresetn;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME engine_clock, ASSOCIATED_RESET engine_aresetn, FREQ_HZ 200000000, PHASE 0.000, CLK_DOMAIN main_design_processing_system7_0_0_FCLK_CLK1" *)
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 engine_clock CLK" *)
input wire engine_clock;
output wire [31 : 0] debug_tdata;
output wire debug_tlast;
output wire debug_tready;
output wire debug_tvalid;
output wire [95 : 0] debug_data;
output wire debug_search_ready;
output wire [15 : 0] debug_engine_match;
output wire debug_start_search;
output wire [1 : 0] debug_state;

  inspection_unit #(
    .TCQ(1),
    .DATA_WIDTH(32),
    .ADDR_WIDTH(16),
    .MAX_PACKET_LENGTH(2048),
    .ENGINES_NUMBER(16),
    .ENGINE_MAX_SIZE(256)
  ) inst (
    .S_AXI_LITE_ARESETN(S_AXI_LITE_ARESETN),
    .S_AXI_LITE_ACLK(S_AXI_LITE_ACLK),
    .S_AXI_LITE_AWADDR(S_AXI_LITE_AWADDR),
    .S_AXI_LITE_AWVALID(S_AXI_LITE_AWVALID),
    .S_AXI_LITE_AWREADY(S_AXI_LITE_AWREADY),
    .S_AXI_LITE_WDATA(S_AXI_LITE_WDATA),
    .S_AXI_LITE_WSTRB(S_AXI_LITE_WSTRB),
    .S_AXI_LITE_WVALID(S_AXI_LITE_WVALID),
    .S_AXI_LITE_WREADY(S_AXI_LITE_WREADY),
    .S_AXI_LITE_BRESP(S_AXI_LITE_BRESP),
    .S_AXI_LITE_BVALID(S_AXI_LITE_BVALID),
    .S_AXI_LITE_BREADY(S_AXI_LITE_BREADY),
    .S_AXI_LITE_ARADDR(S_AXI_LITE_ARADDR),
    .S_AXI_LITE_ARVALID(S_AXI_LITE_ARVALID),
    .S_AXI_LITE_ARREADY(S_AXI_LITE_ARREADY),
    .S_AXI_LITE_RDATA(S_AXI_LITE_RDATA),
    .S_AXI_LITE_RVALID(S_AXI_LITE_RVALID),
    .S_AXI_LITE_RREADY(S_AXI_LITE_RREADY),
    .S_AXI_LITE_RRESP(S_AXI_LITE_RRESP),
    .axis_aresetn(axis_aresetn),
    .axis_clk(axis_clk),
    .m_axis_tdata(m_axis_tdata),
    .m_axis_tkeep(m_axis_tkeep),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tready(m_axis_tready),
    .m_axis_tvalid(m_axis_tvalid),
    .s_axis_tdata(s_axis_tdata),
    .s_axis_tkeep(s_axis_tkeep),
    .s_axis_tlast(s_axis_tlast),
    .s_axis_tready(s_axis_tready),
    .s_axis_tvalid(s_axis_tvalid),
    .engine_aresetn(engine_aresetn),
    .engine_clock(engine_clock),
    .debug_tdata(debug_tdata),
    .debug_tlast(debug_tlast),
    .debug_tready(debug_tready),
    .debug_tvalid(debug_tvalid),
    .debug_data(debug_data),
    .debug_search_ready(debug_search_ready),
    .debug_engine_match(debug_engine_match),
    .debug_start_search(debug_start_search),
    .debug_state(debug_state)
  );
endmodule
