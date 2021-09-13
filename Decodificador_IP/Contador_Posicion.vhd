library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_posicion is
  port (
		clk         : in std_logic;
		rst         : in std_logic;
    reset_pos   : in std_logic;                       --Señal de reset de posicion(Registro)
    pos_cnt_en  : in std_logic;
    pos_cnt_dir : in std_logic;
    pos_cnt_clr : in std_logic;
    cambio      : in std_logic;                       --Pulso de deteccion de cambio de sentido
    pos_cnt     : out std_logic_vector(23 downto 0);  --Posicion del motor
    speed       : out std_logic_vector(23 downto 0); --Posicion para el calculo de velocidad
    speed_vld   : out std_logic);
		
end entity ; -- contador_posicion

architecture rtl of contador_posicion is
    
    signal pos_cnt_i : unsigned(22 downto 0);
    signal speed_i   : unsigned(22 downto 0);
    signal speed_reg : unsigned(22 downto 0);
    signal sped_vld_i  : std_logic;

	
begin

    Contador_velocidad : process (clk) is     
    begin  -- process
     if(clk = '1' and clk'event) then
        if(rst = '1' or pos_cnt_clr = '1' or cambio = '1') then --Si detecta un reset, un cambio de direccion o fin de periodo de muestreo 
           speed_i <= (others => '0');                          --Se pone a 0
     	  elsif(pos_cnt_en = '1') then                            --En cada flanco detectado
            if(pos_cnt_i < 8388597) then                      
              speed_i <= speed_i + 1;                           --Se actualiza la posicion
            end if;                                  
        end if;
     end if;

	end process;

    Registro_Velocidad: process (clk) is     
    begin  -- process
     if(clk = '1' and clk'event) then
        if(rst = '1') then 
           speed_reg <= (others => '0'); 
           sped_vld_i  <= '0';
        else
          if(pos_cnt_clr = '1' or cambio = '1') then                    
            speed_reg <= speed_i;
            sped_vld_i  <= '1';
          else
            sped_vld_i  <= '0';
          end if;                               
        end if;
     end if;

  end process;


	Contador : process (clk) is
    begin  -- process
     if(clk = '1' and clk'event) then
        if(rst = '1' or reset_pos = '1') then
            pos_cnt_i <= (others => '0');
        elsif(pos_cnt_en = '1') then           --Al detactar el flanco
     	    if(pos_cnt_dir = '0') then               --Si gira a la derecha
              if(pos_cnt_i < 8388597) then    --Si no ha llegado al limite, todo 1
                  pos_cnt_i <= pos_cnt_i + 1; --Se incrementa la posicion
              end if;
          else                                --Si gira a la izquierda
        	    if(pos_cnt_i > 0) then          --Si no ha llegado al limite
                  pos_cnt_i <= pos_cnt_i - 1; --Se decrementa la posicion
              end if;
          end if;
        end if;
    end if;

	end process;

	speed     <= pos_cnt_dir & std_logic_vector(speed_reg);   --Se añade la direccion en el último bit
  pos_cnt   <= pos_cnt_dir & std_logic_vector(pos_cnt_i); --Se añade la direccion en el último bit
  speed_vld <= sped_vld_i;

end architecture ; -- rtl
