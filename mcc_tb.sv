`include "ddr_interface.sv"
`include "ctrl_interface.sv"
`include "tb_interface.sv"

module tb; 
  
  ctrl_interface ctrl_intf(); 
  ddr_interface ddr_intf();
  tb_interface tb_intf(); 
  
  
  always #HALF_PERIOD ddr_intf.CK_t = ~ddr_intf.CK_t;
  
  initial 
    begin 
      $dumpvars(); 
      $dumpfile("waves.vcd");
    end 
  
  initial 
    begin
      tb_intf.CL = 3'b010; 
      tb_intf.BL = 2'b00; 
      tb_intf.AL = 2'b11; 
      tb_intf.CWL = 3'b000;
      tb_intf.RD_PRE = 1'b1; 
      tb_intf.WR_PRE = 1'b1; 
      tb_intf.tCCD = 3'b000;     
      ddr_intf.reset_n <= 1'b1;
      tb_intf.cmd_rdy <= 1'b0;
      #200ns
      ddr_intf.reset_n <= 1'b0;
      //verify_init(); 
      #200us
      ddr_intf.reset_n <= 1'b1;
      $monitor("DDR4 Activate state is %s\n", DUT.rw.current_rw_state.name());
      @(negedge ddr_intf.CK_t) 
      tb_intf.cmd_rdy<= 1'b1;
      tb_intf.log_addr <= 40'b10111111111010101; 
      tb_intf.request <= WR_R;
      //verify_act(); 
      @(negedge ddr_intf.CK_t) 
      tb_intf.cmd_rdy <= 1'b0;
      #200ns 
      tb_intf.cmd_rdy <= 1'b1;
      @ (negedge ddr_intf.CK_t) 
      tb_intf.log_addr <= 40'b10111111111010101; 
      tb_intf.request <= RDA_R;
      //verify_act(); 
      //$monitor("DDR4 CAS state is %s at %t\nrequest:: %b\nprevious_req:: %b", DUT.cas.cas_state.name(), $time, DUT.rw.cas_cmd_out, DUT.cas.prev_req);
      #300ns
      $finish;   
    end 
  
task verify_act;
  int seed = 5; 
    begin 
      $monitor("DDR4 Activate state is %s\n", DUT.act.current_activate_state.name());
      //wait(ctrl_intf.act_rdy || ctrl_intf.no_act_rdy);
      tb_intf.log_addr <= 40'b10111111111010101; 
      tb_intf.request <= 110; 
      @(negedge ddr_intf.CK_t) tb_intf.cmd_rdy <= 1'b0; 
      @(negedge ddr_intf.CK_t) tb_intf.cmd_rdy <= 1'b0;
      repeat (5) @(posedge ddr_intf.CK_t); tb_intf.cmd_rdy <=1'b1;
      fork 
        tb_intf.log_addr <= 40'b10111111111010101; 
        tb_intf.request <= 101;
        $monitor("DDR4 CAS state is %s at %t\nrequest:: %h\nprevious_req:: %h", DUT.cas.cas_state.name(), $time, DUT.cas.request, DUT.cas.prev_req);
      join 
    end    
  endtask
  
  
    task verify_cas; 
    begin
      $monitor("DDR4 CAS state is %s at %t\nrequest:: %h\nprevious_req:: %h", DUT.cas.cas_state.name(), $time, DUT.cas.request, DUT.cas.prev_req);
    end 
  endtask   
  
  
  task randomize(int seed); 
    begin
      repeat(5) 
        @(negedge ddr_intf.CK_t) 
          begin
            tb_intf.log_addr <= $urandom(seed); 
            tb_intf.request <= $urandom % 3;
            
            $display("-----------------------------------------");
            $display("Logical address is %h", tb_intf.log_addr);
            $display("Decoded address\nBG:: %h\nBA:: %h\nRow::%h\nColumn::%h", DUT.cmds.phy_addr.bg_addr, DUT.cmds.phy_addr.ba_addr,DUT.cmds.phy_addr.row_addr, DUT.cmds.phy_addr.col_addr);
           $display("-----------------------------------------");
           
            $monitor("ctrl_intf.request:: %h", ctrl_intf.req);
            $monitor("Decoded address:: %h", DUT.cmds.phy_addr);
            $monitor("ctrl_intf.mem_addr:: %h", ctrl_intf.mem_addr);
            $monitor("DDR4 Activate state is %s\n", DUT.act.current_activate_state.name());
          end 
    end 
  endtask 
  

  task verify_init;
    begin 
      tb_intf.CL = 3'b010; 
      tb_intf.BL = 2'b00; 
      tb_intf.AL = 2'b11; 
      tb_intf.CWL = 3'b000;
      tb_intf.RD_PRE = 1'b1; 
      tb_intf.WR_PRE = 1'b1; 
      tb_intf.tCCD = 3'b000;     
      $display("Applying reset at %t" , $time); 
      ddr_intf.reset_n = 0;      
      #200us ddr_intf.reset_n = 1;
     $monitor("DDR4 state is %s\n DDR4 command is %s", DUT.fsm.ctrl_state.name(),  DUT.cmds.cmd_out.cmd.name()); 
      @(DUT.init.config_done);
      $display("Initialization finished at %t", $time);     
    end 
  endtask 
  
  task verify_refresh; 
    begin 
      wait(ctrl_intf.refresh_rdy);
      $display("Refresh should begin");
      $display(" ddr_intf.cs_n <= %b; \n ddr_intf.act_n <= %b\n ddr_intf.RAS_n_A16 <= %b;\nddr_intf.CAS_n_A15 <= %b\n ddr_intf.WE_n_A14 <= %b;\n ddr_intf.bg_addr <= %b;\n ddr_intf.ba_addr <= %b;\n ddr_intf.A12_BC_n <= %b;\n ddr_intf.A17 <= %b;\n ddr_intf.A13 <= %b;\n ddr_intf.A11 <= %b;\n ddr_intf.A10_AP <= %b;\n ddr_intf.A9_A0 <= %b;", ddr_intf.cs_n,  ddr_intf.act_n, ddr_intf.RAS_n_A16, ddr_intf.CAS_n_A15, ddr_intf.WE_n_A14, ddr_intf.bg_addr, ddr_intf.ba_addr, ddr_intf.A12_BC_n,  ddr_intf.A17, ddr_intf.A13, ddr_intf.A11,  ddr_intf.A10_AP,  ddr_intf.A9_A0); 
      wait(!ctrl_intf.refresh_rdy); 
      $display("Refresh Ended at %t", $time);
    end   
  endtask 
 
  
  
    top DUT(.ctrl_intf(ctrl_intf), 
            .ddr_intf(ddr_intf), 
            .tb_intf(tb_intf)); 
    
    endmodule 
