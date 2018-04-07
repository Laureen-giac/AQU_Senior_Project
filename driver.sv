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
    `DRIVER.driver_cb.BL <= 2'b00; //$urandom_range(2'b00, 2'b10);
    `DRIVER.driver_cb.CL <= 3'b010;
    `DRIVER.driver_cb.AL <= 2'b11;
    `DRIVER.driver_cb.CWL <= 3'b000;
    `DRIVER.driver_cb.RD_PRE <= 1'b1;
    `DRIVER.driver_cb.WR_PRE <= 1'b1;
     tb_intf.cmd_rdy <= 1'b0; 
    wait(ctrl_intf.ini_done);
    $display("Reset done at %t", $time); 
  endtask 
  
  /* Get requests from generator, and send to DUT
  */
  task run();
    forever begin
      host_req gen_req;
      #30ns; 
      @(posedge ddr_intf.CK_t);
      if(ctrl_intf.act_idle && !ctrl_intf.busy) begin
        if(gen2dvr.num() != 0) begin 
          tb_intf.cmd_rdy <= 1'b1; 
          gen2dvr.get(gen_req); 
          `DRIVER.driver_cb.phy_addr <= gen_req.phy_addr;
          `DRIVER.driver_cb.request <= gen_req.request;
          `DRIVER.driver_cb.wr_data <= gen_req.wr_data;
          @(posedge ddr_intf.CK_t);
           //$display("DRIVER%0d:: Host Address:%0h\nRequest:%0h\nWrite Data:%0h\n",no_trans, gen_req.phy_addr[27:0], gen_req.request, gen_req.wr_data);
            tb_intf.cmd_rdy <= 1'b0;
            no_trans++;
          end 
        end
      end 
  endtask 
  
endclass 
  
