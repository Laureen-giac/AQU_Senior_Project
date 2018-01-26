`include "ddr_pkg.pkg"

interface tb_interface(ddr_interface ddr_intf); 
  
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
  
  clocking driver_cb@(posedge ddr_intf.CK_t); 
    input rd_data; 
    output cmd_rdy; 
    output wr_data; 
    output request; 
    output log_addr; 
    output CL; 
    output AL;
    output BL; 
    output CWL; 
    output RD_PRE; 
    output WR_PRE; 
    output mrs_update;  
  endclocking 
  
  
  clocking monitor_cb@(posedge ddr_intf.CK_t); 
    input wr_data; 
    input cmd_rdy; 
    input request;
    input log_addr; 
    input CL; 
    input AL; 
    input BL; 
    input CWL; 
    input RD_PRE; 
    input WR_PRE; 
    input mrs_update;
    output rd_data; 
  endclocking 
  
  
  modport MONITOR(clocking monitor_cb); 
  
  modport DRIVER(clocking driver_cb); 
    
endinterface 


