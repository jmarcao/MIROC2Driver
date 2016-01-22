# MIROC2Driver
Repository storing the MIROC2 driver software.

The goals of the driver are to

- Interface directly with MIROC2
	- Data In
		- Diode Strike Trigger
		- 8bit Serial
	- Data Out
		- ADC Select
		- ADC Clock
		- P&H Reset
		- START Signal
- Pipe data to main program
- Save data to CSV if main program is not running or pipe is closed.