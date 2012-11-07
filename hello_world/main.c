#include "omsp_system.h"
#include<inttypes.h>

void delay(uint32_t del)
{
	volatile uint32_t i;
	for(i=0;i<del;i++)
	{
		nop();
		nop();
	}
}

/**
Main function with a blinking LED
*/
int main(void) 
{
	WDTCTL = WDTPW + WDTHOLD;          // Disable watchdog timer
	volatile uint16_t* led_port = (volatile uint16_t*)(0x00);
	
    while (1) 
    {                         
				
		*led_port = 0x00;
		delay(100000);
		*led_port = 0x01;
		delay(200000);

    }
	return 0;
    
}
