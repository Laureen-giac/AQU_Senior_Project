/// Stimulus Generator 
`include "Host_Req.sv"

 class Host_Request_Gen ;
    mailbox mail_box; // creates a mailbox queue 
    Host_Request  Host_Request_array[] ; 

   function new(input int Array_Size ,input mailbox Basic_mail_box );
     this.mail_box = Basic_mail_box;
  Host_Request_array= new[Array_Size] ; 
     foreach(Host_Request_array[i])
       Host_Request_array[i]= new() ;
 
 endfunction 
   
   task randomize_now;
     
     foreach(Host_Request_array[i]) begin 
       if(Host_Request_array[i].randomize()==1)  begin 
          mail_box.put(Host_Request_array[i]); 
         $display("-----------------------------");
         $display("Host Address:%0h \nRequest:%0h\nWrite Data:%0h \n",Host_Request_array[i].address, Host_Request_array[i].req, Host_Request_array[i].data);
         
       end 
       
       
      end 
  endtask 
   
   
   

 
endclass 
  
  
 


  
 
  


