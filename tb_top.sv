`include "tb_interface.sv"
`include "ddr_interface.sv"
`include "ctrl_interface.sv"
`include "ddr_pkg.pkg"
`include "test.sv"

module tb_top;
  
  ddr_interface ddr_intf();
  ctrl_interface ctrl_intf();
  tb_interface tb_intf(ddr_intf, ctrl_intf); 
  test test1(tb_intf, ddr_intf, ctrl_intf);
  
   initial begin
     @(negedge ddr_intf.CK_t);
     ddr_intf.reset_n <= 1'b0;
     #200us
     ddr_intf.reset_n <= 1'b1; 
     //$monitor("act_idle is %h at %0gns", ctrl_intf.act_idle, $time); 
    // $monitor("dimm_req %h", tb_intf.cmd_rdy); 
    //$monitor("index has %h", ddr_intf.data_out.wr_data);
    // $monitor("%h", ddr_intf.data_out.wr_data); 
     
   end
 
  top DUT(.ctrl_intf(ctrl_intf),
          .ddr_intf(ddr_intf),
          .tb_intf(tb_intf));
  
  
endmodule 
  
