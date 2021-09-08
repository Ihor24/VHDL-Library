library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd2seg is

	port (
			bcd : in std_logic_vector (3 downto 0);
			Display : out std_logic_vector (7 downto 0));
	
end entity bcd2seg;

architecture rtl of bcd2seg is

begin

	with bcd select
	 Display <=   "11000000" when "0000", --0 C0
	 			  "11111001" when "0001", --1 F9
	 			  "10100100" when "0010", --2 A4
	 			  "10110000" when "0011", --3 B0
	 			  "10011001" when "0100", --4 99
	 			  "10010010" when "0101", --5 92
	 			  "10000010" when "0110", --6 82
	 			  "11111000" when "0111", --7 F8
	 			  "10000000" when "1000", --8 90
	 			  "10011000" when "1001", --9 98
	 			  "01111111" when others; --. 7F

end architecture ; 