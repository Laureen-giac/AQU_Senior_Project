class gen; 
  
  host_request gen_req;
  mailbox gen2driv; 
  int no_reqs; 
  int trans = 0; 
  
 function new(input mailbox gen2driv,  
               input  no_reqs);
   this.gen2driv = gen2driv;  
   this.no_reqs = no_reqs;
 endfunction
  
  task run; 
    repeat(no_reqs) 
      begin 
        gen_req = new(); 
        if(gen_req.randomize()) begin 
          $display("-----------------------------"); 
          $display("@%0t:Gen%0d", $time, trans); 
          $display("Host Address:%0h\nRequest:%0h\nWrite Data:%0h\n",gen_req.log_addr, gen_req.request, gen_req.data.wr_data);
          gen2driv.put(gen_req); 
          trans++;
        end 
        else 
          begin 
            $fatal("Randomization failed");
          end 
      end 
  endtask 
  
endclass 

  
