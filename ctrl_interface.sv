`include "ddr_pkg.pkg"

interface ctrl_interface;

  bit ini_done;
  bit mrs_rdy;
  bit busy;
  bit mrs_update_rdy;
  bit refresh_rdy;
  bit des_rdy;
  bit zqcl_rdy;
  bit act_rdy;
  bit no_act_rdy;
  bit no_act;
  bit data_idle;
  bit act_idle;
  bit rw_done;
  bit rd_rdy;
  bit wr_rdy;
  bit rda_rdy;
  bit wra_rdy;
  bit pre_rdy;
  bit prea_rdy;
  bit cas_rdy;
  bit cas_idle;
  bit rw_proc;
  bit rw_idle;
  bit rw_rdy;
  bit clear_refresh;
  bit refresh_done;
  bit refresh_almost;
  mem_addr_type mem_addr;
  mode_register_type mode_reg, pre_reg;
  logic[2:0] req;
  logic[2:0] cas_req;
  logic[2:0] act_rw;
  int BL;
  int CL;
  int CWL;
  int tCCD;
  int RD_PRE;
  int WR_PRE;
  int AL;

endinterface
