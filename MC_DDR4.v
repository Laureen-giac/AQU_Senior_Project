
  module MC_DDR4(CLOCK_50, HEX0[6:0], HEX1[6:0], HEX2[6:0], HEX3[6:0], HEX4[6:0],
                 HEX5[6:0],HEX6[6:0], HEX7[6:0], LEDR[17:0], LEDG[8:0], SW[17:0], busy);  
  

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
  reg ini_count_done, clr_act_count, act_count_done, clr_cas_count, cas_count_done; 
  
  wire CK_t; 
  
  parameter CTRL_IDLE = 0; 
  parameter CTRL_INIT = 1; 
  parameter CTRL_ACTIVATE = 2; 
  parameter CTRL_RW = 3; 
  parameter CTRL_WAIT = 4;
  parameter CTRL_DONE = 5;
    
  parameter tMOD = 5;
  parameter tRRD = 5; 
  parameter tCCD = 5; 
    
   reg[10:0] ctrl_state, ctrl_next_state; 
   reg clr_ini_count;  
   reg [3:0] ini_count; 
   reg [3:0] act_count; 
   reg [3:0] cas_count; 
   reg [3:0] bg_addr, ba_addr, row_addr, col_addr; 

  clock_divider clk_div(.clk_50mhz(CLOCK_50), .rst_50mhz(SW[0]), .out_5hz(CK_t));
  
  always@(posedge CK_t or posedge SW[0])
    if(SW[0]) begin
      ctrl_state <= CTRL_IDLE;
    end
  else begin
    ctrl_state <= ctrl_next_state;
  end	
  
  /*
  Next State logic
  */
    
    always@(ctrl_state, SW, ini_count_done, act_count_done, cas_count_done)begin 
      if(SW[0] && ~SW[1] && ~SW[2]) begin
        ctrl_next_state <= CTRL_IDLE;
      	LEDG[0] <= 1'b0;
        LEDG[1] <= 1'b0; 
        LEDG[2] <= 1'b0; 
        LEDR <= 18'b000000000000000000; 
        LEDG[8] <= 1'b0; 
        HEX0 <= 7'b1111111; 
        HEX1 <= 7'b1111111; 
        HEX2 <= 7'b1111111; 
        HEX3 <= 7'b1111111; 
        HEX4 <= 7'b1111111;
        HEX5 <= 7'b1111111; 
        HEX6 <= 7'b1111111; 
        HEX7 <= 7'b1111111; 
        clr_act_count <= 1'b1; 
        clr_cas_count <= 1'b1; 
      end 
   
    if(~SW[0]) begin  
      case(ctrl_state)
        
        CTRL_IDLE: begin
          LEDG[0] <= 1'b0;
          LEDG[1] <= 1'b0;
          LEDG[7:2] <= 6'b000000; 
          LEDR[0] <= 1'b0; 
          LEDR[1] <= 1'b0;  
          clr_act_count <= 1'b1;
          clr_cas_count <= 1'b1; 

          if(~SW[0]) begin 
            ctrl_next_state <= CTRL_INIT; 
            LEDG[0] <= 1'b1;  //busy during initialization '=
            LEDG[7:2] <= 6'b000000;
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
          LEDG[7:2] <= 6'b000000;
          LEDG[7:2] <= 6'b000000;
          HEX7 <= 7'b0100001;
          HEX6 <= 7'b0100001;
          HEX5 <= 7'b0101111;
          HEX4 <= 7'b0011001;
          HEX3 <= 7'b1001111;
          HEX2 <= 7'b1001000;
          HEX1 <= 7'b1001111;
          HEX0 <= 7'b1111111;

           if(~SW[0] && ~ini_count_done && ~SW[1]) begin 
             LEDR[0] = 1'b1; 
             LEDG[0] <= 1'b1; 
             LEDG[1] <= 1'b0; 
             LEDG[7:2] <= 6'b000000;
             ctrl_next_state <= CTRL_INIT;
           end

           else if(~SW[0] && ini_count_done && ~SW[1]) begin 
             LEDR[0] <= 1'b0; 
             LEDG[0] <= 1'b0; 
             LEDG[1] <= 1'b1; //ready for act 
             LEDG[7:2] <= 6'b000000;
             clr_act_count <= 1'b0; 
             ctrl_next_state <= CTRL_ACTIVATE; 
            end  
          else 
            ctrl_next_state <= CTRL_INIT; 
        end
        
        CTRL_ACTIVATE: begin
        
        clr_act_count <= 1'b0;
        LEDG[1] <= 1'b1; 
        
          if(~SW[0] && SW[1]  && SW[2] && ~act_count_done) begin  //sw1 cmd rdy sw2 choose @
			LEDR[0] <= 1'b1;
            //bg_addr <= 4'h8;
            //decode_addr(bg_addr);
            HEX7 <= 7'b0000000; 
            //ba_addr <= 4'h6;
            //decode_addr(ba_addr);
            HEX6 <= 7'b0000010;
            //row_addr <= 4'h9; 
            HEX5 <= 7'b0011000; 
            //col_addr <= 4'h4;
            HEX4 <= 7'b0011001; 
            ctrl_next_state <= CTRL_ACTIVATE; 
          end
          else if (~SW[0] && SW[1] && SW[2] && act_count_done) begin 
            LEDG[1] <= 1'b1; 
            LEDG[2] <= 1'b1; //ready for rw 
            LEDR[0] <= 1'b0;
            clr_cas_count <= 1'b0;
            ctrl_next_state <= CTRL_RW;
          end 
          else 
            ctrl_next_state <= CTRL_ACTIVATE; 
        end 
        
        CTRL_RW: begin
        clr_cas_count <= 1'b0; 
          if(~SW[0] && SW[1] && SW[2] && ~cas_count_done) begin 
            LEDR <= 18'b111111111111111111;
       		HEX7 <= 7'b0001000;
			HEX6 <= 7'b1000110;
			HEX5 <= 7'b1000110;
			HEX4 <= 7'b0000110;
			HEX3 <= 7'b0010010;
			HEX2 <= 7'b0010010;
			HEX1 <= 7'b1111111;
			HEX0 <= 7'b1111111;
			ctrl_next_state <= CTRL_RW;
          end 
		else if (~SW[0] && SW[1] && SW[2] && cas_count_done) begin 
          ctrl_next_state <= CTRL_DONE;
        end 
       end 
        
        CTRL_DONE: begin 
            LEDR <= 18'b000000000000000000; 
            LEDG <= 8'b11111111;
            HEX7 <= 7'b0001100;
			HEX6 <= 7'b0001000;
			HEX5 <= 7'b0010010;
			HEX4 <= 7'b0010010;
			HEX3 <= 7'b1111111;
			HEX2 <= 7'b1111111;
			HEX1 <= 7'b1111111;
			HEX0 <= 7'b1111111; 
			ctrl_next_state <= CTRL_DONE; 
          
        end
        
        /*CTRL_REFRESH: begin
          LEDG[0] <= 1'b1;
          LEDG[1] <= 1'b0; 
          LEDG[2] <= 1'b0;
          
          if(~SW[0] && ~SW[1] && ~SW[2] && ~SW[3])begin
            ctrl_next_state <= CTRL_ACTIVATE; //all banks are precharged, can't go back to RW
            LEDG[0] <= 1'b0;
          end
          else 
            ctrl_next_state <= CTRL_REFRESH; 
        end
       */  
        
       default: ctrl_next_state <= CTRL_IDLE; 
      endcase
    end  
    end 
    
    always@(posedge CK_t, posedge SW[0]) begin 
      if(SW[0]) begin
        ini_count <= 0;
        ini_count_done <= 0; 
      end 
      else begin
        if(ini_count < tMOD )  begin 
          ini_count <= ini_count + 1; 
        end  else begin 
          ini_count_done <= 1'b1; 
          ini_count <= 0;
        end 
      end 
    end 
    
    always@(posedge CK_t, posedge clr_cas_count) begin 
      if(clr_cas_count) begin
        cas_count <= 0;
        cas_count_done <= 1'b0;  
      end 
      else begin
        if(cas_count < tCCD )  begin 
          cas_count <= cas_count + 1;
        end else begin 
          cas_count_done <= 1'b1; 
          cas_count <= 0;
        end 
      end 
    end  
    
    always@(posedge CK_t, posedge clr_act_count) begin 
      if(clr_act_count) begin
        act_count <= 0;
        act_count_done <= 1'b0;  
      end 
      else begin
        if(act_count < tRRD )  begin 
          act_count <= act_count + 1;
        end else begin 
          act_count_done <= 1'b1; 
          act_count <= 0;
        end 
      end 
    end  

  // function was not synthesized //	  
 /*function decode_addr(input reg[3:0] host_addr, output reg[6:0] seg); 
     begin case (host_addr)
       4'h0: seg = 7'h3F;
       4'h1: seg = 7'hz06;     
       4'h2: seg = 7'h5B;     
       4'h3: seg = 7'h4F;    
       4'h4: seg = 7'h66;     
       4'h5: seg = 7'h6D;     
       4'h6: seg = 7'h7D;     
       4'h7: seg = 7'h07;     
       4'h8: seg = 7'h7F;     
       4'h9: seg = 7'h67;  
     endcase 
     end 
   endfunction 
  */
  
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
       
