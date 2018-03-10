`include "ddr_pkg.pkg" 

module ctrl_refresh(ctrl_interface ctrl_intf, ddr_interface ddr_intf); 
  
  int refresh_counter; 

  /* Counter for keeping track of refresh intervals
  */

  always_ff@(posedge ddr_intf.CK_t) begin
    if(ctrl_intf.clear_refresh) begin
      refresh_counter <= 1'b0;
      ctrl_intf.refresh_rdy <= 1'b0;
      ctrl_intf.refresh_almost <= 1'b0; 
      ctrl_intf.refresh_done <= 0;
    end
    
    else begin
      refresh_counter <= refresh_counter + 1;
      if(refresh_counter == tREFI - 100) begin
        ctrl_intf.refresh_rdy <= 1'b0;
        ctrl_intf.refresh_almost <= 1'b1; 
      end  
      
      if(refresh_counter == tREFI - 1) begin //assert in next clock at tREFI 
        ctrl_intf.refresh_almost <= 1'b0; 
        ctrl_intf.refresh_rdy <= 1'b1; 
      end 
      
      if(refresh_counter == tREFI + tRFC) begin
        ctrl_intf.refresh_done <= 1'b1; 
        ctrl_intf.refresh_rdy <= 1'b0;
      end
    end 
  end
endmodule 
     
   
