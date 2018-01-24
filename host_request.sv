class host_request;

  rand bit[63:0] wr_data; 
  rand bit[39:0] address; 
  rand bit[2:0] request; 
  randc bit[2:0] CL; 
  randc bit[2:0] BL; 
  randc bit[2:0] AL;
  randc bit[2:0] CWL; 
  randc bit RD_PRE; 
  randc bit WR_PRE; 
  
  constraint req_c1 { 
    request inside{ 3'b001, 3'b011}; 
  } 
  
  constraint req_c2 {
    request dist { 
      3'b001 := 1, 
      3'b011 := 1
    };
  }
  
  constraint BL_c {
    BL inside {2'b00, 2'b00};
  }
  
  constraint AL_c { 
    AL != 11; 
  } 
  
  constraint CWL_c { 
    CWL inside {2'b00, 2'b10}; 
  } 
  

endclass 
  
  
  
  
  
