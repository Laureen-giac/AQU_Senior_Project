
module MC_DDR4(CLOCK_50, HEX0[6:0], HEX1[6:0], HEX2[6:0], HEX3[6:0], HEX4[6:0],HEX5[6:0], 
			          HEX6[6:0], HEX7[6:0], LEDR[17:0], LEDG[8:0], SW[17:0], busy);  
  
  input CLOCK_50;  
  input [17:0] SW; 
 
 
  output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7; 
  output [17:0] LEDR; 
  output [8:0] LEDG; 
  output busy; 
  
  reg [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7; 
  reg [17:0] LEDR; 
  reg [8:0] LEDG; 
  reg busy; 
  reg ini_count_done; 
  
  wire CK_t; 
  
  parameter CTRL_IDLE = 0; 
  parameter CTRL_INIT = 1; 
  parameter CTRL_ACTIVATE = 2; 
  parameter CTRL_RW = 3; 
  parameter tMOD = 10;
  parameter trrd = 10; 
  parameter tccd = 10; 
 
 reg[1:0] ctrl_state, ctrl_next_state; 
 reg clr_ini_count;  
 reg [3:0] ini_count; 
 reg [3:0] act_count; 
 reg [3:0] rw_count; 
 
  clock_divider clk_div(.clk_50mhz(CLOCK_50), .rst_50mhz(SW[0]), .out_5hz(CK_t));
  
  always@(posedge CK_t or negedge SW[1])
    if(!SW[1])
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

  always@(ctrl_state, SW[1])
    case(ctrl_state)
      CTRL_IDLE: begin
        LEDG[0] <= 1'b0;
        LEDG[1] <= 1'b0; 
        LEDR[0] <= 1'b0; 
        LEDR[1] <= 1'b0;  
        clr_ini_count <= 1'b1; 
        if(SW[1])
          ctrl_next_state <= CTRL_INIT;
          clr_ini_count <= 1'b0; 
          LEDG[0] <= 1'b1;  //busy during initialization 
      end

      CTRL_INIT:
        begin 
         LEDG[0] <= 1'b0;
         LEDR[0] <= 1'b0; 
         if(!ini_count_done) begin 
			LEDR[0] = 1'b1; 
           ctrl_next_state <= CTRL_INIT;
	     end
	     
	     else begin 
             LEDG[0] <= 1'b0; 
             LEDG[1] <= 1'b1; //ini done 
             ctrl_next_state <= CTRL_ACTIVATE; //no open rows 
          end
        end 

    /*  CTRL_RW: //controller should always stay here unless refresh is out | update
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
*/  
    endcase 

  always@(posedge CK_t) 
    if(clr_ini_count) 
      ini_count <= 0; 
      
  else if(ini_count < tMOD) begin 
		ini_count <= ini_count + 1; 
		ini_count_done <= 1'b0;
	end  
	
	else ini_count_done <= 1'b1; 
  
  
endmodule //MC_DDR4


module clock_divider(clk_50mhz,rst_50mhz, out_5hz); 
input clk_50mhz; 
input rst_50mhz; 
reg [23:0] count_reg = 0;
output reg out_5hz = 0;

always @(posedge clk_50mhz or posedge rst_50mhz) begin
    if (rst_50mhz) begin
        count_reg <= 0;
        out_5hz <= 0;
    end else begin
        if (count_reg < 9999999) begin
            count_reg <= count_reg + 1;
        end else begin
            count_reg <= 0;
            out_5hz <= ~out_5hz;
        end
    end
end

endmodule //clock divider 
