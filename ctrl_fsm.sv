/***********************************************************************************
  * Script : ctrl_fsm.sv *
  * Author: Laureen Giacaman *
  * Description: This module is responsible for implementing the controller FSM p.43
  *The controller has six main states: idle, initialization, refresh, update, activate
  * and read/write.
  *** ERRORS: Sends refresh while still in RW and WAIT::FIXED
  *** careful of mrs_update
  
**************************************************************************************/

`include "ddr_pkg.pkg"

module ctrl_fsm(ctrl_interface ctrl_intf, ddr_interface ddr_intf, tb_interface tb_intf);

 ctrl_fsm_type ctrl_state, ctrl_next_state;
  bit act_done, clear_update, update_done,clear_counter;
  int refresh_counter, row_cycle, update_counter;
   

  /*
  Next State transition
  */

  always_ff @(posedge ddr_intf.CK_t or negedge ddr_intf.reset_n)
    if(!ddr_intf.reset_n)
      begin
        ctrl_state <= CTRL_IDLE;
      end
  else
    begin
      ctrl_state <= ctrl_next_state;
    end

  /*
  Next State logic
  */

  always_comb
    case(ctrl_state)
      CTRL_IDLE: begin
        ctrl_intf.clear_refresh <= 1'b1;
        clear_update <= 1'b1;
        clear_counter <= 1'b1;
        ctrl_intf.busy <= 1'b0;
        tb_intf.rw_proc <= 1'b1; 
        if(ddr_intf.reset_n)
          ctrl_next_state <= CTRL_INIT;
      end

      CTRL_INIT:
        begin
         ctrl_intf.clear_refresh <= 1'b1;
         ctrl_intf.busy <= 1'b0;
         if(ctrl_intf.ini_done)
           begin 
             ctrl_next_state <= CTRL_ACTIVATE; //no open rows
             tb_intf.rw_proc <= 1'b1; 
          end
        end 

      CTRL_RW: //controller should always stay here unless refresh is out | update
        begin
          ctrl_intf.clear_refresh <= 1'b0;
          ctrl_intf.busy <= 1'b0;
          if(ctrl_intf.refresh_almost || tb_intf.mrs_update) 
            begin 
              ctrl_next_state <= CTRL_WAIT;
              tb_intf.rw_proc  <= 1'b0; //finish current RW b4 refresh
            end 
        end

      CTRL_WAIT:
        begin
          ctrl_intf.busy <= 1'b0;
          if(ctrl_intf.rw_idle) //finish current RW operation
            if(ctrl_intf.refresh_almost)
              begin
                ctrl_next_state <= CTRL_REFRESH;
              end
          else
            begin
              ctrl_intf.mrs_update_rdy <= 1;
              ctrl_next_state <= CTRL_UPDATE;
            end
        end

      CTRL_REFRESH:
        begin
          ctrl_intf.clear_refresh <= 1'b0;
          ctrl_intf.busy <= 1'b1;
          clear_counter <= 1'b1;
          if(ctrl_intf.refresh_done)
            begin
              ctrl_intf.clear_refresh <= 1'b1;
              ctrl_next_state <= CTRL_ACTIVATE; //all banks are precharged, can't go back to RW
              ctrl_intf.busy <= 1'b0;
            end
        end
            
      CTRL_ACTIVATE:
        begin
          ctrl_intf.clear_refresh <= 1'b0;
          clear_counter <= 1'b0;
          ctrl_intf.busy <= 1'b0;
          if(act_done)
            begin
              ctrl_next_state <= CTRL_RW;
              clear_counter <= 1'b1;
              tb_intf.rw_proc <= 1'b1; 
            end
          else if(tb_intf.mrs_update ||ctrl_intf.refresh_almost )
            begin
              ctrl_next_state <= CTRL_WAIT;
            end
        end

      CTRL_UPDATE:
        begin
          clear_update <= 1'b0;
          ctrl_intf.mrs_update_rdy <= 1'b0;
          ctrl_intf.busy  <= 1'b1;
          if(update_done)
            begin 
              clear_update <= 1'b1; 
              ctrl_intf.busy <= 1'b0;
              ctrl_next_state <= CTRL_RW;
            end 
        end 
      
      default: ctrl_next_state <= CTRL_IDLE; 

    endcase


	/* Counter for keeping track of row cycle (ACTIVATION + PRECHARGE)
    */
  always_ff@(posedge ddr_intf.CK_t)
    begin
      if(clear_counter)
        begin
          row_cycle <= 0;
          act_done <= 1'b0;
        end
      else
        begin
          row_cycle <= row_cycle + 1;
          if(row_cycle == tRC) begin
            act_done <= 1'b1;
          end
        end
    end

  /* Counter for keeping track of MRS update command to non-MRS
  */

  always_ff@(posedge ddr_intf.CK_t)
    begin
      if(clear_update)
        begin
          update_counter <= 1'b0;
          update_done <= 1'b1;
        end
      else
        begin
          update_counter <= update_counter + 1;
          if(update_counter == tMOD)
            begin
              update_done <= 1'b1;
              end
        end
    end
  
endmodule
