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
#define START_CYCLES 9
#define ADC_CYCLES 19
#define GPIO_0 0x44e07000	// Refer to AM335x TRM
#define GPIO_1 0x4804c000	// Table 2-2 Peripheral Map
#define GPIO_2 0x481ac000
#define GPIO_3 0x481ae000
#define GPIO_CLEARDATAOUT 0x190 // For clearing GPIO registers to 0
#define GPIO_SETDATAOUT 0x194 // For setting GPIO registers to 1
#define GPIO_DATAOUT 0x138// For reading the GPIO registers
#define GPIO_0_22 1<<22
#define GPIO_0_10 1<<10
#define GPIO_0_11 1<<11
#define GPIO_0_9  1<<9
#define GPIO_0_8  1<<8

START:
	// Enable OCP Master Port. This is needed to allow the PRU direct memory access to GPIOs
	LBCO	r0, C4, 4, 4	// Load SYSCFG reg into r0 (using c4 const addr)
	CLR 	r0, r0, 4		// Clear bit 4 (STANDBY_INIT)
	SBCO	r0, C4, 4, 4	// Store the modified r0 back at the load addr
	MOV	r1, DELAY	 // load the DELAY value into r1
	MOV	r2, START_CYCLES	// Load the Start Cycle count into r2
	MOV r3, ADC_CYCLES	// Load the ADC cycle count into r3	
	CLR r30.t3	// Start off at 0												

MAINLOOP:
	MOV r20, r31.w0		// Store first 16 bits of R31, corresponding to the Trigger inputs
	QBEQ MAINLOOP, r20.w0, 0	// Jumps to MAINLOOP if R2.w0 is clear

	MOV	r2, START_CYCLES
	MOV r3, ADC_CYCLES
	QBEQ ENABLESTART_0, r2, START_CYCLES // Jump to Enable Start 0
	
STARTCLOCK:
	MOV	r0, r1		// load the delay r1 into temp r0 (50% duty cycle)
	SET r30.t0	// Set the clock to be high

DELAYON:
	SUB	r0, r0, 1	// decrement the counter by 1 and loop (next line)
	QBNE	DELAYON, r0, 0	// loop until the delay has expired (equals 0)
	MOV	r0, r1		// re-load the delay r1 into temporary r0
	CLR r30.t0 // Set the clock to be low
	
DELAYOFF:
	SUB	r0, r0, 1	// decrement the counter by 1 and loop (next line)
	QBNE	DELAYOFF, r0, 0	// loop until the delay has expired (equals 0)
	MOV	r0, r1		// re-load the delay r1 into temporary r0
	SUB r2, r2, 1
	SUB r3, r3, 1
	QBEQ DISABLESTART_0, r2, 0
	QBEQ DISABLECLOCK_0, r3, 0
	QBA	STARTCLOCK	// start again, so the program will not exit

END:
	HALT			// halt the pru program -- never reached

ENABLESTART_0:
	SET r30.t3
	QBA STARTCLOCK

DISABLESTART_0:
	CLR r30.t3
	QBA STARTCLOCK

DISABLECLOCK_0:
	CLR r30.t0
	QBA MAINLOOP
