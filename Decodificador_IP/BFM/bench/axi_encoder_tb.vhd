------------------------------------------------------------
-- Copyright: 2021 Raul Mateos-Gil. University of Alcala
--            https://soc-repo.depeca.uah.es/gitlab
------------------------------------------------------------

----------------------------------------------------------------------------------
-- Company: University of Alcala
-- Authors: Raul Mateos
--
-- Create Date: 03/04/2021 12:43:11
-- Design Name: AXI lite PWM controller
-- Module Name: testbench - sim
-- Project Name: SEDA SoC.
-- Target Devices: Xilinx 7 series (Zynq)
-- Tool Versions: Questa Sim 10.7c / Vivado 2017.4
-- Description:
--
-- Dependencies: RMG support package
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
-- Modification history:
--  03/04/2021: source code established.
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

entity axi_encoder_tb is
end axi_encoder_tb;

architecture sim of axi_encoder_tb is
  constant C_AXI_ADDR_WIDTH : integer := 32;
  constant C_AXI_DATA_WIDTH : integer := 32;
  constant C_CLK_PERIOD_PS  : integer := 10_000;
  
  constant T_CLK : time := C_CLK_PERIOD_PS * 1 ps;
  
  signal axi_aclk     : std_logic := '1';
  signal axi_aresetn  : std_logic;
  signal axi_awaddr   : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
  signal axi_awprot   : std_logic_vector(2 downto 0);
  signal axi_awvalid  : std_logic;
  signal axi_awready  : std_logic;
  signal axi_wdata    : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
  signal axi_wstrb    : std_logic_vector((C_AXI_DATA_WIDTH/8)-1 downto 0);
  signal axi_wvalid   : std_logic;
  signal axi_wready   : std_logic;
  signal axi_bresp    : std_logic_vector(1 downto 0);
  signal axi_bvalid   : std_logic;
  signal axi_bready   : std_logic;
  signal axi_araddr   : std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
  signal axi_arprot   : std_logic_vector(2 downto 0);
  signal axi_arvalid  : std_logic;
  signal axi_arready  : std_logic;
  signal axi_rdata    : std_logic_vector(C_AXI_DATA_WIDTH-1 downto 0);
  signal axi_rresp    : std_logic_vector(1 downto 0);
  signal axi_rvalid   : std_logic;
  signal axi_rready   : std_logic;

  ---

  signal CHA         : std_logic;
  signal CHB         : std_logic;
  signal speed       : std_logic_vector(23 downto 0);
  signal position    : std_logic_vector(23 downto 0);
  signal update      : std_logic;
    
begin

  axi_aclk <= not(axi_aclk) after T_CLK/2;    

  DUT : entity work.axi_encoder_v1_0
    generic map (
      C_S_AXI_DATA_WIDTH => C_AXI_DATA_WIDTH,
      C_S_AXI_ADDR_WIDTH => C_AXI_ADDR_WIDTH)
    port map (
      CHA         => CHA,
      CHB         => CHB,

      s_axi_aclk    => axi_aclk,
      s_axi_aresetn => axi_aresetn,
      s_axi_awaddr  => axi_awaddr,
      s_axi_awprot  => axi_awprot,
      s_axi_awvalid => axi_awvalid,
      s_axi_awready => axi_awready,
      s_axi_wdata   => axi_wdata,
      s_axi_wstrb   => axi_wstrb,
      s_axi_wvalid  => axi_wvalid,
      s_axi_wready  => axi_wready,
      s_axi_bresp   => axi_bresp,
      s_axi_bvalid  => axi_bvalid,
      s_axi_bready  => axi_bready,
      s_axi_araddr  => axi_araddr,
      s_axi_arprot  => axi_arprot,
      s_axi_arvalid => axi_arvalid,
      s_axi_arready => axi_arready,
      s_axi_rdata   => axi_rdata,
      s_axi_rresp   => axi_rresp,
      s_axi_rvalid  => axi_rvalid,
      s_axi_rready  => axi_rready);

  BFM : entity work.m_axi_lite_bfm
    generic map (
      C_M_AXI_DATA_WIDTH  => C_AXI_DATA_WIDTH,
      C_M_AXI_ADDR_WIDTH  => C_AXI_ADDR_WIDTH)
    port map (
      m_axi_aclk      => axi_aclk, 
      m_axi_aresetn   => axi_aresetn, 
      m_axi_awaddr    => axi_awaddr, 
      m_axi_awprot    => axi_awprot, 
      m_axi_awvalid   => axi_awvalid, 
      m_axi_awready   => axi_awready, 
      m_axi_wdata     => axi_wdata, 
      m_axi_wstrb     => axi_wstrb, 
      m_axi_wvalid    => axi_wvalid, 
      m_axi_wready    => axi_wready, 
      m_axi_bresp     => axi_bresp, 
      m_axi_bvalid    => axi_bvalid, 
      m_axi_bready    => axi_bready, 
      m_axi_araddr    => axi_araddr, 
      m_axi_arprot    => axi_arprot, 
      m_axi_arvalid   => axi_arvalid, 
      m_axi_arready   => axi_arready, 
      m_axi_rdata     => axi_rdata, 
      m_axi_rresp     => axi_rresp, 
      m_axi_rvalid    => axi_rvalid, 
      m_axi_rready    => axi_rready);

    ENC_GENERATOR : process
    begin
    wait for T_CLK * 15;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '0';
    wait for T_CLK * 5;
    CHA <= '0';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '1';
    wait for T_CLK * 5;
    CHA <= '1';
    CHB <= '0';
    wait for T_CLK * 5;



    
    

    end process;

end sim;

