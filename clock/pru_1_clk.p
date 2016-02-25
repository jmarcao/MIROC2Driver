// EFIRE Senior Design Project, Boston University
// John Marcao
// PRU file for controlling a clock under various conditions
// This file has been adapted from Derek Molloy's book "Exploring BeagleBone Black"
// *ONLY FOR TESTING PURPOSES*

.origin 0                        // start of program in PRU memory
.entrypoint START                // program entry point (for a debugger)

#define GPIO_0 0x44e07000	// Refer to AM335x TRM
#define GPIO_1 0x4804c000	// Table 2-2 Peripheral Map
#define GPIO_2 0x481ac000
#define GPIO_3 0x481ae000
#define GPIO_CLEARDATAOUT 0x190 // For clearing GPIO registers to 0
#define GPIO_SETDATAOUT 0x194 // For setting GPIO registers to 1
#define GPIO_DATAOUT 0x138// For reading the GPIO register
#define ADDR_0 1<<22	//P8.19
#define ADDR_1 1<<10	//P8.31
#define ADDR_2 1<<11	//p8.32
#define ADDR_3 1<<9		//p8.33
#define ADDR_4 1<<8		//p8.34

#define XID_SCRATCH 10


START:
	// Enable OCP Master Port. This is needed to allow the PRU direct memory access to GPIOs
	LBCO	r0, C4, 4, 4	// Load SYSCFG reg into r0 (using c4 const addr)
	CLR 	r0, r0, 4		// Clear bit 4 (STANDBY_INIT)
	SBCO	r0, C4, 4, 4	// Store the modified r0 back at the load addr			

	// Load Values for GPIO Manipulaion. This will be what Controls the ADDR Pins
	MOV r1, GPIO_0 | GPIO_CLEARDATAOUT
	MOV r2, GPIO_0 | GPIO_SETDATAOUT
	MOV r3, ADDR_0
	MOV r4, ADDR_1
	MOV r5, ADDR_2
	MOV r6, ADDR_3
	MOV r7, ADDR_4

MAINLOOP:
	MOV r20.b3, 0000	// Tell PRU0 there is no trigger
	XOUT 10, r20, b3
	MOV r25, r31.w0	// Load the trigger values. Only expecting 1 trigger at a time due to BI-207 decay rate
					// If two triggers are detected, the LSB is taken and calculated.
	QBEQ EMPTY, r25, 0	// Clear ADDR pins if there is no trigger.
						// Note that this is NOT the final intended action. In the final product, the ADDR will on be erased
						// when the PRU is done utilizing it.
	SET r20.t31	// Copy contents of r25, trigger pins, to r20
	XOUT 10, r20, b3	// Write r20.b3 to scratchpad
	// Jumps to Specific Channel reading the bit from LSB to MSB.
	QBBS CHANNEL0, r25.t0
	QBBS CHANNEL1, r25.t1
	QBBS CHANNEL2, r25.t2
	QBBS CHANNEL3, r25.t3
	QBBS CHANNEL4, r25.t4
	QBBS CHANNEL5, r25.t5
	QBBS CHANNEL6, r25.t6
	QBBS CHANNEL7, r25.t7
	QBBS CHANNEL8, r25.t8
	QBBS CHANNEL9, r25.t9
	QBBS CHANNEL10, r25.t10
	QBBS CHANNEL11, r25.t11
	QBA MAINLOOP // Go back to Start

END:
	HALT			// halt the pru program -- never reached
					// Halt command is retained for security.

// Note that the below code can be optimized.
// There is a lot of repition of setting pins low and high
// I will research a way to improve this method.
EMPTY:	// Sets the ADDR Pins Low
	SBBO r3, r1, 0, 4
	SBBO r4, r1, 0, 4		// NOTE: On the MIROC2, the pins will be set to 11111 when there is no trigger
	SBBO r5, r1, 0, 4		// They are set to 00000 in the test version of the software just to make it easier to read.
	SBBO r6, r1, 0, 4
	SBBO r7, r1, 0, 4
	QBA MAINLOOP
CHANNEL0:
	SBBO r3, r1, 0, 4
	SBBO r4, r1, 0, 4
	SBBO r5, r1, 0, 4
	SBBO r6, r1, 0, 4
//	SBBO r7, r1, 0, 4
	QBA MAINLOOP
CHANNEL1:
	SBBO r3, r2, 0, 4
	SBBO r4, r1, 0, 4
	SBBO r5, r1, 0, 4
	SBBO r6, r1, 0, 4
	//SBBO r7, r1, 0, 4
	QBA MAINLOOP
CHANNEL2:
	SBBO r3, r1, 0, 4
	SBBO r4, r2, 0, 4
	SBBO r5, r1, 0, 4
	SBBO r6, r1, 0, 4
	//SBBO r7, r1, 0, 4
	QBA MAINLOOP
CHANNEL3:
	SBBO r3, r2, 0, 4
	SBBO r4, r2, 0, 4
	SBBO r5, r1, 0, 4
	SBBO r6, r1, 0, 4
	//SBBO r7, r1, 0, 4
	QBA MAINLOOP
CHANNEL4:
	SBBO r3, r1, 0, 4
	SBBO r4, r1, 0, 4
	SBBO r5, r2, 0, 4
	SBBO r6, r1, 0, 4
	//SBBO r7, r1, 0, 4
	QBA MAINLOOP
CHANNEL5:
	SBBO r3, r2, 0, 4
	SBBO r4, r1, 0, 4
	SBBO r5, r2, 0, 4
	SBBO r6, r1, 0, 4
	//SBBO r7, r1, 0, 4
	QBA MAINLOOP
CHANNEL6:
	SBBO r3, r1, 0, 4
	SBBO r4, r2, 0, 4
	SBBO r5, r2, 0, 4
	SBBO r6, r1, 0, 4
	//SBBO r7, r1, 0, 4
	QBA MAINLOOP
CHANNEL7:
	SBBO r3, r2, 0, 4
	SBBO r4, r2, 0, 4
	SBBO r5, r2, 0, 4
	SBBO r6, r1, 0, 4
	//SBBO r7, r1, 0, 4
	QBA MAINLOOP
CHANNEL8:
	SBBO r3, r1, 0, 4
	SBBO r4, r1, 0, 4
	SBBO r5, r1, 0, 4
	SBBO r6, r2, 0, 4
	//SBBO r7, r1, 0, 4
	QBA MAINLOOP
CHANNEL9:
	SBBO r3, r2, 0, 4
	SBBO r4, r1, 0, 4
	SBBO r5, r1, 0, 4
	SBBO r6, r2, 0, 4
	//SBBO r7, r1, 0, 4
	QBA MAINLOOP
CHANNEL10:
	SBBO r3, r1, 0, 4
	SBBO r4, r2, 0, 4
	SBBO r5, r1, 0, 4
	SBBO r6, r2, 0, 4
	//SBBO r7, r1, 0, 4
	QBA MAINLOOP
CHANNEL11:
	SBBO r3, r2, 0, 4
	SBBO r4, r2, 0, 4
	SBBO r5, r1, 0, 4
	SBBO r6, r2, 0, 4
	//SBBO r7, r1, 0, 4
	QBA MAINLOOP
CHANNEL12:
	SBBO r3, r1, 0, 4
	SBBO r4, r1, 0, 4
	SBBO r5, r2, 0, 4
	SBBO r6, r2, 0, 4
	//SBBO r7, r1, 0, 4
	QBA MAINLOOP
