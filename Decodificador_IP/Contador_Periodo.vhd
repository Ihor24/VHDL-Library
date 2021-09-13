library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_periodo is
  port (
	clk        : in std_logic;
	rst        : in std_logic;
	obs_period : in std_logic_vector(31 downto 0); --Periodo de observacion
	period_end : out std_logic);                   --Señal fin de periodo de observacion

end entity ; -- contador_periodo

architecture rtl of contador_periodo is

	signal period_end_i : std_logic;
	signal cont         : unsigned(31 downto 0);

begin

    Contador_descendente : process (clk) is
    begin  -- process
     if(clk = '1' and clk'event) then
        if(rst = '1') then
        cont <= unsigned(obs_period);
        else
     	  if(cont = 0) then                 --Cuando llega a 0, se reinicia
     	      cont <= unsigned(obs_period);
          else
              cont <= cont - 1;             --Si no, se decrementa
          end if;       
        end if;
     end if;

	end process;

	Pulso_fin : process (clk) is
    begin  -- process
     if(clk = '1' and clk'event) then
        if(rst = '1') then
        period_end_i <= '0';
        else
     	  if(cont = 1) then        --Cuando el contador este a 1, porque va con retraso
     		period_end_i <= '1';   --Se ha acabado el periodo
     	  else
     		period_end_i <= '0';   --Si no, a 0
     	  end if;      
        end if;
     end if;

	end process;
	
	period_end <= period_end_i;

end architecture ; -- rtl