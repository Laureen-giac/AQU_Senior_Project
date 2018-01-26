`define MONITOR tb_intf.MONITOR

class monitor;

  virtual tb_interface tb_intf; //output of DUT
  mailbox mon2ch;
  host_req gen_req;
  int no_trans = 0; 

  function new(input virtual tb_interface tb_intf,
               input mailbox mon2ch);

    this.tb_intf = tb_intf;
    this.mon2ch = mon2ch; //mailbox to checker

  endfunction

  task run();
    fork 
      forever
        begin
          $display("-----------------------------");
          $display("@%0t:MONITOR", $time);
          receive(gen_req);
          $display("Host Address:%0h\nRequest:%0h\nWrite Data:%0h\n", gen_req.log_addr, gen_req.request, gen_req.wr_data);
          mon2ch.put(gen_req);
          no_trans++; 
        end
    join 
  endtask

  task receive(output host_req gen_req);
    @(`MONITOR.monitor_cb iff 
      tb_intf.cmd_rdy);
    gen_req = new(); 
    gen_req.log_addr = `MONITOR.monitor_cb.log_addr;
    gen_req.request = `MONITOR.monitor_cb.request;
    gen_req.CL = `MONITOR.monitor_cb.CL;
    gen_req.BL = `MONITOR.monitor_cb.BL;
    gen_req.AL = `MONITOR.monitor_cb.AL;
    gen_req.CWL = `MONITOR.monitor_cb.CWL;
    gen_req.RD_PRE = `MONITOR.monitor_cb.RD_PRE;
    gen_req.WR_PRE = `MONITOR.monitor_cb.WR_PRE;
    gen_req.wr_data = `MONITOR.monitor_cb.wr_data;
  endtask

endclass
