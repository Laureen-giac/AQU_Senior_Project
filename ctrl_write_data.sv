`include "ddr_pkg.pkg"

module write_data(ctrl_interface ctrl_intf, ddr_interface ddr_intf);

  wr_data_type gen_wr_data, wr_data_in;
  wr_data_type wr_data_queue[$];


  always_latch@(ddr_intf.reset_n or ctrl_intf.act_rdy or ctrl_intf.no_act_rdy)
    begin 

      if(!intf.reset_n)
        begin
          wr_data_queue.delete();
        end

      else
        begin

          if((ctrl_intf.act_rdy) || (ctrl_intf.no_act_rdy))
            begin
              wr_data_in.wr_data = gen_wr_data.wr_data;
              wr_data_in.burst_length = gen_wr_data.burst_length;
              wr_data_in.preamble = gen_wr_data.preamble;
              wr_data_queue.push_front(wr_data_in);
            end
        end
    end


  /*generate DQS properly
  */

  always_ff@(ddr_intf.CK_t)
    begin
      if(ctrl_intf.wr_rdy || ctrl_intf.wra_rdy)
        begin
        end
    end
