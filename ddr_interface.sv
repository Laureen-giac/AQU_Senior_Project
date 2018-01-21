interface ddr_interface;

  logic reset_n;
  logic CKE;
  logic CK_t;
  logic CK_c;
  logic CK_r; 
  logic[13:0] row_addr;
  logic[9:0] col_addr;
  logic cs_n;
  logic act_n;
  logic RAS_n_A16;
  logic CAS_n_A15;
  logic WE_n_A14;
  logic[1:0] bg_addr;
  logic[1:0] ba_addr;
  logic A12_BC_n;
  logic A17;
  logic A13;
  logic A11;
  logic A10_AP;
  logic[9:0] A9_A0;
  logic [DATA_WIDTH-1:0] dq;
  logic dqs_t; 
  logic dqs_c; 

endinterface
