`include "ddr_pkg.pkg"

class host_req;

  rand write_data wr_data; 
  rand host_address log_addr; 
  rand bit[2:0] request; 
  randc bit[2:0] CL; 
  randc bit[2:0] BL; 
  randc bit[2:0] AL;
  randc bit[2:0] CWL; 
  randc bit RD_PRE; 
  randc bit WR_PRE;
  bit[63:0] rd_data; 
  
  function void display(); 
    $display("From System Host"); 
    $display("Host Request is a %d", request); 
    $display("Memory Address is %h", log_addr); 
    $display("Memory Data is %h", wr_data); 
    $display("Operating Parameters are:"); 
    $display("BL:%b\tCL:%b\tRD_PRE:%d\tWR_PRE%d\t", BL, CL, RD_PRE, WR_PRE);
  endfunction 
  
  constraint req_c1 { 
    request inside{3'b001 ,  3'b011}; 
  } 
  
  constraint req_c2 {
    request == RD_R -> wr_data == '1; 
  }
  
  constraint req_c3 { 
    request dist {RD_R := 5 , WR_R := 5};
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
 
  
