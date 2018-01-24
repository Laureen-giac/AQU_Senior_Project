`include "ddr_pkg.pkg"

interface tb_interface; 
  
  bit[63:0] rd_data; 
  write_data wr_data; 
  host_address log_addr; 
  bit[2:0] request; 
  bit[2:0] CL; 
  bit[2:0] BL; 
  bit[2:0] AL;
  bit[2:0] CWL; 
  bit RD_PRE; 
  bit WR_PRE;
  bit mrs_update; 
  bit cmd_rdy; 
  
  
endinterface 


