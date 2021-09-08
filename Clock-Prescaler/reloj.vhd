library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reloj is --Estructura reloj

    port(
      CLK : in std_logic; --Señal de reloj
      RST : in std_logic; --Señal de reset
      En_1Hz : out std_logic; --Frecuencia para contar segundos
      En_1KHz : out std_logic); --Frecuencia para display

end entity reloj;

architecture rtl of reloj is

--Declaracion de constantes A, B y C
constant Fin_cuenta_1 : integer :=99; --El valor de conta_1MHz no se actualiza instantaneamente
constant Fin_cuenta_2 : integer :=999;
constant Fin_cuenta_3 : integer :=999;
--Declaracion de constantes para simulacion
--constant Fin_cuenta_1 : integer :=4; 
--constant Fin_cuenta_2 : integer :=10;
--constant Fin_cuenta_3 : integer :=100;

--Señales de reloj iternas
  signal En_1Hz_i : std_logic;
  signal En_1KHz_i : std_logic;
  signal En_1MHz_i : std_logic;
  signal conta_1MHz : unsigned (6 downto 0);
  signal conta_1KHz : unsigned (9 downto 0);
  signal conta_1Hz  : unsigned (9 downto 0);



begin

    --Contador 1
    cnt1_100 : process (CLK, RST) is
        begin
        if (RST = '0') then
            conta_1MHz <= (others => '0');
            En_1MHz_i <= '0';
        elsif (CLK'event and CLK = '1') then
            En_1MHz_i <= '0';
            if (conta_1MHz = Fin_cuenta_1) then
                  En_1MHz_i <= '1';
                  conta_1MHz <= (others => '0');

            else
                conta_1MHz <= conta_1MHz + 1;
            end if;
        end if;
    end process cnt1_100;

    --Contador 2
    cnt2_1000 : process (CLK, RST) is
        begin
        if (RST = '0') then
            conta_1KHz <= (others => '0');
            En_1KHz_i <= '0';
        elsif (CLK'event and CLK = '1') then
            En_1KHz_i <= '0';
            if (En_1MHz_i = '1') then
                En_1KHz_i <= '0';
                if (conta_1KHz = Fin_cuenta_2) then
                    En_1KHz_i <= '1';
                    conta_1KHz <= (others => '0');
                    
                else
                    conta_1KHz <= conta_1KHz + 1;
                end if;
            end if;
        end if;
    end process cnt2_1000;

    En_1KHz <= (En_1KHz_i); --Saco el valor de la señal interna a la salida

    --Contador 3
    cnt3_1000 : process (CLK, RST) is
        begin
        if (RST = '0') then
            conta_1Hz <= (others => '0');
            En_1Hz_i <= '0';
        elsif(CLK'event and CLK = '1') then
            En_1Hz_i <= '0';
            if (En_1KHz_i = '1') then
                 En_1Hz_i <= '0';
                if (conta_1Hz = Fin_cuenta_3) then
                    En_1Hz_i <= '1';
                    conta_1Hz <= (others => '0');
 
                else
                    conta_1Hz <= conta_1Hz + 1;
                end if;
            end if;
        end if;
    end process cnt3_1000;

    En_1Hz <= (En_1HZ_i); --Saco el valor de la señal interna a la salida


end architecture rtl;
