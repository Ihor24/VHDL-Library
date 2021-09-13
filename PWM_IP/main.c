#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <sleep.h>
#include <xparameters.h>

/////////////////////////////////////PWM//////////////////////////////////////////////////////////////
// Register indexes PWM
#define PWM_CTRL_REG_INDEX    0
#define PWM_PERIOD_REG_INDEX  1
#define DUTY_CYCLE_REG_INDEX  2
#define DEADTIME_REG_INDEX    3
//Bit Mask PWM
#define PWM_RST               0x01
#define PWM_ENABLE            0x02
#define DEADTIME_ENABLE       0x04
//Related to PWM
#define AXI_CLK_FREQ_HZ       100000000
#define PWM_FREQ_HZ           10000

#define LEFT_TURN             0x80000000
#define RIGHT_TURN            0x7FFFFFFF


//Declaracion de registros
volatile uint32_t *reg = (volatile uint32_t *) XPAR_AXI_PWM_GENERATOR_0_S_AXI_BASEADDR; //To acess to PWM Registers

//Global Variables
uint32_t dc_code;                //Variable que se escribe en el registro de Duty-Cycle
uint32_t period_code;            //Periode of PWM

void set_PWM()
{

  reg[PWM_CTRL_REG_INDEX] |= PWM_RST;            //Reset PWM
  reg[PWM_CTRL_REG_INDEX] &= ~PWM_ENABLE;        //Disable PWM
  reg[PWM_CTRL_REG_INDEX] &= ~DEADTIME_ENABLE;   //Disable Deadtime

  period_code = (AXI_CLK_FREQ_HZ/PWM_FREQ_HZ)-1;
  reg[PWM_PERIOD_REG_INDEX] = (period_code<<4);  //Set PWM Period
  reg[DUTY_CYCLE_REG_INDEX] = 0;                 //Duty-Cycle 0

  reg[DEADTIME_REG_INDEX] = (0x000F<<12);        //Set Deadtime 15

  reg[PWM_CTRL_REG_INDEX] &= ~PWM_RST;           //Release the reset
  reg[PWM_CTRL_REG_INDEX] |= PWM_ENABLE;         //Enable PWM
  reg[PWM_CTRL_REG_INDEX] |= DEADTIME_ENABLE;    //Enable Deadtime
}

void PWM_Duty_Cycle(float duty_cycle)
{

  dc_code = (uint32_t) (period_code*duty_cycle);
  reg[DUTY_CYCLE_REG_INDEX] = (dc_code<<8);
}

void set_left_turn_direction()
{

  reg[PWM_PERIOD_REG_INDEX] |= (LEFT_TURN); //Set left turn direction
}

void set_right_turn_direction()
{

  reg[PWM_PERIOD_REG_INDEX] &= (RIGHT_TURN); //Set right turn direction
}

void cambio(float valor)
{

  if(valor < 0)
  {
	set_left_turn_direction();
  }
  else
  {
	set_right_turn_direction();
  }

  valor = fabs(valor);

  PWM_Duty_Cycle(valor);

}

int main()
{

  set_PWM();  //Configurate PWM IP

  cambio(0.5);//Cambio PWM por la UART
  cambio(1);
  cambio(0.5);

  cambio(-0.5);
  cambio(-1);
  cambio(-0.5);

  cambio(0.5);

  return 0;
}
