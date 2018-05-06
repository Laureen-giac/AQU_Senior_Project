# DDR4 SDRAM Memory Controller 

Senior project at Al Quds University to design and verify a memory controller that adheres to the JEDEC specification of a DDR4 SDRAM. It implements the basic DRAM tasks, plus an assertion-based randomized verification environment that emulates a system host. 


### Prerequisites

Verilog/SystemVerilog Simulator 

```
Synpsys VCS, Cadence Xcelium/Incisive, Mentor Questa.
```

### Installing

Download and Copy project files to desired working directory. 
	
## Running the tests

1. Setup project environment on EDA Playground 
	a. Open www.edaplayground.com 
	b. Create a new empty playground. 
	c. Upload all project files. 
	

2. Compile/Run Simulation
	a. Select Synopsys VCS as Simulator 
	b. Use default Compile/run options: -timescale=1ns/1ns +vcs+flush+all +warn=all -sverilog
	
3. To run the project with Cadence Xcelium: 
	a. Use the following Compile/run options: xrun tb_top.sv -sv +access-rw 


## Authors

* **Laureen Giacaman**  - [PurpleBooth](https://github.com/Laureen-giac)
* **Diana Atiyeh** -[PurpleBooth] (https://github.com/Diana955)


## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Dr. Emad Hamadeh 
