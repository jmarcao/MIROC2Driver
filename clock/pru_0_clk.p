// EFIRE Senior Design Project, Boston University
// John Marcao
// PRU file for controlling a clock under various conditions
// This file has been adapted from Derek Molloy's book "Exploring BeagleBone Black"
// *ONLY FOR TESTING PURPOSES*

.origin 0                        // start of program in PRU memory
.entrypoint START                // program entry point (for a debugger)

#define	DELAY   47  		 // choose the delay value to suit the frequency required							 // 1 gives a 20MHz clock signal, increase from there
#define START_CYCLES 2
#define ADC_CYCLES 19

START:
	// Enable OCP Master Port. This is needed to allow the PRU direct memory access to GPIOs
	LBCO	r0, C4, 4, 4	// Load SYSCFG reg into r0 (using c4 const addr)
	CLR 	r0, r0, 4		// Clear bit 4 (STANDBY_INIT)
	SBCO	r0, C4, 4, 4	// Store the modified r0 back at the load addr

	// Load the Constants needed for operation
	MOV	r1, DELAY	 // load the DELAY value into r1
	MOV	r2, START_CYCLES	// Load the Start Cycle count into r2
	MOV r3, ADC_CYCLES	// Load the ADC cycle count into r3
	//CLR r30 // Clear all outputs			
	ZERO &r20, 4 // Clear r20			

MAINLOOP:
	XIN 10, r20, b3
	QBEQ MAINLOOP, r20.b3, 0

	MOV	r2, START_CYCLES
	MOV r3, ADC_CYCLES
	QBEQ ENABLESTART_0, r2, START_CYCLES // Jump to Enable Start 0
	
STARTCLOCK:
	MOV	r0, r1		// load the delay r1 into temp r0
	SET r30.t0		// Set the clock to be high

DELAYON:
	SUB	r0, r0, 1	// decrement the counter by 1 and loop (next line)
	QBNE	DELAYON, r0, 0	// loop until the delay has expired (equals 0)
	MOV	r0, r1		// re-load the delay r1 into temporary r0
	CLR r30.t0 // Set the clock to be low
	
DELAYOFF:
	SUB	r0, r0, 1	// decrement the counter by 1 and loop (next line)
	QBNE	DELAYOFF, r0, 0	// loop until the delay has expired (equals 0)
	MOV	r0, r1		// re-load the delay r1 into temporary r0
	SUB r2, r2, 1	// Decrement the two counters
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
