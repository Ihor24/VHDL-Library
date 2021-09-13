library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FSM is
  port (
	  clk         : in std_logic;
	  rst         : in std_logic;
    CHA         : in std_logic;   --Señal A filtrada
    CHB         : in std_logic;   --Señal B filtrada
    pos_cnt_en  : out std_logic;  --Sañal de incremento del contador
    pos_cnt_dir : out std_logic;  --Señal de direccion de giro
    cambio      : out std_logic); --Señal de deteccion de cambio de direccion

end entity ; -- FSM

architecture rtl of FSM is

  signal pos_cnt_dir_i : std_logic;
  signal pos_cnt_i     : unsigned(1 downto 0);

  signal cambio_1      : std_logic;
  signal cambio_up     : std_logic;
  signal cambio_down   : std_logic;

	signal CHA_1         : std_logic;
	signal CHB_1         : std_logic;

	signal up_A          : std_logic;
	signal down_A        : std_logic;
	signal up_B          : std_logic;
	signal down_B        : std_logic;

  type stateFSM is (S1,S2,S3,S4); --Creaccion de estados
  signal state : stateFSM ;  -- estado de la maquina secuencial

begin
  
    pos_cnt_i <= CHA & CHB;  --Contador de combinaciones del encoder
    
    process (clk, rst) is
    begin  -- process
    if (rst = '1') then                  --Lo inicializo en el estado S1 
        state <= S1;   
        pos_cnt_dir_i <= '0';   
    elsif (clk = '1' and clk'event) then 
      case state is
        when S1 =>
        if (pos_cnt_i="10")then           --Si la combinacion se cumple pasa al figuiente estado
          state <= S2;
          pos_cnt_dir_i <= '0';
        elsif(pos_cnt_i="01") then        --Si va al reves, pasa al estado anterior
          state <= S4;
          pos_cnt_dir_i <= '1';
        end if;
        when S2 =>
        if (pos_cnt_i="11")then 
          state <= S3;
          pos_cnt_dir_i <= '0';
        elsif(pos_cnt_i="00") then
          state <= S1;
          pos_cnt_dir_i <= '1';
        end if;
        when S3 =>
        if (pos_cnt_i="01")then
          state <= S4;
          pos_cnt_dir_i <= '0';
        elsif(pos_cnt_i="10") then
          state <= S2;
          pos_cnt_dir_i <= '1';
        end if;
        when S4 =>
        if (pos_cnt_i="00")then
          state <= S1;
          pos_cnt_dir_i <= '0';
        elsif(pos_cnt_i="11") then
          state <= S3;
          pos_cnt_dir_i <= '1';
        end if;
      end case ;
    end if;
  end process;

  Cabio_direccion : process (clk) is
    begin  -- process
     if(clk = '1' and clk'event) then
      if(rst = '1') then                                --Puesta de todas las señales a 0
        cambio_1    <= '0';
        cambio_up   <= '0';
        cambio_down <= '0';
      else
        cambio_1    <= pos_cnt_dir_i;                   --Señal del contador retrasada
        cambio_up   <= not(cambio_1) and pos_cnt_dir_i; --Detector de flanco de subida
        cambio_down <= cambio_1 and not(pos_cnt_dir_i); --Detector de flanco de bajada
      end if;
    end if;

  end process;
  

	Biestable_A : process (clk) is
    begin  -- process
     if(clk = '1' and clk'event) then
      if(rst = '1') then                 --Puesta de todas las señales a 0
        CHA_1  <= '0';
        up_A   <= '0';
        down_A <= '0';
      else
        CHA_1  <= CHA;                   --Señal encoder A retrasada
        up_A   <= not(CHA_1) and CHA;    --Detector de flanco de subida
        down_A <= CHA_1 and not(CHA);    --Detector de flanco de bajada
      end if;
    end if;

	end process;

	Biestable_B : process (clk, rst, CHB) is
    begin  -- process
     if(clk = '1' and clk'event) then
      if(rst = '1') then                --Puesta de todas las señales a 0
        CHB_1  <= '0';
        up_B   <= '0';
        down_B <= '0';
      else
        CHB_1  <= CHB;                 --Señal encoder B retrasada
        up_B   <= not(CHB_1) and CHB;  --Detector de flanco de subida
        down_B <= CHB_1 and not(CHB);  --Detector de flanco de bajada
      end if;
    end if;

	end process;


  pos_cnt_en  <= up_A or up_B or down_A or down_B; --Si alguna está a 1, se pone a 1 el incremento del contador
  pos_cnt_dir <= pos_cnt_dir_i;                    --Se devuelve la direccion de giro
  cambio      <= cambio_up or cambio_down;         --Se devuelve los cambios de direccion detectados
    

end architecture ; -- rtl