`define DRIVER tb_intf.DRIVER
`include "ddr_pkg.pkg"

class driver;
  
  mailbox gen2dvr;
  int no_trans = 0; 
  virtual tb_interface tb_intf;
  virtual ddr_interface ddr_intf;
  virtual ctrl_interface ctrl_intf;
  
  function new(input mailbox gen2dvr, 
               input virtual tb_interface tb_intf, 
               input virtual ddr_interface ddr_intf,
               input virtual ctrl_interface ctrl_intf); 
    
    this.gen2dvr = gen2dvr; 
    this.tb_intf = tb_intf;  
    this.ddr_intf = ddr_intf; 
    this.ctrl_intf = ctrl_intf; 
 
  endfunction 
  
  task reset(); 
    wait(ddr_intf.reset_n); 
    tb_intf.CL <= 3'b010;
    tb_intf.driver_cb.BL <= 2'b00;
    tb_intf.driver_cb.AL <= 2'b11;
    tb_intf.driver_cb.CWL <= 3'b000;
    tb_intf.driver_cb.RD_PRE <= 1'b1;
    tb_intf.driver_cb.WR_PRE <= 1'b1;
    wait(ctrl_intf.ini_done);
    $display("Reset done at %t", $time); 
  endtask 
  
  /* Get requests from generator, and send to DUT
  */
  task run(input int no_reqs);
    repeat(no_reqs)
      begin  
        host_req gen_req;
         gen2dvr.get(gen_req);
        @(negedge ddr_intf.CK_t);
        @(posedge tb_intf.cmd_rdy);
        `DRIVER.driver_cb.log_addr <= gen_req.log_addr;
        `DRIVER.driver_cb.request <= gen_req.request;
        `DRIVER.driver_cb.wr_data <= gen_req.wr_data;
        no_trans++; 
        $display("Host Address:%0h\nRequest:%0h\nWrite Data:%0h\n",gen_req.log_addr, gen_req.request, gen_req.wr_data);
      end
    @(posedge tb_intf.cmd_rdy);
    `DRIVER.driver_cb.log_addr <= 'x;
    `DRIVER.driver_cb.request <= 'x;
    `DRIVER.driver_cb.wr_data <= 'x;
   
  endtask 
  
endclass 
  
