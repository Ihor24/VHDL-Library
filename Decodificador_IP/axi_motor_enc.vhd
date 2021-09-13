library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_motor_enc is
  port (
		clk        : in std_logic;
		rst        : in std_logic;
        reset_pos  : in std_logic;
    	CHA        : in std_logic;
    	CHB        : in std_logic;
    	obs_period : in std_logic_vector(31 downto 0);
    	speed      : out std_logic_vector(23 downto 0); --Posicion para el calculo de velocidad
    	position   : out std_logic_vector(23 downto 0); --Posicion
    	update     : out std_logic);                    --Señal de actualizacion para la interrupcion

end entity ; -- axi_motor_enc

architecture rtl of axi_motor_enc is

    component contador_periodo is
        port(
            clk        : in std_logic;
            rst        : in std_logic;
            obs_period : in std_logic_vector(31 downto 0);
            period_end : out std_logic);

    end component contador_periodo;

	component Filtro_Digital is
		port(
            clk         : in std_logic;
			rst         : in std_logic;
			CHA         : in std_logic;
    		CHB         : in std_logic;
    		CHA_out     : out std_logic; 
            CHB_out     : out std_logic);

	end component Filtro_Digital;

	component FSM is
		port(
            clk         : in std_logic;
			rst         : in std_logic;
			CHA         : in std_logic;
    		CHB         : in std_logic;
    		pos_cnt_en  : out std_logic;
    		pos_cnt_dir : out std_logic;
    		cambio      : out std_logic);

	end component FSM;

	component contador_posicion is
        port(
            clk         : in std_logic;
			rst         : in std_logic;
            reset_pos   : in std_logic;
        	pos_cnt_en  : in std_logic;
        	pos_cnt_dir : in std_logic;
        	pos_cnt_clr : in std_logic;
        	cambio      : in std_logic;
        	pos_cnt     : out std_logic_vector(23 downto 0);
        	speed       : out std_logic_vector(23 downto 0);
            speed_vld   : out std_logic);

    end component contador_posicion;



	signal CHA_i         : std_logic;
	signal CHB_i         : std_logic;
	signal period_end_i  : std_logic;
	signal pos_cnt_en_i  : std_logic;
    signal pos_cnt_dir_i : std_logic;
	signal pos_cnt_i     : std_logic_vector(23 downto 0);
	signal cambio_i      : std_logic;
	signal speed_i       : std_logic_vector(23 downto 0);
    signal speed_vld_i   : std_logic;

	

begin

    Conexion_contador_periodo : contador_periodo
        port map(
            clk         => clk,
            rst         => rst,
            obs_period  => obs_period,
            period_end  => period_end_i);
    

    Conexion_Filtro_Digital : Filtro_Digital
        port map(
            clk         => clk,
            rst         => rst,
            CHA         => CHA,
    		CHB         => CHB,
    		CHA_out     => CHA_i,
    		CHB_out     => CHB_i);


    Conexion_FSM : FSM
        port map(
            clk         => clk,
            rst         => rst,
            CHA         => CHA_i,
    		CHB         => CHB_i,
    		pos_cnt_en  => pos_cnt_en_i,
    		pos_cnt_dir => pos_cnt_dir_i,
    		cambio      => cambio_i);

    Conexion_contador_posicion : contador_posicion
        port map(
            clk         => clk,
            rst         => rst,
            reset_pos   => reset_pos,
        	pos_cnt_en  => pos_cnt_en_i,
        	pos_cnt_dir => pos_cnt_dir_i,
        	pos_cnt_clr => period_end_i,
        	cambio      => cambio_i,
        	pos_cnt     => position,
        	speed       => speed,
            speed_vld   => speed_vld_i);

    update   <= speed_vld_i;
    

end architecture ; -- rtl