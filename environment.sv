`include "host_req.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"

class environment; 
  
  generator gen; 
  driver drv; 
  monitor mon;  
  mailbox gen2dvr; 
  mailbox mon2ch;
  event env_stop; 
  virtual tb_interface tb_intf; 
  
  
  function new(virtual tb_interface tb_intf); 
    this.tb_intf = tb_intf; 
    gen2dvr = new();  
    mon2ch = new(); 
    gen = new(.gen2drv(gen2dvr));
    
    drv = new(.gen2dvr(gen2dvr), 
              .tb_intf(tb_intf));
    
    mon = new(.mon2ch(mon2ch), 
              .tb_intf(tb_intf)); 
  endfunction 
  
  task run(); 
    fork
      gen.run(1); 
      drv.run();
      mon.run(); 
    join
  endtask
  
  task stop();
    wait((gen.no_trans == drv.no_trans) && (gen.no_trans == mon.no_trans));
    $finish; 
  endtask 
  

endclass 
  
