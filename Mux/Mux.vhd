library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Mux is

	port (
			CLK : in std_logic;
			RST : in std_logic;
			unidades : in std_logic_vector (3 downto 0);
			decenas : in std_logic_vector (3 downto 0);
			En_1KHz : in std_logic;
			Seg7_code : out std_logic_vector (7 downto 0);
			Sel_displays : out std_logic_vector (3 downto 0));
	
end entity Mux;


architecture multiplexation of Mux is

signal bcd_i : std_logic_vector (3 downto 0);
signal Selection_i : std_logic_vector (3 downto 0);
signal contador_i : unsigned (3 downto 0);

component bcd2seg is
	port (
		bcd : in std_logic_vector (3 downto 0);
		Display : out std_logic_vector (7 downto 0));
end component bcd2seg;

begin

	Selection : process(En_1KHz, CLK, RST, unidades, decenas) is
	
	begin
		if (RST = '0') then
			Selection_i <= (others => '0');
			contador_i <= (others => '0');
		elsif (CLK = '1' and En_1KHz = '1' and En_1KHz'event) then
					
			   if (contador_i = "0011") then --4ms veces es 250Hz 
                    Selection_i <= "1101";
                    bcd_i <= decenas;
				end if;
				if (contador_i = "0111") then
                    contador_i <= (others => '0');
                    Selection_i <= "1110";
                    bcd_i <= unidades;
                else
                    contador_i <= contador_i + 1;
                end if;
				
		end if;
	end process Selection; -- Selection

Sel_displays <= (Selection_i);
	
	Visualizar_Display : bcd2seg
		port map (
			bcd => bcd_i,
			Display => Seg7_code);
	
end architecture multiplexation;