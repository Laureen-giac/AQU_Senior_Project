`include "host_req.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
//`include "scoreboard.sv"

class environment; 
  
  generator gen; 
  driver drv; 
  monitor mon;  
  //scoreboard sb; 
  mailbox gen2dvr; 
  mailbox gen2sb; 
  mailbox mon2sb;
  event env_stop; 
  virtual tb_interface tb_intf; 
  virtual ddr_interface ddr_intf; 
  virtual ctrl_interface ctrl_intf;
  
  
  function new(input virtual tb_interface tb_intf, input virtual ddr_interface ddr_intf, input virtual ctrl_interface ctrl_intf); 
    this.tb_intf = tb_intf; 
    this.ddr_intf = ddr_intf; 
    this.ctrl_intf = ctrl_intf; 
    
    gen2dvr = new(); 
    gen2sb = new(); 
    mon2sb = new(); 
    
    gen = new(.gen2drv(gen2dvr), 
              .gen2sb(gen2sb));
    
    drv = new(.gen2dvr(gen2dvr), 
              .tb_intf(tb_intf), 
              .ddr_intf(ddr_intf),
              .ctrl_intf(ctrl_intf));
    
    mon = new(.mon2sb(mon2sb), 
              .tb_intf(tb_intf));
    
  //  sb = new(.mon2sb(mon2sb), 
            // .tb_intf(tb_intf)); 
    
  endfunction 
  
  task reset();
    begin 
      drv.reset();
    end 
  endtask 
  
  task run(); 
    fork
      gen.run(7); 
      drv.run(7);
      mon.run(7); 
     //sb.main(5); 
    join
  endtask
  
  task stop();
    #5ns $finish;
  endtask 
  

endclass 
