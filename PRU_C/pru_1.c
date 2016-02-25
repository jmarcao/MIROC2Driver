/*
E-FIRE Senior Design Project, Boston University
John Marcao

This is th C file used by the TI CGT to compile into PRU_1 intructions.
*/

/* the registers for I/O and interrupts */
#define XID_SCRATCH 10

#define GPIO_0 0x44e07000  // Refer to AM335x TRM
#define GPIO_1 0x4804c000  // Table 2-2 Peripheral Map
#define GPIO_2 0x481ac000
#define GPIO_3 0x481ae000

volatile register unsigned int __R31, __R30;
unsigned int addr;

int main()
{
   while(1){
      // Wait for Trigger Inputs
      while(__R31 & 0x000C){  // Check if any of the inputs are high.
         addr = __R31;  // Store the value of R31 into the Address variable
         __asm__ __volatile__
         (
            
         );

      }    
   }
    __halt();      // halt the PRU
}
