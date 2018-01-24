/// Stimulus Generator 

module Rand_Stim ( ctrl_interface ctrl_intf,tb_interface tb_intf); 

  mailbox mail_box; // creates a mailbox queue 



class 	Host_Request ;

// lets define  randomized address array here 
 rand bit  [39:0]address ; 
 
 // lets define  randomized write data array here 
 
 rand bit  [63:0]data ;
 // lets define  randomized operation type  here 
 rand bit  [2:0]req ;
 
 
 // lets define  the randomized user programmed delays and parameters  
 randc bit  [1:0] AL;
 randc bit   RD_PRE;
 randc bit   WR_PRE; 
 randc bit  [2:0] CWL;
 randc bit  [2:0] CL;
 randc bit  [1:0] BL;
// randc bit  [2:0] tCCD;
 //randc bit [3:0] CL; 
 
 
 // now adding constraint to these rondome variables 
 
 
constraint c1 {
req ==3'b001 || req==3'b011; 
req dist {
3'b001:= 1 ,
3'b011:= 1 
};


}
  


constraint c2 {
AL >= 2'b00; 
AL <= 2'b10 ; 
}
constraint c3 {
CWL >= 3'b000; 
CWL <= 3'b110 ; 
}
constraint c4 {
CL >= 3'b000; 
CL <= 3'b111 ; 
}
constraint c5 {
BL >= 2'b00; 
BL <= 2'b10 ; 
}
//constraint c6 {
//tCCD_rand>= 3'b000; 
//tCCD_rand <= 3'b100 ; 
//}
  
  
   task print();
      begin 
        $write("host request data  %b\n",data);
        $write("host request adress  %b\n",address);
        end
   endtask  
 
 

endclass
 class Host_Request_Gen ;

   rand Host_Request  Host_Request_array[] ; 

 function new();
  Host_Request_array= new[5] ; 
 foreach(Host_Request_array[i])
 Host_Request_array[i]= new() ;
 
 endfunction 

 
endclass 
  
  
  Host_Request_Gen host_request_pack ;

initial begin 

 host_request_pack=new(); 
  mail_box= new();
  //if(host_request_pack.randomize()==1  )  begin 
  //  mail_box.put(host_request_pack.Host_Request_array[0]); 
  //  host_request_pack.Host_Request_array[0].print() ;
 // end 
  

end 



  
 
  always@(posedge tb_intf.act_cmd) begin
    
    if(host_request_pack.randomize()==1  && !ctrl_intf.busy)  begin 
    mail_box.put(host_request_pack.Host_Request_array[0]);  end 


end 

endmodule 

