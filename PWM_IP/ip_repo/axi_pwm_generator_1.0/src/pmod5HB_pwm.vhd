library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pmod5HB_pwm is
  port (
		clk : in std_logic;
		rst : in std_logic;
		enable_pwm : in std_logic;
		enable_dead : in std_logic;
		carrier_period : in std_logic_vector(23 downto 0);
		mod_value : in std_logic_vector(23 downto 0);
		mod_dir : in std_logic;
		deadtime : in std_logic_vector(15 downto 0);
		pwm_en : out std_logic;
		pwm_dir : out std_logic);

end entity ; -- pmod5HB_pwm

architecture rtl of pmod5HB_pwm is

	component pwm_generator is
		port(
			clk : in std_logic;
      		rst : in std_logic;
      		enable_pwm : in std_logic;  --Señal enable PWM
      		carrier_period : in std_logic_vector(23 downto 0); --Valor maximo
      		mod_value : in std_logic_vector(23 downto 0); --Ciclo de trabajo
      		pwm : out std_logic; --Salida PWM
      		carrier_fin : out std_logic); --Pulsos fin de periodo
	
	end component pwm_generator;

	component deadtime_cont is
		port(
            clk : in std_logic;
			rst : in std_logic;
    		enable_dead : in std_logic; --Señal enable tiempos muertos
    		mod_dir : in std_logic;  --Cambiar direccion
			pwm_in : in std_logic;  --Señal PWM entrada
			start_dt : in std_logic; --Señal fin periodo
			deadtime : in std_logic_vector(15 downto 0); --Cuentas de deadtime
			pwm_out : out std_logic;  --Salida PWM
    		dir : out std_logic); --Salida direccion

	end component deadtime_cont;

	signal pwm_i : std_logic;
	signal carrier_fin_i : std_logic;

begin

	--JUNTO LOS DOS COMPONENTES, pwm_generator Y deadtime--

	Conexion_pwm_generator : pwm_generator
		port map(
			clk => clk,
		  	rst => rst,
		  	enable_pwm => enable_pwm,
		  	carrier_period => carrier_period,
		  	mod_value => mod_value,
		  	pwm => pwm_i,
		  	carrier_fin => carrier_fin_i);


	Conexion_deadtime : deadtime_cont
		port map(
			clk => clk,
		  	rst => rst,
		  	pwm_in => pwm_i,
		  	mod_dir => mod_dir,
		  	enable_dead => enable_dead,
		  	start_dt => carrier_fin_i,
		  	deadtime => deadtime,
		  	pwm_out => pwm_en,
		  	dir => pwm_dir);


end architecture ; -- rtl