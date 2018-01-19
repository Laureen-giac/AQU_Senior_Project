`include "ctrl_init.sv"
`include "ctrl_cmds.sv"
`include "ctrl_fsm.sv"
`include "ctrl_burst_cas.sv"
`include "ctrl_refresh.sv"

module top(ctrl_interface ctrl_intf, ddr_interface ddr_intf);

  ctrl_fsm fsm(ctrl_intf, ddr_intf);

  ctrl_init init (ctrl_intf, ddr_intf);

  ctrl_cmds cmds (ctrl_intf, ddr_intf);

  ctrl_burst_cas cas(ctrl_intf, ddr_intf);

  ctrl_refresh refresh(ctrl_intf, ddr_intf);


endmodule 
