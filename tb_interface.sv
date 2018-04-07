`include "ddr_pkg.pkg"

interface tb_interface(ddr_interface ddr_intf, ctrl_interface ctrl_intf);
  
  bit CK_t, CK_c; 
  bit[2:0] tCCD; 
  write_data rd_data; 
  write_data wr_data;
  bit[63:0] dimm_data;
  host_address phy_addr; 
  logic[2:0] request; 
  bit[2:0] CL; 
  bit[2:0] BL; 
  bit[1:0] AL;
  bit[2:0] CWL; 
  bit RD_PRE; 
  bit WR_PRE;
  bit mrs_update; 
  bit cmd_rdy; 
  bit rw_proc; 
  bit busy; 
  bit rd_start; 
  logic[2:0] dimm_req;
  event config_done;
  
  
  //assign cmd_rdy = ctrl_intf.act_idle; 
   
  clocking dut_cb@(posedge ddr_intf.CK_t); 
    input wr_data; 
    input request;
    input phy_addr; 
    input CL; 
    input AL; 
    input BL; 
    input CWL; 
    input RD_PRE; 
    input WR_PRE; 
    input mrs_update;
    input rd_data; 
    input rd_start; 
  endclocking
  
  
  clocking driver_cb@(negedge ddr_intf.CK_t); 
    input rd_data; 
    output wr_data; 
    output request; 
    output phy_addr; 
    output CL; 
    output AL;
    output BL; 
    output CWL; 
    output RD_PRE; 
    output WR_PRE; 
    output mrs_update; 
    input rd_start; 
  endclocking 
  
  
  
  clocking monitor_cb@(negedge ddr_intf.CK_t);  
    input wr_data; 
    input request;
    input phy_addr; 
    input CL; 
    input AL; 
    input BL; 
    input CWL; 
    input RD_PRE; 
    input WR_PRE; 
    input mrs_update;
    input rd_data; 
    input rd_start; 
  endclocking 
  
  
  modport MONITOR(clocking monitor_cb); 
  
  modport DRIVER(clocking driver_cb); 
   
endinterface 


