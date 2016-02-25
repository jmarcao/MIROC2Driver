/*
E-FIRE Senior Design Project, Boston University
John Marcao

This is th C file used by the TI CGT to compile into PRU_0 intructions.
*/

/* the registers for I/O and interrupts */

#define XID_SCRATCH 10
#define GPIO_0 0x44e07000  // Refer to AM335x TRM
#define GPIO_1 0x4804c000  // Table 2-2 Peripheral Map
#define GPIO_2 0x481ac000
#define GPIO_3 0x481ae000

volatile register unsigned int __R31, __R30;

unsigned int i;                  // the counter in the time delay
unsigned int delay = 1;     // the delay (manually determined)
unsigned int triggers;

int main()
{
  // Enable the OCP Master Port for Global Mem Access
  // CT_CFG.SYSCFG_bit.STANDBY_INIT = 0;

   // Wait for a Trigger
   
   while(__R31 & 1<<14){   // Waits for one of the trigger pins to go High
       __R30 = __R30 | 1<<1;         // Turn on CLK0 (r30.1)
      for(i=0; i<delay; i++) {}     // sleep for the delay
      __R30 = __R30 & 0<<1;         // Turn off CLK0 (r30.1)
      for(i=0; i<delay; i++) {}     // sleep for the delay
   }

  // unsigned int test_num = 9;
 //  unsigned int* test_numPtr = 0xC0000000;
  // *test_numPtr = test_num;

   // Exiting the application - send the interrupt
   __R31 = 35;                      // PRUEVENT_0 on PRU0_R31_VEC_VALID
   __halt();                        // halt the PRU
}
