library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Filtro_Digital is
  port (
    clk     : in std_logic;
    rst     : in std_logic;
    CHA     : in std_logic;   --Señal A entrada 
    CHB     : in std_logic;   --Señal B entrada
    CHA_out : out std_logic;  --Señal A filtrada
    CHB_out : out std_logic); --Señal B filtrada

end entity ; -- Filtro_Digital

architecture rtl of Filtro_Digital is

  component Filtro_digital_A is
    port(
      clk     : in std_logic;
      rst     : in std_logic;
      CHA     : in std_logic;
      CE      : in std_logic;
      CHA_out : out std_logic);
  
  end component Filtro_digital_A;

  component Filtro_digital_B is
    port(
      clk     : in std_logic;
      rst     : in std_logic;
      CHB     : in std_logic;
      CE      : in std_logic;
      CHB_out : out std_logic);
  
  end component Filtro_digital_B;

  component Prescaler is
    port(
      clk : in std_logic;
      rst : in std_logic;
      CE  : out std_logic);
  
  end component Prescaler;

  signal CE_i : std_logic;

begin

  Conexion_FD_A : Filtro_digital_A
    port map(
      clk     => clk,
      rst     => rst,
      CHA     => CHA,
      CE      => CE_i,
      CHA_out => CHA_out);

    Conexion_FD_B : Filtro_digital_B
    port map(
      clk     => clk,
      rst     => rst,
      CHB     => CHB,
      CE      => CE_i,
      CHB_out => CHB_out);

  Conexion_Prescaler : Prescaler
    port map(
      clk     => clk,
      rst     => rst,
      CE      => CE_i);


end architecture ; -- rtl