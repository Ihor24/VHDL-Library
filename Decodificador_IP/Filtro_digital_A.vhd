library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity filtro_digital_A is
  port (
		clk     : in std_logic;
		rst     : in std_logic;
		CHA     : in std_logic;
		CE      : in std_logic;   --Prescaler
		CHA_out : out std_logic);

end entity ; -- filtro_digital_A

architecture rtl of filtro_digital_A is
	
	signal CHA_out_i   : std_logic;
	signal tap         : std_logic_vector (3 downto 0);
	signal all_zeros_A : std_logic;
	signal all_ones_A  : std_logic;


begin

 
   	Contador : process (clk) is --Contador de pulsos de CE
    begin  -- process
     if(clk = '1' and clk'event) then
      if(rst = '1') then
        tap <= (others => '0');
      elsif(CE = '1') then
        tap <= tap(2 downto 0) & CHA;
      end if;
     end if;

    end process;

  all_ones_A  <= '1' when (tap = "1111") else '0';
  all_zeros_A <= '1' when (tap = "0000") else '0';

  	Biestable_JK : process (clk) is  --Si se producen suficientes pulsos, se pasa a la salida
  	begin  -- process
  		if(clk = '1' and clk'event) then
        if(rst = '1') then
          CHA_out_i <= '0';
        else
  			   if(all_ones_A = '1') then
  			     CHA_out_i <= '1';
  			   elsif(all_zeros_A = '1') then
  			     CHA_out_i <= '0';
  			   end if;
        end if;
  		end if;
   
  end process;

  CHA_out <= CHA_out_i;

end architecture ; -- rtl