/***********************************************************************************
 * Script : ctrl_init.sv *
 * Author: Diana Atiyeh *
 * Description: This module is responsible for controlling the reset and      
   power up initialization sequence of the DDR4 memory. 
***********************************************************************************/

`include "ddr_pkg.pkg" 


module ctrl_init( ctrl_interface ctrl_intf,ddr_interface ddr_intf, tb_interface tb_intf);
  
  event config_done; 
  
  always@(ddr_intf.reset_n) begin
    if (!ddr_intf.reset_n)
      initialize();
  end
  
  task initialize(); 
    ddr_intf.CKE <= 1'b0; 
    ctrl_intf.ini_done <= 1'b0;
    ctrl_intf.des_rdy <= 1'b0;
    ctrl_intf.zqcl_rdy <= 1'b0;
    ctrl_intf.mrs_rdy <= 1'b0;
    ctrl_intf.BL = 2'b00; 
    ctrl_intf.AL = 2'b00; 
    
    wait(ddr_intf.reset_n);
    repeat(tCKE - tIS) @(posedge ddr_intf.CK_t);
    ddr_intf.CKE <= 1'b1; 
    
    repeat(tIS) @(posedge ddr_intf.CK_t); 
    ctrl_intf.des_rdy <= 1'b1; 
    ctrl_intf.mode_reg <= 'x;
    
    @(posedge ddr_intf.CK_t); 
    ctrl_intf.des_rdy <= 1'b0;
    
    repeat(tXPR)@(posedge ddr_intf.CK_t);
   	// MR3 
    ctrl_intf.mrs_rdy<= 1'b1; 
    ctrl_intf.mode_reg <={1'b0,3'b011,1'b0,1'b0,2'b00,2'b00,3'b000,1'b0,1'b0,1'b0,1'b0,2'b00};
    
    @(posedge ddr_intf.CK_t) ;
    ctrl_intf.mrs_rdy <= 1'b0 ;
    ctrl_intf.des_rdy <= 1'b1; 
    ctrl_intf.mode_reg<= 'x;
    
    //MR6
    repeat(tMRD)@(posedge ddr_intf.CK_t);
    ctrl_intf.des_rdy <= 1'b0; 
    ctrl_intf.mrs_rdy <= 1'b1; 
    ctrl_intf.mode_reg <={1'b0,3'b110, 1'b0,1'b0,tb_intf.tCCD,1'b0,1'b0,1'b0,1'b0,6'b000000}; 
    
    @(posedge ddr_intf.CK_t) ;
    ctrl_intf.mrs_rdy <= 1'b0; 
    ctrl_intf.des_rdy <= 1'b1; 
    ctrl_intf.mode_reg<= 'x;
    
    //MR5
    repeat(tMRD)@(posedge ddr_intf.CK_t);
    ctrl_intf.des_rdy <= 1'b0; 
    ctrl_intf.mrs_rdy <= 1'b1; 
    ctrl_intf.mode_reg <={1'b0,3'b101, 1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,3'b000,1'b0,1'b0,1'b0,3'b000};
    
    @(posedge ddr_intf.CK_t) ;
    ctrl_intf.des_rdy <= 1'b1;  
    ctrl_intf.mrs_rdy <= 1'b0; 
    ctrl_intf.mode_reg<= 'x;
    
    //MR4
    repeat(tMRD)@(posedge ddr_intf.CK_t);
    ctrl_intf.mrs_rdy <= 1'b1; 
    ctrl_intf.des_rdy <= 1'b0; 
    ctrl_intf.mode_reg <={1'b0,3'b100, 1'b0,1'b0,tb_intf.WR_PRE,tb_intf.RD_PRE,1'b0,1'b0,3'b000,1'b0,1'b0,1'b0,1'b0,1'b0}; 
    
    @(posedge ddr_intf.CK_t);
    ctrl_intf.des_rdy <= 1'b1; 
    ctrl_intf.mrs_rdy <= 1'b0; 
    ctrl_intf.mode_reg<= 'x;
    
    //MR2
    repeat(tMRD)@(posedge ddr_intf.CK_t);
    ctrl_intf.des_rdy <= 1'b0;  
    ctrl_intf.mrs_rdy <= 1'b1; 
    ctrl_intf.mode_reg<={1'b0,3'b010, 1'b0,1'b0,1'b0,1'b0,2'b00, 1'b0,2'b00,tb_intf.CWL,3'b000};
    
    @(posedge ddr_intf.CK_t) ;
    ctrl_intf.mrs_rdy <= 1'b0; 
    ctrl_intf.mode_reg<= 'x;
    ctrl_intf.des_rdy <= 1'b1;
    
    //MR1
    repeat(tMRD)@(posedge ddr_intf.CK_t);
    ctrl_intf.des_rdy <= 1'b0; 
    ctrl_intf.mrs_rdy <= 1'b1;  
    ctrl_intf.mode_reg<={1'b0,3'b001,1'b0,1'b0,1'b0,1'b0,3'b000,1'b0,2'b00,tb_intf.AL,2'b00,1'b0 };
    
    @(posedge ddr_intf.CK_t) ;
    ctrl_intf.des_rdy <= 1'b1; 
    ctrl_intf.mode_reg<= 'x ;
    ctrl_intf.mrs_rdy <= 1'b0; 
    
    //MR0
    repeat(tMRD) @(posedge ddr_intf.CK_t); 
    ctrl_intf.des_rdy <= 1'b0; 
    ctrl_intf.mrs_rdy <= 1'b1;  
    ctrl_intf.mode_reg<={1'b0,3'b000,1'b0,1'b0,1'b0,3'b000,1'b0,1'b0,tb_intf.CL,1'b0,1'b0, tb_intf.BL };
    
    @(posedge ddr_intf.CK_t);
    ctrl_intf.mrs_rdy <= 1'b0; 
    ctrl_intf.des_rdy <= 1'b1; 
    ctrl_intf.mode_reg<= 'x; 
    
    repeat(tMOD) @(posedge ddr_intf.CK_t);
    ctrl_intf.des_rdy <= 1'b0;
    ctrl_intf.zqcl_rdy <= 1'b1;
    @(posedge ddr_intf.CK_t )
    ctrl_intf.des_rdy <= 1'b1; 
    ctrl_intf.zqcl_rdy <=1'b0;
    
    repeat(tZQ) @(posedge ddr_intf.CK_t); 
    ctrl_intf.ini_done  <= 1'b1;
    ctrl_intf.des_rdy <=1'b0;
    ->config_done;  
    endtask 
  
endmodule 


