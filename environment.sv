`include "host_req.sv"
`include "generator.sv"
`include "driver.sv"

class environment; 
  
  generator gen; 
  driver drv;
  environment env; 
  mailbox gen2dvr; 
  virtual tb_interface tb_intf; 
  int no_reqs; 
  
  
  
  function new(virtual tb_interface tb_intf); 
    this.tb_intf = tb_intf; 
    gen2dvr = new();  
    gen = new(.gen2drv(gen2dvr));
    
    drv = new(.gen2dvr(gen2dvr), 
              .tb_intf(tb_intf));
   
    
  endfunction 
  
  task run(); 
    fork
      gen.run(1); 
      drv.run();
    join
    
    if(gen.trans == drv.no_trans)
        begin 
          $finish; 
        end 
    
  endtask 
  

endclass 
  
