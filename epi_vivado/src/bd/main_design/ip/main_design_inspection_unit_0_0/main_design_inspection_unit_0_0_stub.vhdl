-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
-- Date        : Wed Mar 27 22:43:32 2019
-- Host        : Nelson running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub -rename_top main_design_inspection_unit_0_0 -prefix
--               main_design_inspection_unit_0_0_ main_design_inspection_unit_0_0_stub.vhdl
-- Design      : main_design_inspection_unit_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z020clg484-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity main_design_inspection_unit_0_0 is
  Port ( 
    S_AXI_LITE_ARESETN : in STD_LOGIC;
    S_AXI_LITE_ACLK : in STD_LOGIC;
    S_AXI_LITE_AWADDR : in STD_LOGIC_VECTOR ( 15 downto 0 );
    S_AXI_LITE_AWVALID : in STD_LOGIC;
    S_AXI_LITE_AWREADY : out STD_LOGIC;
    S_AXI_LITE_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_LITE_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_LITE_WVALID : in STD_LOGIC;
    S_AXI_LITE_WREADY : out STD_LOGIC;
    S_AXI_LITE_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_LITE_BVALID : out STD_LOGIC;
    S_AXI_LITE_BREADY : in STD_LOGIC;
    S_AXI_LITE_ARADDR : in STD_LOGIC_VECTOR ( 15 downto 0 );
    S_AXI_LITE_ARVALID : in STD_LOGIC;
    S_AXI_LITE_ARREADY : out STD_LOGIC;
    S_AXI_LITE_RDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_LITE_RVALID : out STD_LOGIC;
    S_AXI_LITE_RREADY : in STD_LOGIC;
    S_AXI_LITE_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    axis_aresetn : in STD_LOGIC;
    axis_clk : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_tkeep : out STD_LOGIC_VECTOR ( 3 downto 0 );
    m_axis_tlast : out STD_LOGIC;
    m_axis_tready : in STD_LOGIC;
    m_axis_tvalid : out STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_tkeep : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axis_tlast : in STD_LOGIC;
    s_axis_tready : out STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC;
    engine_aresetn : in STD_LOGIC;
    engine_clock : in STD_LOGIC;
    debug_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    debug_tlast : out STD_LOGIC;
    debug_tready : out STD_LOGIC;
    debug_tvalid : out STD_LOGIC;
    debug_data : out STD_LOGIC_VECTOR ( 95 downto 0 );
    debug_search_ready : out STD_LOGIC;
    debug_engine_match : out STD_LOGIC_VECTOR ( 15 downto 0 );
    debug_start_search : out STD_LOGIC;
    debug_state : out STD_LOGIC_VECTOR ( 1 downto 0 )
  );

end main_design_inspection_unit_0_0;

architecture stub of main_design_inspection_unit_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "S_AXI_LITE_ARESETN,S_AXI_LITE_ACLK,S_AXI_LITE_AWADDR[15:0],S_AXI_LITE_AWVALID,S_AXI_LITE_AWREADY,S_AXI_LITE_WDATA[31:0],S_AXI_LITE_WSTRB[3:0],S_AXI_LITE_WVALID,S_AXI_LITE_WREADY,S_AXI_LITE_BRESP[1:0],S_AXI_LITE_BVALID,S_AXI_LITE_BREADY,S_AXI_LITE_ARADDR[15:0],S_AXI_LITE_ARVALID,S_AXI_LITE_ARREADY,S_AXI_LITE_RDATA[31:0],S_AXI_LITE_RVALID,S_AXI_LITE_RREADY,S_AXI_LITE_RRESP[1:0],axis_aresetn,axis_clk,m_axis_tdata[31:0],m_axis_tkeep[3:0],m_axis_tlast,m_axis_tready,m_axis_tvalid,s_axis_tdata[31:0],s_axis_tkeep[3:0],s_axis_tlast,s_axis_tready,s_axis_tvalid,engine_aresetn,engine_clock,debug_tdata[31:0],debug_tlast,debug_tready,debug_tvalid,debug_data[95:0],debug_search_ready,debug_engine_match[15:0],debug_start_search,debug_state[1:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "inspection_unit,Vivado 2018.2";
begin
end;
