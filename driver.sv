


class Driver ;
  mailbox mail_box ; 
  Host_Request host_req ; 
  
  
  virtual tb_interface tb_intf ; //tb_interface 
  
  //new constructor 
  
  function new ( input virtual tb_interface tb_intf, input mailbox basic_mail_box);
    
    this.tb_intf= tb_intf ;
    
    this.mail_box= basic_mail_box ; 
    
  endfunction 
  
  
  
  task assign_now(); 
  
    if(tb_intf.act_cmd==1) begin 
    if(mail_box.num() !=0 ) begin 
     mail_box.get(host_req);
     
      tb_intf.CWL=host_req.CWL;
      tb_intf.CL =host_req.CL ;
      tb_intf.RD_PRE=host_req.RD_PRE;
      tb_intf.WR_PRE =host_req.WR_PRE ;
      tb_intf.BL =host_req.BL;
      tb_intf.AL= host_req.AL;
      tb_intf.log_addr=host_req.address; 
      tb_intf.request=host_req.req; 
      tb_intf.gen_rw_Data=host_req.data; 
      $display("-----------------------------");
      $display(" tb_intf.log_addr:%0h \ntb_intf.request:%0h\nWrite Data:%0h \n", tb_intf.log_addr, tb_intf.request,  tb_intf.gen_rw_Data);
         
      
      
    
    
  end 
   end
   endtask 
  
  
  
endclass