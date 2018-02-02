`include "ddr_pkg.pkg"

class scoreboard;
  
  mailbox mon2sb; 
  mailbox gen2sb; 
  host_req gen_req; 
  virtual tb_interface tb_intf; 
  int no_trans; 

  
  function new(input mailbox mon2sb, input virtual tb_interface tb_intf);
    this.mon2sb = mon2sb;  
    this.tb_intf = tb_intf; 
  endfunction 
  
  task reset(); 
    rd_addr_store.delete(); 
  endtask 
  
  task detect_rd(); 
    forever 
      begin 
        rd_end = cycle_8[4] ? 1'b1 : 1'b0; 
      end 
  endtask 
  
  task get_stim();
    host_req gen_req; 
      begin
        if(tb_intf.cmd_rdy)
          begin 
            mon2sb.get(gen_req); 
            if(gen_req.request == RD_R)
              begin 
                rd_addr_store.push_back(gen_req.log_addr[27:0]);
              end
          end 
      end 
  endtask
  
  task get_addr(); 
    if(rd_end)
      begin 
        if(rd_addr_store.size() != 0) 
          begin 
            rd_addr = rd_addr_store.pop_front(); 
          end 
      end 
  endtask 
  
  
  task check(); 
    string result; 
    if(rd_end) 
      begin
        /*if(BL == 2'b00) 
          begin
         //   rd_data; //=?
          end*/
      end 
  endtask
  
   task run(int no_req); 
    repeat(no_req)
      begin
        reset();
       fork
         detect_rd(); 
         get_stim(); 
         get_addr();
         check(); 
       join 
      end 
  endtask 
  
  endclass 
           
    
  
  
  
    
  
  
