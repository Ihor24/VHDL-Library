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
-- Module Name: AXI lite BFM model (testbench) - sim
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

entity m_axi_lite_bfm is
  generic (
    C_M_AXI_ADDR_WIDTH  : integer range 32 to 32 := 32;
    C_M_AXI_DATA_WIDTH  : integer range 32 to 64 := 32);
  port (
    m_axi_aclk    : in  std_logic;                                            --  AXI Clock
    m_axi_aresetn : out std_logic;                                            --  AXI Reset, active low
    ---
    m_axi_awaddr  : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);      --  AXI Write address
    m_axi_awprot  : out std_logic_vector(2 downto 0);
    m_axi_awvalid : out std_logic;                                            --  Write address valid
    m_axi_awready : in  std_logic;                                            --  Write address ready
    ---
    m_axi_wdata   : out std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);      --  Write data
    m_axi_wstrb   : out std_logic_vector((C_M_AXI_DATA_WIDTH/8)-1 downto 0);  --  Write strobes
    m_axi_wvalid  : out std_logic;                                            --  Write valid
    m_axi_wready  : in  std_logic;                                            --  Write ready
    ---
    m_axi_bresp   : in  std_logic_vector(1 downto 0);                         --  Write response
    m_axi_bvalid  : in  std_logic;                                            --  Write response valid
    m_axi_bready  : out std_logic;                                            --  Response ready
    ---
    m_axi_araddr  : out std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);      --  Read address
    m_axi_arprot  : out std_logic_vector(2 downto 0);
    m_axi_arvalid : out std_logic;                                            --  Read address valid
    m_axi_arready : in  std_logic;                                            --  Read address ready
    ---
    m_axi_rdata   : in  std_logic_vector(C_M_AXI_DATA_WIDTH-1 downto 0);      --  Read data
    m_axi_rresp   : in  std_logic_vector(1 downto 0);                         --  Read response
    m_axi_rvalid  : in  std_logic;                                            --  Read valid
    m_axi_rready  : out std_logic);                                            --  Read ready
end entity;

architecture sim of m_axi_lite_bfm is
  procedure gap(N_cycles : in integer := 0) is
  begin
    for i in 1 to N_cycles loop
      wait until (m_axi_aclk'event and m_axi_aclk = '1');
    end loop;
  end gap;
  
  signal m_axi : axi_lite_bus;
            
  -- Add user code here:
  
begin

  main: process
    procedure axi_read_32(addr : in integer; data : out integer) is
    begin
      axi_read_32(m_axi_aclk, m_axi, addr, data);
    end axi_read_32;
    procedure axi_write_32(addr : in integer; data : in integer) is
    begin
      axi_write_32(m_axi_aclk, m_axi, addr, data);
    end axi_write_32;

    procedure axi_read_32(addr : in integer; data : out std_logic_vector) is
    begin
      axi_read_32(m_axi_aclk, m_axi, addr, data);
    end axi_read_32;
    procedure axi_write_32(addr : in integer; data : in std_logic_vector) is
    begin
      axi_write_32(m_axi_aclk, m_axi, addr, data);
    end axi_write_32;
    
    -- Add user code here:
    
    constant PMOD_encoder_CTRL_REG_OFFSET     : integer := 0*4;
    constant PMOD_encoder_PERIOD_REG_OFFSET   : integer := 1*4;
    constant PMOD_encoder_position_REG_OFFSET : integer := 2*4;
    constant PMOD_encoder_speed_OFFSET        : integer := 3*4;

    variable period     : integer := 0;
  
  begin
    axi_init(m_axi);
    
    m_axi_aresetn <= '0';
    gap(4);
    m_axi_aresetn <= '1';
    gap(4);
    
    -- Add user code here:
    
    axi_write_32(PMOD_encoder_CTRL_REG_OFFSET, x"1"); --RST
    
    axi_write_32(PMOD_encoder_CTRL_REG_OFFSET, x"8"); --Quito flag

    period := (100_000_000 / 20_000) - 1;

    axi_write_32(PMOD_encoder_PERIOD_REG_OFFSET, period); --Fijo periodo

    axi_write_32(PMOD_encoder_CTRL_REG_OFFSET, x"4"); --Activo IRQ y quito RST

    gap(6000);
    axi_write_32(PMOD_encoder_CTRL_REG_OFFSET, x"C"); --Limpio IRQ

    gap(5000);
    axi_write_32(PMOD_encoder_CTRL_REG_OFFSET, x"C"); --Limpio IRQ

    gap(3000);
    axi_write_32(PMOD_encoder_CTRL_REG_OFFSET, x"6"); --RST Posicion




    report "End of simulation";
    wait;
  end process;

  XPANSOR: entity work.m_axi_lite_expansor
    generic map (
      C_M_AXI_ADDR_WIDTH  => C_M_AXI_ADDR_WIDTH,
      C_M_AXI_DATA_WIDTH  => C_M_AXI_DATA_WIDTH)
    port map (
      m_axi         => m_axi, 
      ---
      m_axi_awaddr  => m_axi_awaddr, 
      m_axi_awprot  => m_axi_awprot, 
      m_axi_awvalid => m_axi_awvalid, 
      m_axi_awready => m_axi_awready, 
      ---
      m_axi_wdata   => m_axi_wdata, 
      m_axi_wstrb   => m_axi_wstrb, 
      m_axi_wvalid  => m_axi_wvalid, 
      m_axi_wready  => m_axi_wready, 
      ---
      m_axi_bresp   => m_axi_bresp, 
      m_axi_bvalid  => m_axi_bvalid, 
      m_axi_bready  => m_axi_bready, 
      ---
      m_axi_araddr  => m_axi_araddr, 
      m_axi_arprot  => m_axi_arprot, 
      m_axi_arvalid => m_axi_arvalid, 
      m_axi_arready => m_axi_arready, 
      ---
      m_axi_rdata   => m_axi_rdata, 
      m_axi_rresp   => m_axi_rresp, 
      m_axi_rvalid  => m_axi_rvalid, 
      m_axi_rready  => m_axi_rready); 

end sim;

