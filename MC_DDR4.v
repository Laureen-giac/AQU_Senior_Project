
  module MC_DDR4(CLOCK_50, HEX0[6:0], HEX1[6:0], HEX2[6:0], HEX3[6:0], HEX4[6:0],HEX5[6:0], 
			   HEX6[6:0], HEX7[6:0], LEDR[17:0], LEDG[8:0], SW[17:0], busy);  
  
  
  initial begin 
	$monitor("%b", ini_count_done); 
end 
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
  parameter CTRL_WAIT = 4;
  parameter CTRL_REFRESH = 5; 
  parameter tMOD = 10;
  parameter trrd = 10; 
  parameter tccd = 10; 
 
 reg[1:0] ctrl_state, ctrl_next_state; 
 reg clr_ini_count;  
 reg [3:0] ini_count; 
 reg [3:0] act_count; 
 reg [3:0] rw_count; 
 
  clock_divider clk_div(.clk_50mhz(CLOCK_50), .rst_50mhz(SW[0]), .out_5hz(CK_t));
  
  always@(posedge CK_t or posedge SW[0])
    if(SW[0])
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

  always@(ctrl_state, SW, ini_count_done)
    
    if(SW[0]) begin
      ctrl_next_state <= CTRL_IDLE;
      LEDG[0] <= 1'b0;
      LEDG[1] <= 1'b0; 
      LEDG[2] <= 1'b0; 
      LEDR[0] <= 1'b0;
      LEDR[1] <= 1'b0; 
      LEDG[8] <= 1'b0; 
      HEX0 <= 7'b1111111; 
      HEX1 <= 7'b1111111; 
      HEX2 <= 7'b1111111; 
      HEX3 <= 7'b1111111; 
      HEX4 <= 7'b1111111;
      HEX5 <= 7'b1111111; 
      HEX6 <= 7'b1111111; 
      HEX7 <= 7'b1111111; 
      clr_ini_count <= 1'b1;
    end 
    
    else
    
     case(ctrl_state)
      
      CTRL_IDLE: begin
        LEDG[0] <= 1'b0;
        LEDG[1] <= 1'b0; 
        LEDR[0] <= 1'b0; 
        LEDR[1] <= 1'b0;  
        
        if(~SW[0] && ~SW[1] && ~SW[2]) begin 
          ctrl_next_state <= CTRL_INIT;
          LEDG[0] <= 1'b1;  //busy during initialization 
          LEDG[1] <= 1'b0; 
          LEDR[0] <= 1'b0; 
          LEDR[1] <= 1'b0;  
        end 
        else 
          ctrl_next_state <= CTRL_IDLE; 
      end

      CTRL_INIT: begin 
        LEDR[0] = 1'b0; 
  	LEDG[0] <= 1'b1; 
	LEDG[1] <= 1'b0; 
	LEDG[8] <= 1'b1; 
        HEX7 <= 7'b1000110;
        HEX6 <= 7'b1001110;
        HEX5 <= 7'b0001000;
        HEX4 <= 7'b1000111;
        HEX3 <= 7'b1001111;
        HEX2 <= 7'b1001000;
        HEX1 <= 7'b1001111;
        HEX0 <= 7'b1111111;
		  
         if(SW[1] && ~SW[0] && ~SW[2]) begin 
           LEDR[0] = 1'b1; 
           LEDG[0] <= 1'b0; 
           LEDG[1] <= 1'b1; //ini done..start act
           ctrl_next_state <= CTRL_ACTIVATE ;
	     end
        else 
          ctrl_next_state <= CTRL_INIT; 
	    end
       
      CTRL_ACTIVATE: begin
        LEDG[0] <= 1'b0;
        LEDG[8] <= 1'b1; 
        HEX7 <= 7'b1000110;
        HEX6 <= 7'b1001110;
        HEX5 <= 7'b0001000;
        HEX4 <= 7'b1000111;
        HEX3 <= 7'b0001000;
        HEX2 <= 7'b1000110;
        HEX1 <= 7'b1001110;
        HEX0 <= 7'b1111111;
        if(~SW[0] && ~SW[1] && ~SW[2]) begin  //sw1 start act, pull down finish act
          ctrl_next_state <= CTRL_RW;
          LEDG[1] <= 1'b1; 
          LEDG[2] <= 1'b1; 
        end
        else 
          ctrl_next_state <= CTRL_ACTIVATE; 
        
      end 

      CTRL_RW: begin
      HEX7 <= 7'b1000110;
      HEX6 <= 7'b1001110;
      HEX5 <= 7'b0001000;
      HEX4 <= 7'b1000111;
      HEX3 <= 7'b0001000;
      HEX2 <= 7'b1111111;
      HEX1 <= 7'b1111111;
      HEX0 <= 7'b1111111;
        
        if(~SW[0] && ~SW[1] && SW[2]) begin 
          ctrl_next_state <= CTRL_REFRESH;
          LEDG[0] <= 1'b1;
          LEDG[1] <= 1'b0; 
          LEDG[2] <= 1'b0;  //finish current RW b4 refresh
        end
        else 
          ctrl_next_state <= CTRL_RW; 
      end
   
      CTRL_REFRESH: begin
          LEDG[0] <= 1'b1;
          LEDG[1] <= 1'b0; 
          LEDG[2] <= 1'b0;
        if(~SW[0] && ~SW[1] && ~SW[2])begin
          ctrl_next_state <= CTRL_ACTIVATE; //all banks are precharged, can't go back to RW
          LEDG[0] <= 1'b0;
        end
        else 
          ctrl_next_state <= CTRL_REFRESH; 
      end
       
       default: ctrl_next_state <= CTRL_IDLE; 
     
     endcase
  
  endmodule //MC_DDR4

module clock_divider(clk_50mhz,rst_50mhz, out_5hz); 
input clk_50mhz; 
input rst_50mhz; 
reg [40:0] count_reg;
output reg out_5hz;

always @(posedge clk_50mhz or posedge rst_50mhz) begin
    if (rst_50mhz) begin
        count_reg <= 0;
        out_5hz <= 0;
    end else begin
        if (count_reg < 49999999) begin
            count_reg <= count_reg + 1;
        end else begin
            count_reg <= 0;
            out_5hz <= ~out_5hz;
        end
    end
end

endmodule //clock divider    
       
