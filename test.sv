`include "environment.sv"

program test(tb_interface tb_intf); 
  
  initial 
    begin 
      environment env = new(tb_intf); 
      env.run();
    end 
  
endprogram 
