`include "tb_interface.sv"
`include "ddr_interface.sv"
`include "ctrl_interface.sv"
`include "ddr_pkg.pkg"
`include "test.sv"

module tb_top;
  
  ddr_interface ddr_intf(); 
  tb_interface tb_intf(ddr_intf);
  ctrl_interface ctrl_intf();
  test t(tb_intf);
  
  initial 
    begin
      ddr_intf.reset_n <= 1'b1;
      tb_intf.cmd_rdy <= 1'b0;
      #200ns
      @(negedge ddr_intf.CK_t);
      ddr_intf.reset_n <= 1'b0;
      #200us
      ddr_intf.reset_n <= 1'b1;
      #300ns
      @(negedge ddr_intf.CK_t)
      tb_intf.cmd_rdy<= 1'b1;
      $monitor("DDR4 RW state is %s\n", DUT.rw.current_rw_state.name());
      @(negedge ddr_intf.CK_t)
      tb_intf.cmd_rdy <= 1'b0;
      #3ns
      tb_intf.cmd_rdy <= 1'b1;
    end 
  
  top DUT(.ctrl_intf(ctrl_intf),
            .ddr_intf(ddr_intf),
            .tb_intf(tb_intf));
  
  
endmodule 
 
