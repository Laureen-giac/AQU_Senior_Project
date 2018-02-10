/***********************************************************************************
  * Script : ctrl_burst_cas.sv *
  * Author: Laureen Giacaman *
  * Description: This module is responsible for controlling the CAS timing latencies
    which are tRCD: ACT to CAS delay which only comes into play whenever a request
    arrives for a data that is not in an actitve row. and tCCD which is the delay
    from one column access to the next column.
    CAS: READ OR WRITE
  
  ERRORS: PREV REQ:: FIXED 
***********************************************************************************/

`include "ddr_pkg.pkg"

module ctrl_burst_cas(ctrl_interface ctrl_intf, ddr_interface ddr_intf);

  cas_fsm_type cas_state, cas_next_state;
  bit clear_cas_counter, clear_extra_counter, next_cas, rtw, ignore;
  int rc_counter, cas_counter, extra_wait, extra_counter, cas_delay;
  int act_rw_trk[$]; 
  logic[2:0]request,  prev_req; 
  logic[2:0] act_cmd_trk[$];

  always_ff@(posedge ddr_intf.CK_t or negedge ddr_intf.reset_n)
    begin
      if(!ddr_intf.reset_n)
        begin
          cas_state <= CAS_IDLE;
        end
      else
        cas_state <= cas_next_state;
    end


  always_comb
    begin
      if(!ddr_intf.reset_n)
        begin
          cas_next_state <= CAS_IDLE;
          clear_extra_counter <= 1'b1;
          clear_cas_counter <= 1'b1;
          ctrl_intf.cas_rdy <= 1'b0;
          ctrl_intf.cas_idle <= 1'b1;
          prev_req <= RD_R; 
          //ignore = 1'b0;
        end
      else
        begin
          case(cas_state)
            CAS_IDLE: begin
              clear_extra_counter <= 1'b1;
          	  clear_cas_counter <= 1'b1;
          	  ctrl_intf.cas_rdy <= 1'b0;
              ctrl_intf.cas_idle <= 1'b1;
              
              if(!ignore)
                begin
                  prev_req <= ctrl_intf.act_rw;
                  ignore = 1'b1;
                end 

              /* Wait for an ACTIVATE. When skipped?
              *********CHECK BURST_ACT**************
              */

              if(ctrl_intf.act_rdy || ctrl_intf.no_act_rdy)
                begin
                  cas_next_state <= CAS_WAIT_ACT;
                  
                end
            end

             CAS_WAIT_ACT: begin
              if(ctrl_intf.act_rw) begin 
              clear_cas_counter <= 1'b0;
              if(cas_counter == cas_delay)
                begin
                  clear_cas_counter <= 1'b1;
                  if ((request == prev_req) ||
                      (request  == RD_R && prev_req == RDA_R) ||
                      (request == RDA_R && prev_req == RD_R) ||
                      (request == WR_R && prev_req == WRA_R) ||
                      (request == WRA_R && prev_req == WR_R))
                    begin
                      clear_cas_counter <= 1'b0;
                      cas_next_state <= CAS_CMD;
                      ctrl_intf.cas_req <= request;
                      ctrl_intf.cas_rdy <= 1'b1; 
                      prev_req <= request;
                      clear_extra_counter <= 1'b1;
                    end
                  else
                    begin
                      get_extra_wait(.prev_req(prev_req),
                                     .req(ctrl_intf.req),
                                     .extra_wait(extra_wait));
                      prev_req <= request;
                      if(rtw)
                        begin
                          cas_next_state <= CAS_WAIT_DATA;
                        end 
                      else 
                        cas_next_state <= CAS_EXTRA_WAIT;  
                    end 
                end
              end 
              else 
                cas_next_state <= CAS_WAIT_ACT; 
            end 
            
            CAS_WAIT_DATA: begin 
              clear_extra_counter <= 1'b1; 
              if(ctrl_intf.rw_done) 
                begin 
                  cas_next_state <= CAS_EXTRA_WAIT; 
                end 
            end 
            
            CAS_EXTRA_WAIT: begin
              clear_extra_counter <= 1'b0; 
            
            if(extra_counter == extra_wait)
                begin
                  clear_extra_counter <= 1'b1;
                  cas_next_state <= CAS_CMD;
                  ctrl_intf.cas_req <= request;
                  ctrl_intf.cas_rdy <= 1'b1;
                end

            end     

            CAS_CMD: begin

              ctrl_intf.cas_rdy <= 1'b0;

              if(next_cas)
                begin
                  cas_next_state <= CAS_WAIT_ACT;
                end

              else
                begin
                  cas_next_state <= CAS_IDLE;
                end
            end
          
          endcase

        end

    end


  //optimize
  always_ff@(posedge ddr_intf.CK_t)
    begin
      if (clear_cas_counter == 1'b1)
       	  cas_counter <= 0;
      else
        begin 
          cas_counter <= cas_counter + 1;
        end 
    end 
  
  always_ff@(posedge ddr_intf.CK_t)
    begin
      if (clear_extra_counter == 1'b1)
        extra_counter <= 0;
      else
        extra_counter <= extra_counter + 1;
    end

  //
  
  always @ (negedge ddr_intf.reset_n,posedge  ctrl_intf.act_rdy,posedge   ctrl_intf.no_act_rdy,posedge next_cas)
    begin
      int temp;
      if (!ddr_intf.reset_n) 
        begin
          act_cmd_trk.delete();
     	  act_rw_trk.delete();
          cas_delay = 0;
          request   = '0;
        end
      
      if (((cas_state == CAS_IDLE) || (cas_state == CAS_CMD)) && 
       ((ctrl_intf.act_rdy)     || (ctrl_intf.no_act_rdy))) 
        begin
          cas_delay = tRCD - 1;
          if(ctrl_intf.act_rw) begin 
            request   = ctrl_intf.act_rw;
          end 
        end 
      
      
      else if ((cas_state == CAS_CMD) && (next_cas)) 
        begin
         temp = (tRCD - act_rw_trk.pop_front - 1);
          
          if (temp > ctrl_intf.tCCD)
            cas_delay = temp;
          else
            cas_delay = ctrl_intf.tCCD;
          
          request   = act_cmd_trk.pop_front;
     
         foreach (act_rw_trk[i]) 
          act_rw_trk[i] = {(act_rw_trk[i] + cas_delay +1 )};
        end
    end
  
  always @(ctrl_intf.act_rdy, ctrl_intf.no_act_rdy)
    begin  
      
      if (((ctrl_intf.act_rdy) || (ctrl_intf.no_act_rdy))  && 
       ((cas_state != CAS_IDLE)  && (cas_state != CAS_CMD))) 
        begin
          act_rw_trk.push_back(cas_delay - cas_counter);
          act_cmd_trk.push_back(ctrl_intf.act_rw); 
        end       
    end 


  always_ff@(posedge ddr_intf.CK_t)
    begin
      if((cas_state == CAS_CMD) &&(act_rw_trk.size() != 0))
        begin
          next_cas = 1'b1;
        end
      else
        next_cas = 1'b0;
    end


  function void get_extra_wait(input logic[2:0] prev_req, req, output int extra_wait);

    begin
      /*Read to Write Delay */
      if ((prev_req  == RD_R && req == WR_R) ||
          (prev_req == RD_R && req == WRA_R) ||
          (prev_req == RDA_R && req == WR_R) ||
          (prev_req == RDA_R && req == WRA_R))
        begin
          //user programmed refer to waveform
          extra_wait = ctrl_intf.CL - ctrl_intf.AL  - ctrl_intf.CWL + ctrl_intf.BL/2 + 2;
          rtw = 1'b1; 
        end
      else //Write to Read
        begin 
          extra_wait = tWTR + 4;
          rtw = 1'b0; 
         end 
      
    end
  endfunction


endmodule
