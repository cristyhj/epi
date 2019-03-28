// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Wed Mar 27 22:43:32 2019
// Host        : Nelson running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top main_design_inspection_unit_0_0 -prefix
//               main_design_inspection_unit_0_0_ main_design_inspection_unit_0_0_stub.v
// Design      : main_design_inspection_unit_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "inspection_unit,Vivado 2018.2" *)
module main_design_inspection_unit_0_0(S_AXI_LITE_ARESETN, S_AXI_LITE_ACLK, 
  S_AXI_LITE_AWADDR, S_AXI_LITE_AWVALID, S_AXI_LITE_AWREADY, S_AXI_LITE_WDATA, 
  S_AXI_LITE_WSTRB, S_AXI_LITE_WVALID, S_AXI_LITE_WREADY, S_AXI_LITE_BRESP, 
  S_AXI_LITE_BVALID, S_AXI_LITE_BREADY, S_AXI_LITE_ARADDR, S_AXI_LITE_ARVALID, 
  S_AXI_LITE_ARREADY, S_AXI_LITE_RDATA, S_AXI_LITE_RVALID, S_AXI_LITE_RREADY, 
  S_AXI_LITE_RRESP, axis_aresetn, axis_clk, m_axis_tdata, m_axis_tkeep, m_axis_tlast, 
  m_axis_tready, m_axis_tvalid, s_axis_tdata, s_axis_tkeep, s_axis_tlast, s_axis_tready, 
  s_axis_tvalid, engine_aresetn, engine_clock, debug_tdata, debug_tlast, debug_tready, 
  debug_tvalid, debug_data, debug_search_ready, debug_engine_match, debug_start_search, 
  debug_state)
/* synthesis syn_black_box black_box_pad_pin="S_AXI_LITE_ARESETN,S_AXI_LITE_ACLK,S_AXI_LITE_AWADDR[15:0],S_AXI_LITE_AWVALID,S_AXI_LITE_AWREADY,S_AXI_LITE_WDATA[31:0],S_AXI_LITE_WSTRB[3:0],S_AXI_LITE_WVALID,S_AXI_LITE_WREADY,S_AXI_LITE_BRESP[1:0],S_AXI_LITE_BVALID,S_AXI_LITE_BREADY,S_AXI_LITE_ARADDR[15:0],S_AXI_LITE_ARVALID,S_AXI_LITE_ARREADY,S_AXI_LITE_RDATA[31:0],S_AXI_LITE_RVALID,S_AXI_LITE_RREADY,S_AXI_LITE_RRESP[1:0],axis_aresetn,axis_clk,m_axis_tdata[31:0],m_axis_tkeep[3:0],m_axis_tlast,m_axis_tready,m_axis_tvalid,s_axis_tdata[31:0],s_axis_tkeep[3:0],s_axis_tlast,s_axis_tready,s_axis_tvalid,engine_aresetn,engine_clock,debug_tdata[31:0],debug_tlast,debug_tready,debug_tvalid,debug_data[95:0],debug_search_ready,debug_engine_match[15:0],debug_start_search,debug_state[1:0]" */;
  input S_AXI_LITE_ARESETN;
  input S_AXI_LITE_ACLK;
  input [15:0]S_AXI_LITE_AWADDR;
  input S_AXI_LITE_AWVALID;
  output S_AXI_LITE_AWREADY;
  input [31:0]S_AXI_LITE_WDATA;
  input [3:0]S_AXI_LITE_WSTRB;
  input S_AXI_LITE_WVALID;
  output S_AXI_LITE_WREADY;
  output [1:0]S_AXI_LITE_BRESP;
  output S_AXI_LITE_BVALID;
  input S_AXI_LITE_BREADY;
  input [15:0]S_AXI_LITE_ARADDR;
  input S_AXI_LITE_ARVALID;
  output S_AXI_LITE_ARREADY;
  output [31:0]S_AXI_LITE_RDATA;
  output S_AXI_LITE_RVALID;
  input S_AXI_LITE_RREADY;
  output [1:0]S_AXI_LITE_RRESP;
  input axis_aresetn;
  input axis_clk;
  output [31:0]m_axis_tdata;
  output [3:0]m_axis_tkeep;
  output m_axis_tlast;
  input m_axis_tready;
  output m_axis_tvalid;
  input [31:0]s_axis_tdata;
  input [3:0]s_axis_tkeep;
  input s_axis_tlast;
  output s_axis_tready;
  input s_axis_tvalid;
  input engine_aresetn;
  input engine_clock;
  output [31:0]debug_tdata;
  output debug_tlast;
  output debug_tready;
  output debug_tvalid;
  output [95:0]debug_data;
  output debug_search_ready;
  output [15:0]debug_engine_match;
  output debug_start_search;
  output [1:0]debug_state;
endmodule
