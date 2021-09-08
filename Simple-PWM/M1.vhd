library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity M1 is
	port (
			CLK : in std_logic; --Señal de Reloj
			RST : in std_logic; --Señal de Reset asincrono y a nivel bajo
			sw_Dir : in std_logic; --Entrada sentido de giro
			PWM_vector : in std_logic_vector (7 downto 0); --Vector D
			pinDir : out std_logic; --Salida sentido de giro
			pinEn : out std_logic); --Salida PWM

end entity M1;

architecture rtl of M1 is

	component reloj is
		port (
			CLK : in std_logic; --Señal de reloj
      		RST : in std_logic; --Señal de reset
      		En_200KHz : out std_logic; --Frecuencia contador
      		En_2KHz : out std_logic); --Frecuencia MR0
	end component reloj;

	component FSM_direccion is
		port (
			CLK : in std_logic;                 -- Señal de reloj
    		RST : in std_logic;                 -- Sñal de reset
    		sw_Dir : in std_logic;               -- Señal para cambiar de direccion
    		swDir1 : out std_logic);         -- Señal de salida de direccion
	end component FSM_direccion;

	signal En_2KHz_i : std_logic;
	signal En_200KHz_i : std_logic;
	signal pinDir_i : std_logic;
	signal swDir1 : std_logic;
	signal pinEn_i : std_logic;
	signal pinEn_PWM : std_logic;
	signal cont : unsigned (7 downto 0);
	signal cont_blank : unsigned (4 downto 0);
	signal cont_pin_en : unsigned (5 downto 0);
	signal cnt : std_logic;
	signal cnt2 : std_logic;
	
	constant Fin_cuenta1 : integer :=30; 
    constant Fin_cuenta2 : integer :=60;
    --constant Fin_cuenta1 : integer :=3; 
    --constant Fin_cuenta2 : integer :=6;

begin

	Clock : reloj
		port map (
			CLK => CLK,
            RST => RST,
      		En_200KHz => En_200KHz_i,  
      		En_2KHz => En_2KHz_i); 

	FSM : FSM_direccion
		port map (
			CLK => CLK,
    		RST => RST,
    		sw_Dir => sw_Dir,
    		swDir1 => swDir1);

    
    Tblank : process(RST, CLK, sw_Dir, swDir1) is --tiempo que debe de esperar para cambiar de direccion
    begin
        if (RST = '0') then
           cont_blank <= (others => '0');
           pinDir_i <= swDir1;
           cnt <= '1';
        elsif (CLK = '1' and CLK'event) then
           if (sw_Dir = '1') then --cuando se detecte que se ha pulsado el cambio de direccion
               cnt <= '0';                         --pongo el contador a 0
           elsif (cnt = '0') then                  --mientras el contador sea 0
               if (En_2KHz_i = '1') then           --cada vez que se cumpla la condiccion
                   if (cont_blank = Fin_cuenta1) then --miro si ha llegado a fin de cuenta
                       cont_blank <= (others => '0'); --entonces pongo el contador a 0
                        pinDir_i <= swDir1;           --saco por la salida el cambio de direccion
                        cnt <= '1';                   --cambio el contador para que no entre a la condiccion
                    else                           
                        cont_blank <= cont_blank + 1; --si cnt no es 0 cada vez me incrementa
                    end if;
               end if;
            end if;
        end if;
   end process; -- Tblank

    pinDir <= pinDir_i; --pongo en la salida el cambio de direccion


	Pin_En_signal : process(RST, CLK, sw_Dir) is --tiempo que debe esperar para activar el PWM
	begin
		if (RST = '0') then
			cont_pin_en <= (others => '0');
			pinEn_PWM <= '1';
			cnt2 <= '1';
		elsif (CLK = '1' and CLK'event) then
		    if (sw_Dir = '1') then --cuando detecta que se ha pulsado el cambio de direccion
                pinEn_PWM <= '0';                   --desactivo el PWM
                cnt2 <= '0';                        --habilito para que entre en el if
			elsif (cnt2 = '0') then                 --mientras el contador sea 0
				if (En_2KHz_i = '1') then           --cada vez que cumpla la condicion
					if (cont_pin_en = Fin_cuenta2) then --miro si ha llegado al fin de cuenta
						cont_pin_en <= (others => '0'); --entonces pongo el contador a 0
						pinEn_PWM <= '1';               --vuelvo a activar el PWM
						cnt2 <= '1';                    --cambio el contador para que no entre a la condiccion
					else
						cont_pin_en <= cont_pin_en + 1; --si cnt no es 0 cada vez me incrementa
						pinEn_PWM <= '0';               --y mantiene deshabilitado el PWM
					end if;
				end if;
			end if;
		end if;
	end process; -- Pin_En_signal


	Contador_MR0 : process(CLK, RST) is --actua como el MR0
	begin
		if (RST = '0') then
			cont <= (others => '0');
		elsif (CLK = '1' and CLK'event) then
			if (En_2KHz_i = '1') then        --cada vez que llegue a 1 se reinicia, debido a que entre cada flanco hay 100 cuentas
				cont <= (others => '0');     --el contador se vuelve a poner a 0
			elsif (En_200KHz_i = '1') then   --cada vez que se produzca la condicion
				 cont <= cont + 1;           --el contador se incrementa
			end if;
		end if;
		
	end process; -- Contador_MR0


	Comparador_MR1 : process(RST, CLK, PWM_vector) is --Actua como el MR1
	begin
	    if (RST = '0') then
	       pinEn_i <= '0';
	    elsif (CLK = '1' and CLK'event) then
		    if (pinEn_PWM = '0') then        --Mientras el enable este desactivado, el PWM esta a 0
			    pinEn_i <= '0';
		    elsif (pinEn_PWM = '1') then     --cuando el enable esta activado, el PWM esta a 1
			    if (cont >= unsigned(PWM_vector)) then --si el contador el >= al valor de PWM_vector que se ha fijado
				    pinEn_i <= '0';           --el pin se pone a 0
			    else
				    pinEn_i <= '1';           --si no el pin esta a 1
			    end if;
		    end if;
		end if;
	end process; -- Comparador_MR1

	pinEn <= pinEn_i; --Se saca por la salida la señal de PWM
	
end architecture rtl;