`include "ddr_pkg.pkg"

module dimm_model(ddr_interface ddr_intf, 
                  ctrl_interface ctrl_intf, 
                  tb_interface tb_intf);
  
  parameter MRS_C = 5'b01000; 
  parameter REF_c = 5'b01001; 
  parameter PRE_C = 5'b10101; 
  parameter ACT_C = 5'b00; 
  parameter WR_C = 5'b01100; 
  parameter RD_C = 5'b01101; 
  parameter NOP_C = 5'b1xxxx; 
  
  write_data dimm[*];
  bit[17:0] act_addr_store[$]; 
  bit[9:0] cas_addr_store[$], cas_addr, col_addr; 
  bit act, wr, rd, rd_d, rd_dd ,wr_d, act_d, rd_ddd, cycle_8_d, cycle_4_d; 
  bit rd_start_d,rd_start_dd, wr_end,wr_end_d, rd_start; 
   
  bit[4:0] cycle_8;
  bit[2:0] cycle_4; 
  
  logic[4:0][7:0] data_t, data_c; 
  logic[7:0][7:0] data;
  logic[4:0] cmd;
  bit [17:0] act_addr, row_addr;
  
  always_ff@(posedge ddr_intf.CK_t) begin
    rd_start_d <= rd_start;
    ctrl_intf.rd_start<= rd_start_d; 
    wr_end_d <= wr_end;
    rd_d<= rd ; 
    rd_dd <= rd_d ;
    wr_d <= wr ;
    act_d <= act ; 
    rd_ddd <= rd_dd ;
    cycle_8_d <= cycle_8[4];
    cycle_4_d <= cycle_4[2];
  end 
  
  always_ff@(posedge ddr_intf.CK_t) begin 
    cmd <= {ddr_intf.cs_n, ddr_intf.act_n, ddr_intf.RAS_n_A16, ddr_intf.CAS_n_A15, ddr_intf.WE_n_A14}; 
  end 
  
  always_comb begin 
    if(cmd[4:3] === ACT_C)begin 
      act <= 1'b1; 
      wr <= 1'b0; 
      rd <= 1'b0; 
    end 
    
    else if (cmd === WR_C)begin 
      act <= 1'b0; 
      wr <= 1'b1; 
      rd <= 1'b0; 
    end 
    
    else if(cmd === RD_C)begin 
      act <= 1'b0; 
      wr <= 1'b0; 
      rd <= 1'b1; 
    end
    else  begin 
      act <= 1'b0; 
      wr <= 1'b0;
      rd <= 1'b0;
    end 
  end 
  
  assign wr_end = (((cycle_8[4]) && (!cycle_8_d)) ||
                ((cycle_4[2]) && (!cycle_4_d)))? 1'b1:1'b0;
  
  always_ff@(posedge ddr_intf.CK_t) begin 
    rd_start   <= (ctrl_intf.dimm_req == RD_R) && (ctrl_intf.rd_rdy);
  end 
  
  always_ff@(posedge act)
    begin
      if(act) begin 
        act_addr = {ddr_intf.bg_addr, ddr_intf.ba_addr, ddr_intf.A13, ddr_intf.A12_BC_n, ddr_intf.A11, ddr_intf.A10_AP, ddr_intf.A9_A0};
      end 
    end 
  
  //when does read_start?
  
  always_ff@(posedge act_d   or posedge ctrl_intf.no_act_rdy or negedge ddr_intf.reset_n) begin
    bit[17:0] temp;
    
    if(!ddr_intf.reset_n)begin 
      act_addr_store.delete();
    end 
    else begin 
      if(act_d) begin
        act_addr_store.push_back(act_addr); 
      end
      
      else if (ctrl_intf.no_act_rdy) begin
        temp = {ctrl_intf.mem_addr.bg_addr, ctrl_intf.mem_addr.ba_addr,
                      ctrl_intf.mem_addr.row_addr};
        act_addr_store.push_back(temp); 
      end 
    end 
  end 
  
  always_ff@(posedge wr or posedge rd)begin
    cas_addr <= ddr_intf.A9_A0; 
  end 
  
  always_ff@(posedge rd_d or posedge  wr_d or negedge ddr_intf.reset_n) begin
    if(!ddr_intf.reset_n) begin
      cas_addr_store.delete();
    end
    else if(rd_d || wr_d) begin 
      cas_addr_store.push_back(cas_addr);
    end 
  end 
  
  always_ff@( posedge wr_end , posedge rd_start ) begin 
    if((wr_end || rd_start) &&
       ((act_addr_store.size() != 0) && (cas_addr_store.size() != 0 ))) begin 
      row_addr = act_addr_store.pop_front(); 
      col_addr = cas_addr_store.pop_front();
    end 
  end 
  
  always_ff@(posedge ddr_intf.dqs_t)
    begin
      if(ctrl_intf.dimm_req == WR_R) 
       data_t <= {ddr_intf.dq, data_t[4:1]};
    end
  
  always_ff@(posedge ddr_intf.dqs_c , negedge ddr_intf.reset_n)begin
    if(!ddr_intf.reset_n) begin
      cycle_8 <= 5'b10000;
      cycle_4 <= 3'b100;
    end 
    
    else if(ctrl_intf.dimm_req == WR_R) begin
      data_c <= {ddr_intf.dq, data_c[4:1]}; 
      if(ctrl_intf.BL == 8 ) 
        cycle_8 <= {cycle_8[3:0] , cycle_8[4]}; 
      else
        cycle_4 <= {cycle_4[1:0] , cycle_4[2]}; 
    end
  end
  
  always_ff@( posedge wr_end_d or posedge  rd_start_d or negedge  ddr_intf.reset_n) begin
    bit[27:0] dimm_index; 
    
    if(!ddr_intf.reset_n) begin 
      dimm_index <= '0;
    end
    
    else if ((rd_start_d) && (ctrl_intf.BL == 8)) begin
      dimm_index = {row_addr, col_addr};
      ddr_intf.data_out.wr_data = dimm[dimm_index];
      ddr_intf.data_out.burst_length = ctrl_intf.BL;
      ddr_intf.data_out.preamable = tb_intf.RD_PRE;
    end
    
    else if((rd_start_d) && (ctrl_intf.BL == 4)) begin 
      dimm_index = {row_addr, col_addr};
      ddr_intf.data_out.wr_data[31:0] = dimm[dimm_index];
      ddr_intf.data_out.burst_length = ctrl_intf.BL;
      ddr_intf.data_out.preamable = tb_intf.RD_PRE;
    end 
    
    else if ((wr_end_d) && (ctrl_intf.BL == 8)) begin
      dimm_index = {row_addr, col_addr};
      dimm[dimm_index] = {data_c[4] , data_t[3], data_c[3], data_t[2], 
                                       data_c[2], data_t[1], data_c[1], data_t[0]};
    end 
    
    else if((wr_end_d)&& (ctrl_intf.BL == 4)) begin 
      dimm[{row_addr,col_addr}] = {data_c[4],data_t[3],data_c[3],data_t[2]}; 
   end
      
  end
endmodule 
