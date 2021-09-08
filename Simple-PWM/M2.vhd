library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity M2 is
	port (
			CLK : in std_logic;
			RST : in std_logic;
			btn_up : in std_logic;
			btn_down : in std_logic;
			vecPWM : out std_logic_vector (7 downto 0));
	
end entity M2;

architecture rtl of M2 is

	component reloj is
		port (
			CLK : in std_logic; --Señal de reloj
      		RST : in std_logic; --Señal de reset
      		En_10Hz : out std_logic; 
      		En_4Hz : out std_logic); 
	end component reloj;


	signal vecPWM_i : unsigned (7 downto 0);
	signal En_10Hz_i : std_logic;
    signal En_4Hz_i : std_logic;

begin

	Clock : reloj
		port map (
			CLK => CLK,
            RST => RST,
      		En_10Hz => En_10Hz_i,  
      		En_4Hz => En_4Hz_i);


	Pulsadores : process(CLK, RST) is
	begin

		if (RST = '0') then
			vecPWM_i <= (others => '0');

		elsif (CLK = '1' and CLK'event) then
			if (btn_up = '1') then             --cada vez que se detecte que el boton de Up esta pulsado
				if (En_10Hz_i = '1') then   --si ocurre con la señal de 10Hz
					vecPWM_i <= vecPWM_i + 1;   --se incrementa con 1
				end if;
			
			elsif (btn_down = '1') then            --cada vez que se detecte que el boton de Down esta pulsado
                    if (En_10Hz_i = '1') then   --si ocurre con la señal de 10Hz
                        vecPWM_i <= vecPWM_i - 1;  --se incrementa con 1
                    end if;
            end if;
		end if;
		
		if (vecPWM_i <= "01100100") then     --si el contador es <= 100
		    vecPWM <= std_logic_vector(vecPWM_i); --se devuelve el vector
		end if;
		
	end process; -- Pulsadores

end architecture rtl;