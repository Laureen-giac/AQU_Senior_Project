class generator; 
  
  host_req gen_req;
  mailbox gen2drv; 
  
  int no_trans = 0; 
  int no_reqs ;
  
 function new(input mailbox gen2drv);
   this.gen2drv = gen2drv;  
 endfunction
  
  task run(); 
    repeat(no_reqs) 
      begin   
        gen_req = new();
        if(gen_req.randomize()) begin 
          $display("-----------------------------"); 
          $display("@%0t:Gen%0d", $time, trans); 
          $display("Host Address:%0h\nRequest:%0h\nWrite Data:%0h\n",gen_req.log_addr, gen_req.request, gen_req.wr_data);
          gen2drv.put(gen_req); 
          no_trans++;
        end 
        else 
          begin 
            $fatal("Randomization failed");
          end 
      end 
  endtask
  
endclass 

  
