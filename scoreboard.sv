`include "ddr_pkg.pkg" 

class scoreboard; 
  
  virtual ddr_interface ddr_intf; 
  virtual ctrl_interface ctrl_intf; 
  virtual tb_interface tb_intf; 
  
  mailbox gen2sb; 
  mailbox mon2sb; 
  
  write_data dimm[dimm_addr]; 
  write_data wr_data, rd_data; 
  bit[27:0] index; 
  bit rd_end; 
  host_req gen_req; 
  logic[4:0][7:0] data_c, data_t; 
  bit[4:0] cycle_8 = 5'b10000; 
  bit[2:0] cycle_4 = 3'b100; 
  
  int no_trans = 0; 
  mem_addr_type rd_addr; 
  mem_addr_type rd_addr_store[$]; 
  
  function new(input virtual tb_interface tb_intf, 
               input virtual ddr_interface ddr_intf, 
               input virtual ctrl_interface ctrl_intf, 
               input mailbox gen2sb,
               input mailbox mon2sb); 
    
    this.tb_intf = tb_intf; 
    this.ddr_intf = ddr_intf;
    this.ctrl_intf = ctrl_intf; 
    this.gen2sb = gen2sb; 
    this.mon2sb = mon2sb; 
    
  endfunction 
  
  task store_write_data();
    forever begin 
      gen_req= new(); 
      @(posedge tb_intf.cmd_rdy) ;
      if(gen2sb.num() != 0 ) begin 
        gen2sb.get(gen_req);
        if(gen_req.request==WR_R) begin
          index = gen_req.log_addr[27:0]; 
          if(ctrl_intf.BL == 8)
            dimm[index]=  gen_req.wr_data;
          else 
            dimm[index]= gen_req.wr_data[31:0]; 
          no_trans++; 
        end 
        else begin
          rd_addr_store.push_back(gen_req.log_addr[27:0]);
          no_trans++ ; 
        end 
      end 
    end
  endtask
  
  
  task compare() ;
    
    string result;
    host_req host_req_samp ; 
    forever begin 
      @(posedge ddr_intf.CK_t);
      @(posedge rd_end);
      host_req_samp=  new();
      if(mon2sb.num() != 0) begin 
        mon2sb.get(host_req_samp);
        rd_addr=rd_addr_store.pop_front;
        wr_data= dimm[rd_addr];
        
        if(host_req_samp.BL== 2'b00) begin 
          rd_data = {data_c[4], data_t[3], data_c[3], data_t[2], 
                     data_c[2], data_t[1], data_c[1], data_t[0]};
          
          if(rd_data== wr_data) 
            result= "PASS";
          
          else  
            result= "FAIL";
            
            data_check_8: assert (wr_data == rd_data);
            $display("%t\tAddress:0x%h\tWR_Data: 0x%h\tRD_Data0x%h\tResult:%s\n", $time, rd_addr, wr_data, rd_data, result);
        end 
        
        else if(host_req_samp.BL==2'b10) begin 
          rd_data = {'0, data_t[2], data_c[1], data_t[1], data_c[0]}; // not sure 
          
          if(rd_data[31:0]== wr_data)
            result= "PASS";
          else 
            result= "FAIL";
          data_check_4: assert (wr_data == rd_data);
          $display("%t\tAddress:0x%h\tWR_Data: 0x%h\tRD_Data0x%h\tResult:%s\n", $time, rd_addr, wr_data, rd_data, result);
        end 
      end
    end  
  endtask 
  
  task cap_data_t(); 
    forever begin 
      @(negedge ddr_intf.dqs_t);
      if(ctrl_intf.dimm_req==RD_R) begin
        data_t ={ddr_intf.dq, data_t[4:1]};
        if(ctrl_intf.BL==8) begin 
          cycle_8 = {cycle_8[3:0], cycle_8[4]};
          if((cycle_8[4]))
            rd_end = 1'b1 ; 
          else 
            rd_end = 1'b0; 
        end
        else begin 
          cycle_4 = {cycle_4[1:0], cycle_4[2]};
          if((cycle_4[2]))
            rd_end = 1'b1; 
          else 
            rd_end = 1'b0; 
        end   
      end 
    end 
  endtask
  
  task cap_data_c(); 
    forever begin 
      @(negedge  ddr_intf.dqs_c)
      if(ctrl_intf.dimm_req==RD_R) begin
        data_c <= {ddr_intf.dq, data_c[4:1]}; 
      end
    end 
  endtask 
  
  task cap_rd_data();
    fork
      cap_data_t();
      cap_data_c();
    join
  endtask 
  
  task run(); 
    fork
      store_write_data();
      cap_rd_data();
      compare(); 
    join_any
  endtask 

endclass

  
  


  
