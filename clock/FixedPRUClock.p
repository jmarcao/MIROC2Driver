// EFIRE Senior Design Project, Boston University
// John Marcao
// PRU file for controlling a clock under various conditions
// This file has been adapted from Derek Molloy's book "Exploring BeagleBone Black"
// *ONLY FOR TESTING PURPOSES*
// This verision outputs a clock at P9_31 when P8_14 is high
// Ideal clock is 1 MHz, but testing shows 840 kHz
// This can be fixed by adjusting the DELAY variable 

.origin 0                        // start of program in PRU memory
.entrypoint START                // program entry point (for a debugger)

#define	DELAY   47  		 // choose the delay value to suit the frequency required							 // 1 gives a 20MHz clock signal, increase from there
#define GPIO_0 0x44e07000	// Refer to AM335x TRM
#define GPIO_1 0x4804c000	// Table 2-2 Peripheral Map
#define GPIO_2 0x481ac000
#define GPIO_3 0x481ae000
#define GPIO_CLEARDATAOUT 0x190 // For clearing GPIO registers to 0
#define GPIO_SETDATAOUT 0x194 // For setting GPIO registers to 1
#define GPIO_DATAOUT 0x138// For reading the GPIO registers
#define GPIO_0_26 1<<26	// P8_14 Trigger Input, bit 26 of GPIO Bank 0

START:
	// Enable OCP Master Port. This is needed to allow the PRU direct memory acess
	LBCO	r0, C4, 4, 4	// Load SYSCFG reg into r0 (using c4 const addr)
	CLR 	r0, r0, 4		// Clear bit 4 (STANDBY_INIT)
	SBCO	r0, C4, 4, 4	// Store the modified r0 back at the load addr
	MOV	r1, DELAY	 // load the DELAY value into r1																		

MAINLOOP:
	CLR	r30.t0		// set the clock to be low
	CLR	r30.t0		// set the clock to be low -- to balance the duty cycle
	MOV	r0, r1		// load the delay r1 into temp r0 (50% duty cycle)
	MOV r2, GPIO_0 | GPIO_DATAOUT // Load the data from GPIO-0 to r2
	LBBO r3, r2, 0, 4	// Load the values at r2 to r3
	QBBC MAINLOOP, r3.t26	// Jump to MAINLOOP if r3 is clear (0)

DELAYOFF:
	SUB	r0, r0, 1	// decrement the counter by 1 and loop (next line)
	QBNE	DELAYOFF, r0, 0	// loop until the delay has expired (equals 0)
	SET	r30.t0		// set the clock to be high
	MOV	r0, r1		// re-load the delay r1 into temporary r0

DELAYON:
	SUB	r0, r0, 1	// decrement the counter by 1 and loop (next line)
	QBNE	DELAYON, r0, 0	// loop until the delay has expired (equals 0)
	QBA	MAINLOOP	// start again, so the program will not exit

END:
	HALT			// halt the pru program -- never reached