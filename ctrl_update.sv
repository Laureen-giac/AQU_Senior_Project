`include "ddr_pkg.pkg"

module ctrl_update(ctrl_interface ctrl_intf, ddr_interface ddr_intf, tb_interface tb_intf);


  always_comb
    begin
      if(ctrl_intf.mrs_update_rdy)
        begin
          if(tb_intf.BL == 2'b00 || tb_intf.BL == 2'b10)
            begin
              ctrl_intf.BL = tb_intf.BL;
            end
          else
            begin
              ctrl_intf.BL = 8;
            end
        end
    end

endmodule











  
