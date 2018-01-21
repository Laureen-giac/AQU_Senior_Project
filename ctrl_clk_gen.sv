`include "ddr_pkg.pkg"

module ctrl_clk_gen(ddr_interface ddr_intf); 

 timeunit 10ps ; 
 timeprecision 100ps ;

 
  //differential clock 
  initial
    begin
      ddr_intf.CK_t = 0 ;
      forever #HALF_PERIOD ddr_intf.CK_t = !ddr_intf.CK_t ;  
 end 
  
  initial
    begin 
     ddr_intf.CK_c =1 ;
     forever #HALF_PERIOD ddr_intf.CK_c = !ddr_intf.CK_c ; 
    end 
  
   initial 
     begin
       ddr_intf.CK_r <= 0;
       #QUAD_PERIOD;
       forever #QUAD_PERIOD ddr_intf.CK_r = !ddr_intf.CK_r;      
   end
endmodule 









