library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity filtro_digital_B is
  port (
    clk     : in std_logic;
    rst     : in std_logic;
    CHB     : in std_logic;
    CE      : in std_logic;   --Prescaler
    CHB_out : out std_logic);

end entity ; -- filtro_digital_B

architecture rtl of filtro_digital_B is
  
  signal CHB_out_i   : std_logic;
  signal tap         : std_logic_vector (3 downto 0);
  signal all_zeros_B : std_logic;
  signal all_ones_B  : std_logic;


begin

 
    Contador : process (clk) is  --Contador de pulsos de CE
    begin  -- process
     if(clk = '1' and clk'event) then
      if(rst = '1') then
        tap <= (others => '0');
      elsif(CE = '1') then
            tap <= tap(2 downto 0) & CHB;
      end if;
     end if;

end process;

  all_ones_B  <= '1' when (tap = "1111") else '0';
  all_zeros_B <= '1' when (tap = "0000") else '0';

    Biestable_JK : process (clk) is  --Si se producen suficientes pulsos, se pasa a la salida
    begin  -- process
      if(clk = '1' and clk'event) then
        if(rst = '1') then
        CHB_out_i <= '0';
        else
          if(all_ones_B = '1') then
            CHB_out_i <= '1';
          elsif(all_zeros_B = '1') then
            CHB_out_i <= '0';
          end if;
        end if;
      end if;
   
  end process;

  CHB_out <= CHB_out_i;

end architecture ; -- rtl