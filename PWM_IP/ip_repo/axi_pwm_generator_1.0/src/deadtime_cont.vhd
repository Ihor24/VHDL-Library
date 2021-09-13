library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity deadtime_cont is
  port (
  	clk : in std_logic;
	  rst : in std_logic;
    enable_dead : in std_logic; --Señal enable tiempos muertos
	  pwm_in : in std_logic;  --Señal PWM entrada
    mod_dir : in std_logic;  --Cambiar direccion
	  start_dt : in std_logic; --Señal fin periodo
	  deadtime : in std_logic_vector(15 downto 0); --Cuentas de deadtime
	  pwm_out : out std_logic;  --Salida PWM
    dir : out std_logic); --Salida direccion

end entity ; -- deadtime_cont

architecture rtl of deadtime_cont is

  signal dt_enable : std_logic;
  signal detect_start : std_logic;
  signal deadtime_i : unsigned(15 downto 0);
  signal prev_dir : std_logic;
  signal dir_i : std_logic;

  signal dir_up : std_logic;
  signal dir_down : std_logic;


begin

  Actualizacion_direccion : process(clk)
  begin
    if(clk = '1' and clk'event) then
      if(rst = '1') then
        prev_dir <= mod_dir;
        dir_up <= '0';
        dir_down <= '0';
      elsif (enable_dead = '1' and start_dt = '1')then --Si detecta cambio en la direcci�?n y es fin de periodo
        prev_dir <= mod_dir;
        dir_up <= not(prev_dir) and mod_dir;
        dir_down <= prev_dir and not(mod_dir);
      end if;
    end if;
    
  end process ; -- Actualizacion_direccion


  detect_start <= dir_down or dir_up; --Cuando detecta que las señales de dir_in y prev_dir son diferentes se pone a 1

  Enable_deadtime : process(clk)
  begin
    if(clk = '1' and clk'event) then
      if(rst = '1') then
         dt_enable <= '0';
         dir_i <= '0';
      else
        if (detect_start = '1' and start_dt = '1')then --Si detecta cambio en la direcci�?n y es fin de periodo
          dt_enable <= '1';  --Activa el deadtime
          dir_i <= prev_dir;
        elsif(deadtime_i = 0) then  --Si llega a fin de cuenta
        dt_enable <= '0';  --Lo desactiva
        end if;
      end if;
    end if;
    
  end process ; 
  
  Dead_time_cont : process(clk)
    begin
      if(clk = '1' and clk'event) then
        if(rst = '1') then
            deadtime_i <= unsigned(deadtime);  --Actualizo valor deadtime
        else
            if (dt_enable = '1') then  --Si la se�?al de enable del deadtime eta activa
            deadtime_i <= deadtime_i - 1; -- Decremento el contador
            else
            deadtime_i <= unsigned(deadtime);  --El contador vuelve a la posicion inicial
            end if;
        end if;
     end if;
            
  end process ; -- Dead_time_cont
  
  pwm_out <= pwm_in and not(dt_enable);
  dir <= dir_i;

end architecture ; -- rtl