module ctrl_rw(ctrl_interface ctrl_intf, ddr_interface ddr_intf);

  rw_fsm_type current_rw_state ,next_rw_state ;

  logic  clear_rw_counter;
  logic [2:0]cas_type_track[$];
  logic [2:0]cas_cmd_out;
  int rw_counter, rw_delay;
  int cas_command_track[$];
  int new_data;
  int delay;
  
  
  always_ff@(posedge ddr_intf.CK_t or  ddr_intf.reset_n)
    begin
      if(!ddr_intf.reset_n)
        current_rw_state <= RW_IDLE ;
      else
        current_rw_state <=  next_rw_state ;
    end

  always_comb
    begin
      if(!ddr_intf.reset_n )
        begin
          clear_rw_counter <=1'b1;
      	  ctrl_intf.rd_rdy <=1'b0;
          ctrl_intf.wr_rdy <=1'b0;
          ctrl_intf.rda_rdy <= 1'b0;
          ctrl_intf.wra_rdy <= 1'b0;
          ctrl_intf.rw_done <= 1'b0;
          ctrl_intf.data_idle <= 1'b1;
          next_rw_state <= RW_IDLE;
        end

      else
        begin
          case(current_rw_state)
            
            RW_IDLE: begin
              ctrl_intf.rw_done <=1'b1;
              ctrl_intf.data_idle <= 1'b1;
              ctrl_intf.rd_rdy <= 1'b0;
              ctrl_intf.wr_rdy <= 1'b0;
              ctrl_intf.rda_rdy <= 1'b0;
              
              if(ctrl_intf.cas_rdy)
              begin
                next_rw_state <= RW_WAIT_STATE;
                clear_rw_counter <= 1'b1 ;
              end
            else
              begin 
                next_rw_state <= RW_IDLE;
                clear_rw_counter <= 1'b0;
              end 
            end

         RW_WAIT_STATE: begin
           ctrl_intf.rw_done <= 1'b0;
           ctrl_intf.data_idle <= 1'b0;
           clear_rw_counter<=1'b0 ;
           if(rw_counter == rw_delay)
             begin
               next_rw_state <= RW_DATA;
               clear_rw_counter <= 1'b1 ;
               if(cas_cmd_out == RD_R)
               ctrl_intf.rd_rdy <= 1'b1;
               else
                ctrl_intf.wr_rdy <=1'b1;
             end
           else
             next_rw_state <= RW_WAIT_STATE;
         end


          RW_DATA: begin
            clear_rw_counter <= 0 ;
            ctrl_intf.rw_done <=1 ;
            ctrl_intf.rd_rdy <= 0 ;
            ctrl_intf.wr_rdy <= 0 ;

            if(new_data) begin
              next_rw_state <= RW_WAIT_STATE;
            end

            else
               next_rw_state <=RW_IDLE ;
             end

            default : next_rw_state  <= RW_IDLE;

            endcase
        end
    end
  
  always@(ctrl_intf.cas_rdy , new_data, ddr_intf.reset_n)
    begin
      if(!ddr_intf.reset_n) begin
        cas_command_track.delete();
        cas_type_track.delete(); 
        rw_delay <= 0 ;
        end

      else if((current_rw_state ==RW_IDLE) && (ctrl_intf.cas_rdy)) begin

        cas_cmd_out =ctrl_intf.act_rw;
        
        if(cas_cmd_out == RD_R) begin
          delay = ctrl_intf.CL + ctrl_intf.AL - ctrl_intf.RD_PRE ;
        end

        else
          begin
          delay =  ctrl_intf.CWL + ctrl_intf.AL - ctrl_intf.WR_PRE;
          end

        rw_delay = delay  ;

      end

      else if((current_rw_state ==RW_WAIT_STATE) && (ctrl_intf.cas_rdy))
        begin
          cas_command_track ={cas_command_track , rw_delay - rw_counter };
          cas_type_track={cas_type_track, ctrl_intf.cas_req};
        end

      else if((current_rw_state ==RW_DATA)&& (new_data))
        begin
          cas_cmd_out = cas_type_track.pop_front;

          if(cas_cmd_out == RD_R)begin

            delay = ctrl_intf.CL+ctrl_intf.AL  - ctrl_intf.RD_PRE ;
          end

        else
          begin
          delay= ctrl_intf.CWL + ctrl_intf.AL - ctrl_intf.WR_PRE;
          end

        rw_delay =  delay - cas_command_track.pop_front;

        foreach(cas_command_track[i])
          cas_command_track[i] = {( cas_command_track[i] + rw_delay + 1)};

      end

      if ((current_rw_state == RW_DATA) && (ctrl_intf.cas_rdy))
        begin
          cas_command_track ={cas_command_track , rw_delay };
          cas_type_track={cas_type_track, ctrl_intf.cas_req};
        end
    end


  always_ff@(posedge ddr_intf.CK_t )
    begin
      if(clear_rw_counter)
        rw_counter <= 0;
      else
        rw_counter <= rw_counter +1;
    end

  always_ff@(posedge ddr_intf.CK_t )
    begin
      if((cas_command_track.size != 0) && (next_rw_state == RW_DATA ))
        new_data <=1'b1 ;
      else
        new_data <= 1'b0 ;
    end


endmodule
