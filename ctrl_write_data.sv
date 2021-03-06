`include "ddr_pkg.pkg"

module ctrl_write_data(ctrl_interface ctrl_intf, ddr_interface ddr_intf, tb_interface tb_intf) ; 


  wr_data_type wr_in , wr_out,wr_out_final;  
  wr_data_type wr_queue[$]; 
  
  always_comb 
  begin 
    if(!ddr_intf.reset_n)
      begin 
        wr_queue.delete(); 
      end 
    
    if(ctrl_intf.act_rdy || ctrl_intf.no_act_rdy )
      begin
        if(tb_intf.wr_data != '1)
          begin 
            wr_in.burst_length = ctrl_intf.BL ;
            wr_in.preamable = ctrl_intf.WR_PRE;
            wr_in.wr_data = tb_intf.wr_data; 
            wr_queue.push_back(wr_in);
           // $display("the ctrl_intf.BLis %d",ctrl_intf.BL);
         end
      end 
     end
  
   always_ff@(posedge ctrl_intf.wr_rdy)
    begin 
      wr_out = wr_queue.pop_front();
    // $display("the  wr_out is %h ",wr_out );
    end
     
  always@(ddr_intf.CK_t)
     begin
        if ((ctrl_intf.wr_rdy))
          begin
            wr_out_final = wr_out;
          //  $display("the  wr_out is %h ",wr_out_final );
            fork
              set_diff_dqs(.rw_D(wr_out_final));
         	  set_wr_pins (.rw_D(wr_out_final));
              //$display("wr_out_final %h\n", wr_out_final);
              
            join 
     
        end
    end
  
  task set_wr_pins(input wr_data_type rw_D );
     begin 
    //$display("the  rw_D is %h ",rw_D ); 
       @(negedge  ddr_intf.CK_r);
       ddr_intf.dq = 'z ;
       repeat(rw_D.preamable) @(negedge ddr_intf.CK_r); 
       repeat(rw_D.burst_length + 1)
         begin  
           @(negedge ddr_intf.CK_r)
           ddr_intf.dq = rw_D.wr_data[7:0]; 
           //$display("the  ddr_intf.dq is %h ",ddr_intf.dq ); 
           rw_D.wr_data=  {8'h00, rw_D.wr_data[63:8]} ;
          
         end 
     ddr_intf.dq = 'z;
     end 
  endtask 
 
     
  task set_diff_dqs(input wr_data_type rw_D);
     begin
     @(posedge ddr_intf.CK_r );
     ddr_intf.dqs_t <=  1'b1; 
     ddr_intf.dqs_c <=  1'b0;
       repeat(rw_D.preamable-1)@(posedge ddr_intf.CK_r);// refer to jedec p.115
       repeat(rw_D.burst_length +1 ) 
       begin
         @(posedge ddr_intf.CK_r)
         ddr_intf.dqs_t <= !ddr_intf.dqs_t; 
     	 ddr_intf.dqs_c <= !ddr_intf.dqs_c;
       end 
       repeat (1) begin
         @ (posedge ddr_intf.CK_r)
     ddr_intf.dqs_t = ~ddr_intf.dqs_t;
     ddr_intf.dqs_c =1'b1;
   end;  
      
       ddr_intf.dqs_t <= 1'b1; 
       ddr_intf.dqs_c <= 1'b1; 
     end
  endtask 
      
endmodule
