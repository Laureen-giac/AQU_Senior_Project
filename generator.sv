class generator; 
  
  host_req gen_req;
  mailbox gen2drv; 
  mailbox gen2sb; 
  host_address addr_queue[$];  
  int no_trans = 0; 
  
  function new(input mailbox gen2drv, mailbox gen2sb);
   this.gen2drv = gen2drv; 
   this.gen2sb = gen2sb; 
 endfunction
  
  task run(input int no_reqs); 
    repeat(no_reqs) 
      begin 
        gen_req = new();
        if(gen_req.randomize()) begin
          if(no_trans == 0 || addr_queue.size() == 0) begin
            gen_req.request = WR_R; 
            gen_req.wr_data = $random(); 
          end 
          if(gen_req.request == WR_R) begin 
            addr_queue.push_back(gen_req.log_addr); 
          end 
          else if(no_trans != 0 && gen_req.request == RD_R) begin 
            if(addr_queue.size() != 0) begin 
              gen_req.log_addr = addr_queue.pop_front();
            end 
          end 
         // $display("-----------------------------"); 
         // $display("@%0t:Gen%0d", $time, no_trans); 
            $display("Host Address:%0h\nRequest:%0h\nWrite Data:%0h\n",gen_req.log_addr, gen_req.request, gen_req.wr_data);
          gen2drv.put(gen_req); 
          gen2sb.put(gen_req); 
          no_trans++;
        end 
        else begin 
          $fatal("Randomization failed");
        end 
      end
  endtask
  
endclass 
  
  
  
