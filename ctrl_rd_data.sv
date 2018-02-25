`include "ddr_pkg.pkg"


module ctrl_rd_data(ddr_interface ddr_intf, ctrl_interface ctrl_intf);
  
  logic rd_start_d;
  
  always_ff@(posedge ddr_intf.CK_t)begin
    if(rd_start_d)
      fork
        set_differential_dqs(ddr_intf.data_out);
        set_read_data_pins(ddr_intf.data_out);
      join 
    end
  
  
  task set_differential_dqs(input wr_data_type rw_D );
    begin
      @(posedge ddr_intf.CK_r)
      ddr_intf.dqs_t <=  1'b1; 
      ddr_intf.dqs_c <=  1'b0;
      repeat(rw_D.preamable)@(posedge ddr_intf.CK_r);// refer to jedec p.115
      repeat(rw_D.burst_length + 1) begin
        @(posedge ddr_intf.CK_r)
        ddr_intf.dqs_t <= !ddr_intf.dqs_t; 
        ddr_intf.dqs_c <= !ddr_intf.dqs_c;
      end 
      repeat (1) begin
        @(posedge ddr_intf.CK_r)
        ddr_intf.dqs_t = ~ddr_intf.dqs_t;
        ddr_intf.dqs_c =1'b1;
      end; 
      ddr_intf.dqs_t <= 1'b1; 
      ddr_intf.dqs_c <= 1'b1; 
    end
  endtask 
  
  
  
  task set_read_data_pins(input wr_data_type rw_D );
     begin 
       @(negedge  ddr_intf.CK_r)
       ddr_intf.dq = 'z ;
       repeat(rw_D.preamable) @(negedge ddr_intf.CK_r); 
       repeat(rw_D.burst_length + 1) begin  
         @(negedge  ddr_intf.CK_r)
         ddr_intf.dq = rw_D.wr_data[7:0]; 
         rw_D.wr_data=  {8'h00, rw_D.wr_data[63:8]};
       end 
       ddr_intf.dq = 'z;
     end 
  endtask 
  
  always@(posedge ddr_intf.CK_t) begin
    rd_start_d <=ctrl_intf.rd_start ;
  end 
  
endmodule 
