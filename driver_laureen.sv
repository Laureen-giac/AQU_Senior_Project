`define DRIVER tb_intf.DRIVER.driver_cb
`include "ddr_pkg.pkg"

class driver;
  
  mailbox gen2dvr;
  int no_trans = 0;
  host_req gen_req; 
  virtual tb_interface tb_intf;
  virtual ddr_interface ddr_intf; 
  
  
  function new(input mailbox gen2dvr, 
               input virtual tb_interface tb_intf); 
    
    this.gen2dvr = gen2dvr; 
    this.tb_intf = tb_intf; 
 
  endfunction 
  
  /* Get requests from generator, and send to DUT
  */
  task run();
    host_req gen_req;
    tb_intf.rd_data <=  '0; 
    tb_intf.wr_data <=  'z; 
    tb_intf.log_addr <= 'x; 
    tb_intf.request <= NOP_R;
    tb_intf.CL <= '0;
    tb_intf.AL <= '0;
    tb_intf.CWL <= '0;
    tb_intf.RD_PRE <= '0;
    tb_intf.WR_PRE <= '0;
     
    forever
      begin 
        @(posedge tb_intf.cmd_rdy); 
        gen2dvr.get(gen_req);
        `DRIVER.log_addr <= gen_req.log_addr;
        `DRIVER.request <= gen_req.request;
        //if(gen_req.request == WR_R || gen_req.request == WRA_R)
        `DRIVER.wr_data <= gen_req.wr_data; 
        //else `DRIVER.wr_data <= 'z; 
        $display("-----------------------------"); 
        $display("@%0t:DRIVER%0d", $time, no_trans); 
        $display("Host Address:%0h\nRequest:%0h\nWrite Data:%0h\n",gen_req.log_addr, gen_req.request, gen_req.wr_data);
        this.no_trans++; 
      end 
  endtask 
  
endclass 
  
