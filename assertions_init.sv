module assertion_check(ddr_interface ddr_intf) ;

timeunit 1ns ; 
 timeprecision 100ps ; 


sequence MRS0 ; 
              (!ddr_intf.cs_n)
               ##0 (ddr_intf.act_n )
              ##0 (!ddr_intf.RAS_n_A16 )
              ##0 (!ddr_intf.CAS_n_A15 )
             ##0 (!ddr_intf.WE_n_A14 )
              ##0 (ddr_intf.bg_addr ==2'b00) 
            ##0 (ddr_intf.ba_addr==2'b00);


endsequence
  
sequence MRS1 ; 
             (!ddr_intf.cs_n) 
               ##0 (ddr_intf.act_n )
              ##0 (!ddr_intf.RAS_n_A16 )
              ##0 (!ddr_intf.CAS_n_A15 )
             ##0 (!ddr_intf.WE_n_A14 )
              ##0 (ddr_intf.bg_addr ==2'b00) 
            ##0 (ddr_intf.ba_addr==2'b01);


endsequence 
sequence MRS2 ; 
              (!ddr_intf.cs_n)  
              ##0 (ddr_intf.act_n )
              ##0 (!ddr_intf.RAS_n_A16 )
              ##0 (!ddr_intf.CAS_n_A15 )
             ##0 (!ddr_intf.WE_n_A14 )
              ##0 (ddr_intf.bg_addr ==2'b00) 
            ##0 (ddr_intf.ba_addr==2'b10);


endsequence 
sequence MRS3 ; 
               (!ddr_intf.cs_n) 
              ##0 (ddr_intf.act_n )
              ##0 (!ddr_intf.RAS_n_A16 )
              ##0 (!ddr_intf.CAS_n_A15 )
             ##0 (!ddr_intf.WE_n_A14 )
              ##0 (ddr_intf.bg_addr ==2'b00) 
            ##0 (ddr_intf.ba_addr==2'b11);


endsequence 
sequence MRS4; 
              (!ddr_intf.cs_n) 
              ##0 (ddr_intf.act_n )
              ##0 (!ddr_intf.RAS_n_A16 )
              ##0 (!ddr_intf.CAS_n_A15 )
             ##0 (!ddr_intf.WE_n_A14 )
              ##0 (ddr_intf.bg_addr ==2'b01) 
            ##0 (ddr_intf.ba_addr==2'b00);


endsequence 
sequence MRS5 ; 
             (!ddr_intf.cs_n)  
              ##0 (ddr_intf.act_n )
              ##0 (!ddr_intf.RAS_n_A16 )
              ##0 (!ddr_intf.CAS_n_A15 )
             ##0 (!ddr_intf.WE_n_A14 )
              ##0 (ddr_intf.bg_addr ==2'b01) 
            ##0 (ddr_intf.ba_addr==2'b01);


endsequence 
sequence MRS6 ; 
 (!ddr_intf.cs_n)  ##0 (ddr_intf.act_n ) ##0 (!ddr_intf.RAS_n_A16 )
  ##0 (!ddr_intf.CAS_n_A15 ) ##0 (!ddr_intf.WE_n_A14 )        
     ##0 (ddr_intf.bg_addr ==2'b01)   ##0 (ddr_intf.ba_addr==2'b10);         
              
            
            
            


endsequence 



sequence zqcl_cal ; 
             (!ddr_intf.cs_n) 
              ##0 (ddr_intf.act_n )
              ##0 (ddr_intf.RAS_n_A16 )
              ##0 (ddr_intf.CAS_n_A15 )
             ##0 (!ddr_intf.WE_n_A14 )
  ##0 (ddr_intf.bg_addr =='1) 
  ##0 (ddr_intf.ba_addr=='1);


endsequence 


sequence CKE_ROSE; 
 	$rose(ddr_intf.CKE);
endsequence 

sequence RESET_S; 
 	$rose(ddr_intf.reset_n);
endsequence



// propert for CKE 
property  CKE_P ; 

@(posedge ddr_intf.CK_t)
  RESET_S |-> (##[tCKE-tIS:$]CKE_ROSE) ;
endproperty 
 CKE_P_assert :  assert property(CKE_P)
    else
                $display("@%0dns Assertion Failed", $time);



property INIT_SEQ_P ; 
@(posedge ddr_intf.CK_t)
  CKE_ROSE |->  ##[(tIS + tXPR):(tIS + tXPR+1)] MRS3    ##[tMRD:tMRD+1] MRS6
  ##[tMRD:tMRD+1] MRS5  ##[tMRD:tMRD+1] MRS4  ##[tMRD:tMRD+1] MRS2 
  ##[tMRD:tMRD+1] MRS1   ##[tMRD:tMRD+1] MRS0 
  ##[tMOD:tMOD+1] zqcl_cal ; 


endproperty 
   
  assert property(INIT_SEQ_P);
      




endmodule 