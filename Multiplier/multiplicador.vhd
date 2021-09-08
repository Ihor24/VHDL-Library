library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;
library UNIMACRO;
use unimacro.Vcomponents.all;

entity multiplicador is
  
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    dato_A   : in  std_logic_vector (8 downto 0);
    dato_B   : in  std_logic_vector (2 downto 0);
    producto : out std_logic_vector (11 downto 0));

end entity multiplicador;


architecture rtl of multiplicador is

signal rst_n : std_logic;

  
begin  -- architecture rtl

rst_n <= not rst;                       -- reset core activo a nivel alto

  

  -- MULT_MACRO: Multiply Function implemented in a DSP48E
  -- 7 Series
  -- Xilinx HDL Language Template, version 2017.4
  MULT_MACRO_inst : MULT_MACRO
    generic map (
      DEVICE  => "7SERIES",  -- Target Device: "VIRTEX5", "7SERIES", "SPARTAN6"
      LATENCY => 1,                     -- Desired clock cycle latency, 0-4
      WIDTH_A => 9,                     -- Multiplier A-input bus width, 1-25
      WIDTH_B => 3)                     -- Multiplier B-input bus width, 1-18
    port map (
      P   => producto,  -- Multiplier ouput bus, width determined by WIDTH_P generic
      A   => dato_A,  -- Multiplier input A bus, width determined by WIDTH_A generic
      B   => dato_B,  -- Multiplier input B bus, width determined by WIDTH_B generic
      CE  => '1',                       -- 1-bit active high input clock enable
      CLK => clk,                       -- 1-bit positive edge clock input
      RST => rst_n                      -- 1-bit input active high reset
      );
  -- End of MULT_MACRO_inst instantiation



end architecture rtl;
