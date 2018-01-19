/***********************************************************************************
  * Script : ctrl_burst_act.sv *
  * Author: Diana Atiyeh *
  * Description: This module is responsible for controlling the ACTIVATE command
  *This module keeps an array of open rows indexed by the bank group and bank address
  *A row hit is an open row.
  *A row miss is closed row in an open bank
  *An empty page is a closed bank
*******************************************************************/


`include "ddr_pkg.pkg"


module ctrl_burst_act(ctrl_interface ctrl_intf, ddr_interface ddr_intf, tb_interface tb_intf);

  act_fsm_type current_activate_state, next_activate_state;

  int activate_counter;
  logic hit;
  logic miss;
  logic empty;
  logic clear_activate_counter ;
  logic act_rdy, activate_ready_d; // empty page
  logic no_activate_command , no_activate_command_d;
  logic bank_init;
  logic cas_d, rw_d;
  logic [15:0 ][14:0]bank_activated ; // keep track of open banks
  bit  [2:0]Request_Type ; // this register contains if the request read or write
  int EXTRA_CYCLES  ;
  bit act_cmd;

  // this  is self defind
  assign ctrl_intf.act_rdy = act_rdy;
  assign ctrl_intf.no_act_rdy =  no_activate_command ;


  always_comb
    begin
      ctrl_intf.rw_idle <=  (ctrl_intf.cas_idle) && (ctrl_intf.act_idle) && (ctrl_intf.data_idle) ;
    end


  always_ff @(posedge ddr_intf.CK_t  or negedge ddr_intf.reset_n )
  begin
    if(!ddr_intf.reset_n)
      current_activate_state <=  ACTIVATE_IS_IDLE ;
    else
      begin
        current_activate_state <= next_activate_state ;
        no_activate_command_d <=  no_activate_command ;
        activate_ready_d <= act_rdy;
        cas_d <= ctrl_intf.cas_rdy;
        rw_d <=  ctrl_intf.rw_rdy;
      end
  end

  always_comb
    begin
      if(!ddr_intf.reset_n) begin
        clear_activate_counter <= 1'b1 ;
        act_rdy<=0 ;
        no_activate_command <= 1'b0 ;
        next_activate_state <=  ACTIVATE_IS_IDLE ;
        ctrl_intf.act_idle <= 1'b0;
        bank_init <= 1;
        check_for_activated_bank();
      end

      else
        begin
        case(current_activate_state)
          ACTIVATE_IS_IDLE : begin
            act_rdy <= 0 ;
            no_activate_command <= 1'b0;
            ctrl_intf.pre_rdy <= 1'b0;
            ctrl_intf.act_idle <= 1'b1;
            bank_init <= 0 ;

            if((tb_intf.cmd_rdy) || (ctrl_intf.rw_proc)) begin
              next_activate_state <=  ACTIVATE_WAIT_STATE ;
              check_for_activated_bank ();
            end
          end

          ACTIVATE_WAIT_STATE:  begin
            no_activate_command <= 1'b0 ;
            act_rdy <= 1'b0 ;
            clear_activate_counter <= 1'b0 ;
            ctrl_intf.act_idle <= 1'b0 ;
            ctrl_intf.pre_rdy <= 1'b0 ;

            if( (activate_counter== tRRD)  && ( hit ) && (!miss)) begin
              // in this case not activate command needed
              next_activate_state <=  ACTIVATE_CAS ;
              ctrl_intf.act_rw  <= ctrl_intf.req;
              no_activate_command <= 1'b1;
            end

            else
              if( (activate_counter== tRRD)  && (miss ) && (!hit))
              next_activate_state <=  PRECHARGE_WAIT_DATA ;

           else
             if((activate_counter== tRRD)  && (!miss)  && (!hit))
               begin
                 next_activate_state <=  ACTIVATE_COMMAND ;
                 ctrl_intf.act_rw  <= ctrl_intf.req;
                 act_rdy <=  1'b1;
               end

         else begin
              next_activate_state <=  ACTIVATE_WAIT_STATE;
            end
          end

          ACTIVATE_COMMAND: begin
            clear_activate_counter <= 1'b1;
            next_activate_state <=  ACTIVATE_IS_IDLE;
            act_rdy <= 1'b0;
          end

          ACTIVATE_CAS:begin
            hit <= 1'b0;
            no_activate_command <=  1'b0;
            clear_activate_counter <= 1'b1;
            next_activate_state <=ACTIVATE_IS_IDLE;
          end

          PRECHARGE_WAIT_DATA:begin
            miss <= 0 ;
            clear_activate_counter <= 1'b1 ;
            if(ctrl_intf.cas_idle ) begin
              next_activate_state <=  PRECHARGE_WAIT_STATE;
              Request_Type <= ctrl_intf.cas_req;
              ctrl_intf.pre_reg <= { ctrl_intf.mem_addr.bg_addr,
                                     ctrl_intf.mem_addr.ba_addr, 15'bx, 10'bx};
            end
          end


          PRECHARGE_WAIT_STATE : begin
            clear_activate_counter <= 1'b0;
            RW_Extra_Cycles () ;
            // we have to decide if the last cas command was read or write
            if(activate_counter == EXTRA_CYCLES) begin
              next_activate_state <=  PRECHARGE_COMMAND;
              ctrl_intf.pre_rdy <= 1;
            end
          end

          PRECHARGE_COMMAND : begin
            ctrl_intf.pre_rdy <= 0 ;
            clear_activate_counter<= 1'b1;
            next_activate_state <= AFTER_PRECHARGE_CMD_DELAY ;
          end

          AFTER_PRECHARGE_CMD_DELAY : begin
            clear_activate_counter <= 1'b0 ;
            if( activate_counter == tRP)begin
              act_rdy <= 1 ;
              ctrl_intf.act_rw  <= ctrl_intf.req;
               next_activate_state <= ACTIVATE_COMMAND ;
          end

          end

        endcase

      end

    end

  always_ff @(posedge ddr_intf.CK_t)
  begin
    if(clear_activate_counter)
      activate_counter <= 1'b0 ;
    else
     activate_counter <= activate_counter + 1;
  end

  function  void check_for_activated_bank ();
        begin
      int index;
      index = int'({ctrl_intf.mem_addr.bg_addr, ctrl_intf.mem_addr.ba_addr}) ;
      if(bank_init)
        bank_activated ='z ;
      else
        begin
          if(  bank_activated[index] == ctrl_intf.mem_addr.row_addr) begin // same bank same row
            hit =1;
            miss=0;
            empty = 1'b0;
            $display("Page hit");
          end

          else if(bank_activated[index]===15'bz) begin// bank not  activated
            miss <= 0 ;
            hit <= 0 ;
            empty = 1'b1;
            $display("Page Empty");
            bank_activated[index] <=  ctrl_intf.mem_addr.row_addr ;
          end

          else if( bank_activated[index] !=  ctrl_intf.mem_addr.row_addr) begin
            bank_activated[index] <=  ctrl_intf.mem_addr.row_addr ;
            miss <= 1 ;
            hit  <= 0 ;
            empty = 1'b0;
            $display("Page miss");
          end
        end
    end

  endfunction


  function void RW_Extra_Cycles ();

    if(Request_Type == RD_R)
      EXTRA_CYCLES <= tRTP;

    if(Request_Type ==  WR_R)
      EXTRA_CYCLES  <= tWR + tWTR + 4 ;

  endfunction


endmodule
