class generator; 
  
  host_req gen_req;
  mailbox gen2drv; 
  mailbox gen2sb; 
  int no_trans = 0; 
  event ended ; 
  
  function new(input mailbox gen2drv, mailbox gen2sb);
   this.gen2drv = gen2drv; 
   this.gen2sb = gen2sb; 
 endfunction
  
  task run(input int no_reqs); 
    repeat(no_reqs) 
      begin 
        gen_req = new();
        if(gen_req.randomize()) begin 
         // $display("-----------------------------"); 
         // $display("@%0t:Gen%0d", $time, no_trans); 
         // $display("Host Address:%0h\nRequest:%0h\nWrite Data:%0h\n",gen_req.log_addr, gen_req.request, gen_req.wr_data);
          gen2drv.put(gen_req); 
          gen2sb.put(gen_req); 
          no_trans++;
          //$display("%d", no_trans); 
        end 
        else 
          begin 
            $fatal("Randomization failed");
          end 
      end
    -> ended ;
  endtask
  
endclass 
  
  
  
               
  
  
  
  
