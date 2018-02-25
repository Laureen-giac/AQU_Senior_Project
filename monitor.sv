`define MONITOR tb_intf.MONITOR

class monitor;

  virtual tb_interface tb_intf; //output of DUT
  virtual ddr_interface ddr_intf; 
  mailbox mon2sb;
  host_req gen_req;
  int no_trans = 0; 

  function new(input virtual tb_interface tb_intf,
               input virtual ddr_interface ddr_intf, 
               input mailbox mon2sb);

    this.tb_intf = tb_intf;
    this.ddr_intf = ddr_intf; 
    this.mon2sb = mon2sb; //mailbox to checker

  endfunction

  task run(); 
    forever begin 
      @(posedge tb_intf.cmd_rdy); 
      repeat(2)@(posedge ddr_intf.CK_t);
      gen_req = new();
      gen_req.log_addr = `MONITOR.monitor_cb.log_addr;
      gen_req.request = `MONITOR.monitor_cb.request;
      gen_req.BL = `MONITOR.monitor_cb.BL;
      gen_req.wr_data = `MONITOR.monitor_cb.wr_data;  
      // $display("Host Address:%0h\nRequest:%0h\nWrite Data:%0h\n", gen_req.log_addr, gen_req.request, gen_req.wr_data); 
      
      if(gen_req.log_addr && gen_req.request && gen_req.wr_data) begin 
        mon2sb.put(gen_req); 
        no_trans++; 
      end 
    end 
  endtask
        
  
  /*task run();
    forever begin
      receive(gen_req);
      end 
  endtask

  task receive(output host_req gen_req);
     @(posedge tb_intf.cmd_rdy);
     repeat(2) @(negedge ddr_intf.CK_t);
   // $display("@%0t:MONITOR%0d", $time, no_trans);
    gen_req = new();
    gen_req.log_addr = `MONITOR.monitor_cb.log_addr;
    gen_req.request = `MONITOR.monitor_cb.request;
    gen_req.BL = `MONITOR.monitor_cb.BL;
    gen_req.wr_data = `MONITOR.monitor_cb.wr_data;  
   // $display("Host Address:%0h\nRequest:%0h\nWrite Data:%0h\n", gen_req.log_addr, gen_req.request, gen_req.wr_data); 
  endtask
*/
endclass
