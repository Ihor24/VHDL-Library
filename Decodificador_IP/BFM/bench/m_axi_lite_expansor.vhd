------------------------------------------------------------
-- Copyright: 2021 Raul Mateos-Gil. University of Alcala
--            https://soc-repo.depeca.uah.es/gitlab
------------------------------------------------------------

----------------------------------------------------------------------------------
-- Company: University of Alcala
-- Authors: Raul Mateos
--
-- Create Date: 03/04/2021 12:43:11
-- Design Name: Master AXI Lite BFM
-- Module Name: m_axi_lite_expansor - sim
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

use work.interfaces_pkg.all;

entity m_axi_lite_expansor is
  generic (
    C_M_AXI_ADDR_WIDTH  : integer range 32 to 32 := 32;
    C_M_AXI_DATA_WIDTH  : integer range 32 to 64 := 32);
  port (
    m_axi         : inout axi_lite_bus;
    ---
    m_axi_awaddr  : out std_logic_vector(C_m_axi_ADDR_WIDTH-1 downto 0);      --  AXI Write address
    m_axi_awprot  : out std_logic_vector(2 downto 0);
    m_axi_awvalid : out std_logic;                                            --  Write address valid
    m_axi_awready : in  std_logic;                                            --  Write address ready
    ---
    m_axi_wdata   : out std_logic_vector(C_m_axi_DATA_WIDTH-1 downto 0);      --  Write data
    m_axi_wstrb   : out std_logic_vector((C_m_axi_DATA_WIDTH/8)-1 downto 0);  --  Write strobes
    m_axi_wvalid  : out std_logic;                                            --  Write valid
    m_axi_wready  : in  std_logic;                                            --  Write ready
    ---
    m_axi_bresp   : in  std_logic_vector(1 downto 0);                         --  Write response
    m_axi_bvalid  : in  std_logic;                                            --  Write response valid
    m_axi_bready  : out std_logic;                                            --  Response ready
    ---
    m_axi_araddr  : out std_logic_vector(C_m_axi_ADDR_WIDTH-1 downto 0);      --  Read address
    m_axi_arprot  : out std_logic_vector(2 downto 0);
    m_axi_arvalid : out std_logic;                                            --  Read address valid
    m_axi_arready : in  std_logic;                                            --  Read address ready
    ---
    m_axi_rdata   : in  std_logic_vector(C_m_axi_DATA_WIDTH-1 downto 0);      --  Read data
    m_axi_rresp   : in  std_logic_vector(1 downto 0);                         --  Read response
    m_axi_rvalid  : in  std_logic;                                            --  Read valid
    m_axi_rready  : out std_logic);                                           --  Read ready
end entity;

architecture sim of m_axi_lite_expansor is
begin
  m_axi_awaddr  <= m_axi.awaddr;  --  out
  m_axi_awprot  <= m_axi.awprot;  --  out
  m_axi_awvalid <= m_axi.awvalid; --  out
  m_axi.awready <= m_axi_awready; --  in 
  ---
  m_axi_wdata   <= m_axi.wdata;   --  out
  m_axi_wstrb   <= m_axi.wstrb;   --  out
  m_axi_wvalid  <= m_axi.wvalid;  --  out
  m_axi.wready <= m_axi_wready;   --  in 
  ---
  m_axi.bresp <= m_axi_bresp;     --  in 
  m_axi.bvalid <= m_axi_bvalid;   --  in 
  m_axi_bready  <= m_axi.bready;  --  out
  ---
  m_axi_araddr  <= m_axi.araddr;  --  out
  m_axi_arprot  <= m_axi.arprot;  --  out
  m_axi_arvalid <= m_axi.arvalid; --  out
  m_axi.arready <= m_axi_arready; --  in 
  ---
  m_axi.rdata <= m_axi_rdata;     --  in 
  m_axi.rresp <= m_axi_rresp;     --  in 
  m_axi.rvalid <= m_axi_rvalid;   --  in 
  m_axi_rready  <= m_axi.rready;  --  out
  
  
  -- Al ser m_axi de tipo inout a los campos que 
  -- leemos se le asigna HZ.

  m_axi.awaddr  <= (others => 'Z'); --  out
  m_axi.awprot  <= (others => 'Z'); --  out
  m_axi.awvalid <= 'Z';             --  out

  m_axi.wdata   <= (others => 'Z'); --  out
  m_axi.wstrb   <= (others => 'Z'); --  out
  m_axi.wvalid  <= 'Z';             --  out

  m_axi.bready  <= 'Z';             --  out

  m_axi.araddr  <= (others => 'Z'); --  out
  m_axi.arprot  <= (others => 'Z'); --  out
  m_axi.arvalid <= 'Z';             --  out

  m_axi.rready  <= 'Z';             --  out
    
end sim;

