# DDR4 SDRAM Memory Controller 

Senior project at Al Quds University to design and verify a memory controller that adheres to the JEDEC specification of a DDR4 SDRAM. It implements the basic DRAM tasks, plus an assertion-based randomized verification environment that emulates a system host. 


### Prerequisites

Verilog/SystemVerilog Simulator 

```
Synpsys VCS, Cadence Xcelium/Incisive, Mentor Questa.
```

### Installing

Download and Copy project files to desired working directory. 
	
## Compile/Simulation 

#### EDA Playground:
1. Open www.edaplayground.com 
2. Create a new empty playground. 
3. Upload all project files. 
4. Select Synopsys VCS as Simulator 
5. Use default Compile/run options: -timescale=1ns/1ns +vcs+flush+all +warn=all -sverilog

#### Cadence Incisive Simulator:
 1. Use the following Compile/run options: xrun tb_top.sv -sv +access-rw 


## Authors

* **Laureen Giacaman**  - [Laureen-giac](https://github.com/Laureen-giac)
* **Diana Atiyeh** - [Diana955](https://github.com/Diana955)

## Acknowledgments

* Dr. Emad Hamadeh 
