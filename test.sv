`include "environment.sv"

program automatic test(tb_interface tb_intf, ddr_interface ddr_intf, ctrl_interface ctrl_intf); 
  
  environment env; 
  
  initial 
    begin 
      env = new(tb_intf, ddr_intf, ctrl_intf); 
      env.reset(); 
      env.run();
      env.stop(); 
    end 
  
endprogram 
