library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_generator is
  port (
      clk : in std_logic;
      rst : in std_logic;
      enable_pwm : in std_logic;  --Se�???al enable PWM
      carrier_period : in std_logic_vector(23 downto 0); --Valor maximo
      mod_value : in std_logic_vector(23 downto 0); --Ciclo de trabajo
      pwm : out std_logic; --Salida PWM
      carrier_fin : out std_logic); --Pulsos fin de periodo
  
end entity pwm_generator;

architecture rtl of pwm_generator is

  signal pwm_i : std_logic;
  signal carrier_cnt : unsigned(23 downto 0);
  signal mod_value_reg : std_logic_vector(23 downto 0);
  signal carrier_fin_i : std_logic;

begin

  Actualizacion_Registros : process(clk) is
  begin
    if(clk = '1' and clk'event)then  --En cada flanco de CLK
      if (rst = '1') then                 --El reset lo pone todo a un valor inicial
         mod_value_reg <= mod_value;
      elsif(carrier_fin_i = '1') then --compruebo si ha llegado a fin de cuenta y si esta activo deadtime_enable
        mod_value_reg <= mod_value; --Actualizo el valor del ciclo de trabajo
      end if;
    end if;

  end process; -- Actualizacion_Registros
  
  carrier_fin_i <= '1' when (carrier_cnt = 0) else '0';

  
  MR0 : process(clk) is
  begin
    if (clk = '1' and clk'event) then
      if(rst = '1') then
        carrier_cnt <= unsigned(carrier_period); 
      elsif(enable_pwm = '1') then
        if(carrier_fin_i = '1') then         --Cuando ha finalizado el periodo del pwm
         carrier_cnt <= unsigned(carrier_period); --Vuelvo a empezar a contar
        else
         carrier_cnt <= carrier_cnt - 1; --Si no, decremento el contador
        end if;
      end if;
    end if;
      
  end process; -- MR0


  MR1 : process(clk)
  begin
    if(clk = '1' and clk'event) then
      if(rst = '1') then
         pwm_i <= '0';
      elsif(enable_pwm = '1') then
        if(carrier_cnt > unsigned(mod_value_reg)) then --Si el contador esta por debajo del ciclo de trabajo fijado, PWM = 1
          pwm_i <= '0';  --la salida sera 1
        elsif (carrier_fin_i = '0') then
         pwm_i <= '1';  --Si, no, PWM = 0
        end if;
      end if;
    end if;
    
  end process ; -- MR1

    carrier_fin <= carrier_fin_i; --Saco la se�???al de fin de periodo
    pwm <= pwm_i; --Saco la se�???al PWM

  
end architecture rtl;