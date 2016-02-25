/** Program to generate a simple PWM signal using the BBB PRU-ICSS
* Written by Derek Molloy for the book "Exploring BeagleBone: Tools and 
* Techniques for Building with Embedded Linux" by John Wiley & Sons, 2014
* ISBN 9781118935125. Please see the file README.md in the repository root 
* directory for copyright and GNU GPLv3 license information.            */

#include <stdio.h>
#include <stdlib.h>
#include <prussdrv.h>
#include <pruss_intc_mapping.h>

#define PRU_0 	0
#define PRU_1  1

int main (void)
{
   int n, ret;
   if(getuid()!=0){
      printf("You must run this program as root. Exiting.\n");
      exit(EXIT_FAILURE);
   }
   /* Initialize structure used by prussdrv_pruintc_intc   */
   /* PRUSS_INTC_INITDATA is found in pruss_intc_mapping.h */
   tpruss_intc_initdata pruss_intc_initdata = PRUSS_INTC_INITDATA;

   /* Allocate and initialize memory */
   prussdrv_init ();
   ret = prussdrv_open (PRU_EVTOUT_0);
   if(ret){
      printf("Failed to open the PRU-ICSS, have you loaded the overlay?");
      exit(EXIT_FAILURE);
   }
   
   prussdrv_pruintc_init(&pruss_intc_initdata);

/*********************************
Load Data for PRU_0
**********************************/
   /* Load the memory data file */
   prussdrv_load_datafile(PRU_0, "./data_0.bin");
   /* Load and execute binary on PRU */
   prussdrv_exec_program (PRU_0, "./text_0.bin");

/*********************************
Load Data for PRU_1
**********************************/
   /* Load the memory data file */
   prussdrv_load_datafile(PRU_1, "./data_1.bin");
   /* Load and execute binary on PRU */
   prussdrv_exec_program (PRU_1, "./text_1.bin");


   /* Wait for event completion from PRU */
   n = prussdrv_pru_wait_event (PRU_EVTOUT_0);  // This assumes the PRU generates an interrupt
                                                    // connected to event out 0 immediately before halting
   printf("PRU program completed, event number %d.\n", n);

   /* Disable PRU and close memory mappings */
   prussdrv_pru_disable(PRU_0);
   prussdrv_pru_disable(PRU_1);
   prussdrv_exit ();
   return(EXIT_SUCCESS);
}
