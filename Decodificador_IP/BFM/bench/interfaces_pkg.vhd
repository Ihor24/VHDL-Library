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
-- Module Name: Interfaces package
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
--
package interfaces_pkg is
  constant C_ADDR_WIDTH : integer := 32;
  constant C_DATA_WIDTH : integer := 32;

  type axi_lite_bus is record
    awaddr  : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
    awprot  : std_logic_vector(2 downto 0);
    awvalid : std_logic;
    awready : std_logic;
    ---
    wdata   : std_logic_vector(C_DATA_WIDTH-1 downto 0);
    wstrb   : std_logic_vector((C_DATA_WIDTH/8)-1 downto 0);
    wvalid  : std_logic;
    wready  : std_logic;
    ---
    bresp   : std_logic_vector(1 downto 0);
    bvalid  : std_logic;
    bready  : std_logic;
    ---
    araddr  : std_logic_vector(C_ADDR_WIDTH-1 downto 0);
    arprot  : std_logic_vector(2 downto 0);
    arvalid : std_logic;
    arready : std_logic;
    ---
    rdata   : std_logic_vector(C_DATA_WIDTH-1 downto 0);
    rresp   : std_logic_vector(1 downto 0);
    rvalid  : std_logic;
    rready  : std_logic;
  end record;

  procedure axi_init (
    signal axi_lite  : inout axi_lite_bus);

  procedure axi_write (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in std_logic_vector(31 downto 0);
    data            : in std_logic_vector(31 downto 0);
    size            : in integer);

  procedure axi_read (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in    std_logic_vector(31 downto 0);
    data            : out   std_logic_vector(31 downto 0);
    size            : in    integer);

  -- CONVENIENCE FUNCTIONS:
    
  procedure axi_write_8 (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in    integer;
    data            : in    integer);

  procedure axi_write_16 (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in    integer;
    data            : in    integer);

  procedure axi_write_32 (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in    integer;
    data            : in    integer);

  procedure axi_read_8 (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in    integer;
    data            : out   integer);

  procedure axi_read_16 (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in    integer;
    data            : out   integer);

  procedure axi_read_32 (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in    integer;
    data            : out   integer);

  ----- 

  procedure axi_read_32 (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in    integer;
    data            : out   std_logic_vector);

  procedure axi_write_32 (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in    integer;
    data            : in    std_logic_vector);

end interfaces_pkg;

package body interfaces_pkg is

  procedure axi_write (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in std_logic_vector(31 downto 0);
    data            : in std_logic_vector(31 downto 0);
    size            : in integer)
  is
    variable addr_done : boolean := false;
    variable data_done : boolean := false;
    variable wr_resp  : std_logic_vector(1 downto 0);

    variable wr_data  : std_logic_vector(31 downto 0) := (others => '0');
    variable be       : std_logic_vector(3 downto 0) := (others => '0');

    variable offset : integer;
  begin
    case size is
      when 1 => -- byte access
        offset := to_integer(unsigned(addr(1 downto 0)));
        wr_data(8*(offset+1)-1 downto 8*offset) := data(7 downto 0);
        be(1*(offset+1)-1 downto 1*offset) := (others => '1');
      when 2 => -- half word access
        assert (addr(0 downto 0) = "0") report "Invalid offset" severity WARNING;
        offset := to_integer(unsigned(addr(1 downto 0)));
        wr_data(16*(offset+1)-1 downto 16*offset) := data(15 downto 0);
        be(2*(offset+1)-1 downto 2*offset) := (others => '1');
      when 4 => -- word access
        assert (addr(1 downto 0) = "00") report "Invalid offset" severity WARNING;
        wr_data := data(31 downto 0);
        be := (others => '1');
      when others =>
        assert false report "Invalid size" severity ERROR;
    end case;

    -- addr & data phase:
    axi_lite.awaddr  <= addr;
    axi_lite.awprot  <= "000";
    axi_lite.awvalid <= '1';

    axi_lite.wdata  <= wr_data;
    axi_lite.wstrb  <= be;
    axi_lite.wvalid <= '1';

    wait until (clk'event and clk = '1');

    if (axi_lite.awready = '1') then
      axi_lite.awaddr  <= (others => 'X');
      axi_lite.awprot  <= (others => 'X');
      axi_lite.awvalid <= '0';
      addr_done := true;
    end if;

    if (axi_lite.wready = '1') then
      axi_lite.wdata   <= (others => 'X');
      axi_lite.wstrb   <= (others => 'X');
      axi_lite.wvalid  <= '0';
      data_done := true;
    end if;

    while(not(addr_done and data_done)) loop
      wait until (clk'event and clk = '1');

      if (axi_lite.awready = '1') then
        axi_lite.awaddr  <= (others => 'X');
        axi_lite.awprot  <= (others => 'X');
        axi_lite.awvalid <= '0';
        addr_done := true;
      end if;

      if (axi_lite.wready = '1') then
        axi_lite.wdata   <= (others => 'X');
        axi_lite.wstrb   <= (others => 'X');
        axi_lite.wvalid  <= '0';
        data_done := true;
      end if;
    end loop;

    -- end of addr & data phases: get the response.
    axi_lite.bready  <= '1';
    wait until (clk'event and clk = '1');

    while(axi_lite.bvalid /= '1') loop
      wait until (clk'event and clk = '1');
    end loop;

    axi_lite.bready  <= '0';
    wr_resp := axi_lite.bresp;
  end axi_write;

  procedure axi_read (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in    std_logic_vector(31 downto 0);
    data            : out   std_logic_vector(31 downto 0);
    size            : in    integer)
  is
    variable rd_resp  : std_logic_vector(1 downto 0);
    variable rd_data  : std_logic_vector(31 downto 0) := (others => '0');

    variable offset : integer;
  begin
    case size is
      when 1 => -- byte access
        offset := to_integer(unsigned(addr(1 downto 0)));
      when 2 => -- half word access
        assert (addr(0 downto 0) = "0") report "Invalid offset" severity WARNING;
        offset := to_integer(unsigned(addr(1 downto 0)));
      when 4 => -- word access
        assert (addr(1 downto 0) = "00") report "Invalid offset" severity WARNING;
        offset := 0;
      when others =>
        assert false report "Invalid size" severity ERROR;
    end case;

    axi_lite.rready <= '0';

    -- addr phase:
    axi_lite.araddr <= addr;
    axi_lite.arprot <= "000";
    axi_lite.arvalid <= '1';
    wait until (clk'event and clk = '1');

    while(axi_lite.arready /= '1') loop
      wait until (clk'event and clk = '1');
    end loop;
    -- end of addr phase: release the channel:
    axi_lite.araddr <= (others => 'X');
    axi_lite.arprot <= (others => 'X');
    axi_lite.arvalid <= '0';

    -- data phase:
    axi_lite.rready <= '1';
    wait until (clk'event and clk = '1');

    while(axi_lite.rvalid /= '1') loop
      wait until (clk'event and clk = '1');
    end loop;

    -- end of data phase: get the data
    axi_lite.rready <= '0';

    rd_resp := axi_lite.rresp;
    case size is
      when 1 => -- byte access
        rd_data(7 downto 0) := axi_lite.rdata(8*(offset+1)-1 downto 8*offset);
      when 2 => -- half word access
        rd_data(15 downto 0) := axi_lite.rdata(16*(offset+1)-1 downto 16*offset);
      when 4 => -- word access
        rd_data := axi_lite.rdata(31 downto 0);
      when others => null;
    end case;

    data := rd_data;
  end axi_read;

  procedure axi_init (
    signal axi_lite  : inout axi_lite_bus)
  is

  begin
    axi_lite.awaddr  <= (others => 'X');
    axi_lite.awprot  <= (others => 'X');
    axi_lite.awvalid <= '0';
    axi_lite.awready <= 'Z';

    axi_lite.wdata   <= (others => 'X');
    axi_lite.wstrb   <= (others => 'X');
    axi_lite.wvalid  <= '0';
    axi_lite.wready <= 'Z';

    axi_lite.bvalid <= 'Z';
    axi_lite.bresp <= (others => 'Z');
    axi_lite.bready  <= '0';

    axi_lite.araddr  <= (others => 'X');
    axi_lite.arprot  <= (others => 'X');
    axi_lite.arvalid <= '0';
    axi_lite.arready <= 'Z';

    axi_lite.rdata   <= (others => 'Z');
    axi_lite.rresp   <= (others => 'Z');
    axi_lite.rvalid  <= 'Z';
    axi_lite.rready  <= '0';
    
  end axi_init;


  -- Convenience functions:
  procedure axi_write_8 (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in    integer;
    data            : in    integer) 
  is
    variable addr_i : std_logic_vector(31 downto 0);
    variable data_i : std_logic_vector(31 downto 0);
  begin
    addr_i := std_logic_vector(to_unsigned(addr, 32));
    data_i := std_logic_vector(to_signed(data, 32));
    axi_write(clk, axi_lite, addr_i, data_i, 1);
  end axi_write_8;

  procedure axi_write_16 (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in    integer;
    data            : in    integer) 
  is
    variable addr_i : std_logic_vector(31 downto 0);
    variable data_i : std_logic_vector(31 downto 0);
  begin
    addr_i := std_logic_vector(to_unsigned(addr, 32));
    data_i := std_logic_vector(to_signed(data, 32));
    axi_write(clk, axi_lite, addr_i, data_i, 2);
  end axi_write_16;

  procedure axi_write_32 (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in    integer;
    data            : in    integer) 
  is
    variable addr_i : std_logic_vector(31 downto 0);
    variable data_i : std_logic_vector(31 downto 0);
  begin
    addr_i := std_logic_vector(to_unsigned(addr, 32));
    data_i := std_logic_vector(to_signed(data, 32));
    axi_write(clk, axi_lite, addr_i, data_i, 4);
  end axi_write_32;

  procedure axi_read_8 (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in    integer;
    data            : out   integer) 
  is
    variable addr_i : std_logic_vector(31 downto 0);
    variable data_i : std_logic_vector(31 downto 0);
  begin
    addr_i := std_logic_vector(to_unsigned(addr, 32));
    axi_read(clk, axi_lite, addr_i, data_i, 1);
    data := to_integer(signed(data_i));
  end axi_read_8;

  procedure axi_read_16 (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in    integer;
    data            : out   integer) 
  is
    variable addr_i : std_logic_vector(31 downto 0);
    variable data_i : std_logic_vector(31 downto 0);
  begin
    addr_i := std_logic_vector(to_unsigned(addr, 32));
    axi_read(clk, axi_lite, addr_i, data_i, 2);
    data := to_integer(signed(data_i));
  end axi_read_16;

  procedure axi_read_32 (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in    integer;
    data            : out   integer) 
  is
    variable addr_i : std_logic_vector(31 downto 0);
    variable data_i : std_logic_vector(31 downto 0);
  begin
    addr_i := std_logic_vector(to_unsigned(addr, 32));
    axi_read(clk, axi_lite, addr_i, data_i, 2);
    data := to_integer(signed(data_i));
  end axi_read_32;

  ----- 

  procedure axi_read_32 (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in    integer;
    data            : out   std_logic_vector) 
  is
    constant N : integer := data'length; 
    variable addr_i : std_logic_vector(31 downto 0);
    variable data_i : std_logic_vector(31 downto 0);
  begin
    addr_i := std_logic_vector(to_unsigned(addr, 32));
    axi_read(clk, axi_lite, addr_i, data_i, 4);
    data := data_i(N-1 downto 0);
  end axi_read_32;

  procedure axi_write_32 (
    signal clk      : in    std_logic;
    signal axi_lite : inout axi_lite_bus;
    addr            : in    integer;
    data            : in    std_logic_vector) 
  is
    constant N : integer := data'length; 
    variable addr_i : std_logic_vector(31 downto 0);
    variable data_i : std_logic_vector(31 downto 0) := x"0000_0000";
  begin
    data_i(N-1 downto 0) := data;
    addr_i := std_logic_vector(to_unsigned(addr, 32));
    axi_write(clk, axi_lite, addr_i, data_i, 4);
  end axi_write_32;


end interfaces_pkg;
