`include "ddr_pkg.pkg"
`timescale 10ns/1ps


module assertions(ddr_interface ddr_intf, ctrl_interface ctrl_intf);
  
  parameter CL = 11; //drive from TB; can't use constants in assertions
  parameter BL = 8;
  parameter AL = 0;
  parameter CWL = 9;
  parameter RD_PRE = 1;
  parameter WR_PRE = 1;
  parameter tCCD = 4;
  
  sequence CKE_ROSE; 
    $rose(ddr_intf.CKE);
  endsequence 
  
  sequence RESET_S; 
    $rose(ddr_intf.reset_n); 
  endsequence 
  
  sequence DES_S; 
    $rose(ddr_intf.cs_n);
  endsequence 
  
  property RES_P; //?
    @(posedge ddr_intf.CK_t)
    RESET_S |=> ##[(160000) + (tCKE) + 1 : (160000) +(tCKE) + 2] DES_S; 
  endproperty 
    
  assert property(RES_P)
    else 
      $display("RES P FAILED"); 
  
 sequence MRS0; 
   (!ddr_intf.cs_n) ##0 (ddr_intf.act_n) ##0 (!ddr_intf.RAS_n_A16) ##0 
   (!ddr_intf.CAS_n_A15) ##0 (!ddr_intf.WE_n_A14) ##0
   (ddr_intf.bg_addr[0]==1'b0) ##0
   (ddr_intf.ba_addr == 2'b00);
 endsequence 

sequence MRS1; 
   (!ddr_intf.cs_n) ##0 (ddr_intf.act_n) ##0 (!ddr_intf.CAS_n_A15) ##0
   (!ddr_intf.WE_n_A14) ##0 (ddr_intf.bg_addr[0]==1'b0) ##0
   (ddr_intf.ba_addr == 2'b01);
endsequence 

sequence MRS2;
  (!ddr_intf.cs_n) ##0 (ddr_intf.act_n) ##0 (!ddr_intf.RAS_n_A16) ##0 
  (!ddr_intf.CAS_n_A15) ##0 (!ddr_intf.WE_n_A14) ##0
  (ddr_intf.bg_addr[0]==1'b0) ##0
  (ddr_intf.ba_addr == 2'b10);
endsequence 

sequence MRS3; 
  (!ddr_intf.cs_n) ##0 (ddr_intf.act_n) ##0 (!ddr_intf.RAS_n_A16) ##0 
  (!ddr_intf.CAS_n_A15) ##0 (!ddr_intf.WE_n_A14) ##0
  (ddr_intf.bg_addr[0]==1'b0) ##0
  (ddr_intf.ba_addr == 2'b11);
endsequence 

sequence MRS4; 
  (!ddr_intf.cs_n) ##0 (ddr_intf.act_n) ##0 (!ddr_intf.RAS_n_A16) ##0 
  (!ddr_intf.CAS_n_A15) ##0 (!ddr_intf.WE_n_A14) ##0
  (ddr_intf.bg_addr[0]==1'b1) ##0
  (ddr_intf.ba_addr == 2'b00);
endsequence 

sequence MRS5; 
  (!ddr_intf.cs_n) ##0 (ddr_intf.act_n) ##0 (!ddr_intf.RAS_n_A16) ##0 
  (!ddr_intf.CAS_n_A15) ##0 (!ddr_intf.WE_n_A14) ##0
  (ddr_intf.bg_addr[0]==1'b1) ##0
  (ddr_intf.ba_addr == 2'b01);
endsequence 

sequence MRS6; 
  (!ddr_intf.cs_n) ##0 (ddr_intf.act_n) ##0 (!ddr_intf.RAS_n_A16) ##0 
  (!ddr_intf.CAS_n_A15) ##0 (!ddr_intf.WE_n_A14) ##0
  (ddr_intf.bg_addr[0]==1'b1) ##0
  (ddr_intf.ba_addr == 2'b10);
endsequence 

sequence ZQCL_CAL;
  (!ddr_intf.cs_n) ##0 (ddr_intf.act_n) ##0 (ddr_intf.RAS_n_A16) ##0 
  (ddr_intf.CAS_n_A15) ##0 (!ddr_intf.WE_n_A14);
endsequence 
  
  property CKE_P; 
    @(posedge ddr_intf.CK_t) 
    RESET_S |-> ##[(tCKE - tIS) :$] CKE_ROSE; 
  endproperty 
  
  property INIT_SEQ_P;
    @(posedge ddr_intf.CK_t) 
    CKE_ROSE |=> ##[(tIS + tXPR):(tIS + tXPR + 1)] MRS3 ##[tMRD:tMRD+1] MRS6
    ##[tMRD:tMRD+1] MRS5 ##[tMRD:tMRD+1] MRS4
    ##[tMRD:tMRD+1] MRS2 ##[tMRD:tMRD+1] MRS1
    ##[tMRD:tMRD+1] MRS0 ##[tMOD:tMOD+1] ZQCL_CAL;
  endproperty
 
  
  // ACTIVATE is sent on an emty page or a miss (PRE +  ACT)
  
  
  sequence ACT_S; 
    (!ddr_intf.cs_n) ##0 (!ddr_intf.act_n); 
  endsequence 
  
  property INIT_to_ACT;
    @(posedge ddr_intf.CK_t)
    ZQCL_CAL|=> ##[(tZQ):$] ACT_S;
  endproperty
  
  sequence PRE_S; 
    (!ddr_intf.cs_n) ##0 (ddr_intf.act_n) ##0
    (!ddr_intf.RAS_n_A16) ##0 (ddr_intf.CAS_n_A15) ##0 (!ddr_intf.WE_n_A14); 
  endsequence 
  
    property ACT_to_ACT; //Bank Life cycle(from BANK ACT to same BANK ACT)
    @(posedge ddr_intf.CK_t)
    ACT_S |=> ((##[tRRD : $] ACT_S) or (##[tRAS:tRAS+tRP] PRE_S)); 
  endproperty 
  
    property PRE_TO_ACT; //page miss 
    @(posedge ddr_intf.CK_t)
    PRE_S |=> (##[tRP:$] ACT_S); 
  endproperty 
  
  sequence REF_S;
    (!ddr_intf.cs_n) ##0 (ddr_intf.act_n) ##0 (!ddr_intf.RAS_n_A16)##0 
    (!ddr_intf.CAS_n_A15) ##0 (ddr_intf.WE_n_A14);
  endsequence
  
  property REF_to_REF; 
    @(posedge ddr_intf.CK_t)
    REF_S |=> ##[(tREFI) : (tREFI + 4)] REF_S; 
  endproperty 
  
 // can't assert tRFC, cant predict next valid cmd 
  
  sequence RD_S;
    (!ddr_intf.cs_n) ##0 (ddr_intf.act_n)##0 (ddr_intf.RAS_n_A16) ##0 
    (!ddr_intf.CAS_n_A15) ##0 (ddr_intf.WE_n_A14);
  endsequence
  
  sequence WR_S;
    (!ddr_intf.cs_n) ##0 (ddr_intf.act_n)##0 (ddr_intf.RAS_n_A16) ##0 
    (!ddr_intf.CAS_n_A15) ##0 (!ddr_intf.WE_n_A14);
  endsequence
  
  //ACT TO CAS 
  
  property tRCD_P; 
    @(posedge ddr_intf.CK_t) 
    ACT_S |=> ((##[tRCD:$] WR_S) or (##[tRCD:$] RD_S)); 
  endproperty 
  
  //write to write or write to read 
  
  property tCCDW_P;
    @(posedge ddr_intf.CK_t)
    WR_S |=> ((##[tRCD:$] WR) or ( ##[(tWTR + 4):$] RD_S));
endproperty
  
  
  //read to read or read to write 
  
  property tCCDR_P; 
    @(posedge ddr_intf.CK_t) 
    RD_S |=> ((##[tCCD:$] RD_S) or (##[(CL + (2 * AL) + BL/2 + CWL + 2) : $] WR_S));
  endproperty 
                        
  
/*
assert property(INIT_SEQ_P) 
   $display("INITIALIZATION PROPERTY SUCCESS at %0tns", $time);
   else
    $display("INITIALIZATION PROPERTY FAILED at %0tns ", $time);
  
  assert property(INIT_to_ACT)
    $display("RESET TO ACT PROPERTY SUCESS at %0tns", $time);
    else 
      $display("RESET TO ACT PROPERTY FAILED at %0tns", $time); 
    
  
 assert property(ACT_to_ACT) 
   $display("tRRD: ACT to ACT delay SUCCESS at %0tns", $time); 
    else
      $display("tRRD: ACT to ACT delay FAILED at %0tns", $time);
     
    
 assert property(PRE_TO_ACT) 
    $display("tRP: PRE to ACT delay SUCCESS at %0tns", $time); 
     else 
       $display("tRP: PRE to ACT delay FAILEDat %0tns", $time);
        
        
 assert property(REF_to_REF) 
   $display("tREFI: REF to REF delay SUCCESS at %0tns", $time);
   else 
    $display("tREFI: REF to REF delay FAILED at %0tns", $time); 
      
  
 assert property(tCCDR_P) 
   $display("tRCD: RAS to CAS delay SUCCESS at %0tns", $time); 
    else
     $display("tRCD: RAS to CAS delay FAILED at %0tns", $time); 
      
 assert property(CKE_P)
  $display("CKE PROPERTY SUCCESS at %0tns", $time); 
  else
   $display("CKE PROPERTY FAILED at %0tns", $time);
  
  */  

endmodule
