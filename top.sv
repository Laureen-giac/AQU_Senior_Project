`include "ctrl_clk_gen.sv"
`include "ctrl_init.sv"
`include "ctrl_cmds.sv"
`include "ctrl_fsm.sv"
`include "ctrl_burst_cas.sv"
`include "ctrl_refresh.sv"
`include "ctrl_burst_act.sv"
`include "ctrl_rw.sv"
`include "ctrl_write_data.sv"
`include "dimm_model.sv"
`include "ctrl_rd_data.sv"
`include "ddr_interface.sv"
`include "tb_interface.sv"
`include "ctrl_interface.sv"
`include "assertions.sv"



module top(ctrl_interface ctrl_intf, ddr_interface ddr_intf, tb_interface tb_intf); 
  
  ctrl_clk_gen clk(ddr_intf); 
  
  ctrl_fsm fsm(ctrl_intf, ddr_intf, tb_intf);
  
  ctrl_init init (ctrl_intf, ddr_intf, tb_intf); 
  
  ctrl_cmds cmds (ctrl_intf, ddr_intf, tb_intf); 
  
  ctrl_burst_cas cas(ctrl_intf, ddr_intf); 
  
  ctrl_refresh refresh(ctrl_intf, ddr_intf); 
  
  ctrl_burst_act act(ctrl_intf, ddr_intf, tb_intf); 
  
  ctrl_rw rw(ctrl_intf, ddr_intf); 
  
  ctrl_write_data wr_data(.ctrl_intf(ctrl_intf), .ddr_intf(ddr_intf), .tb_intf(tb_intf));
  
  ctrl_rd_data rd_data(ddr_intf, ctrl_intf); 
  
  dimm_model mem_model(ddr_intf, ctrl_intf, tb_intf); 
  
  assertions assertion(.ddr_intf(ddr_intf), .ctrl_intf(ctrl_intf));
  
  //ctrl_update update(ctrl_intf, ddr_intf, tb_intf); 
  
  

  
endmodule 
