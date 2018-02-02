`define MONITOR tb_intf.MONITOR

class monitor;

  virtual tb_interface tb_intf; //output of DUT
  mailbox mon2sb;
  host_req gen_req;
  int no_trans = 0; 

  function new(input virtual tb_interface tb_intf,
               input mailbox mon2sb);

    this.tb_intf = tb_intf;
    this.mon2sb = mon2sb; //mailbox to checker

  endfunction

  task run(input int no_req);
    repeat(no_req)
      begin
        receive(gen_req);
      end 
  endtask

  task receive(output host_req gen_req);
    @(`MONITOR.monitor_cb iff 
      tb_intf.cmd_rdy);
      $display("-----------------------------");
      $display("@%0t:MONITOR%d", $time, no_trans);
      gen_req = new(); 
      gen_req.log_addr = `MONITOR.monitor_cb.log_addr;
      gen_req.request = `MONITOR.monitor_cb.request;
      gen_req.BL = `MONITOR.monitor_cb.BL;
      gen_req.wr_data = `MONITOR.monitor_cb.wr_data;
      $display("Host Address:%0h\nRequest:%0h\nWrite Data:%0h\n", gen_req.log_addr, gen_req.request, gen_req.wr_data);
      mon2sb.put(gen_req);
      no_trans++; 
  endtask

endclass
