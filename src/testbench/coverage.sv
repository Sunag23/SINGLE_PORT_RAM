class ram_coverage;
    ram_transaction pkt;
    mailbox #(ram_transaction) mon2cov_mbx;
    real coverage_score;

    covergroup ram_cg;
        option.per_instance = 1;
        option.name = "RAM_INST_COVERAGE";

        cp_op: coverpoint {pkt.reset, pkt.write_enb, pkt.read_enb} {
            ignore_bins active_reset = {3'b000, 3'b001, 3'b010, 3'b011};
            bins normal_write = {3'b110};
            bins normal_read  = {3'b101};
            ignore_bins simultaneous = {3'b111};
            ignore_bins idle  = {3'b100};
        }

        cp_addr: coverpoint pkt.address {
            bins addr_zero       = {5'd0};
            bins addr_max        = {5'd31};
            bins addr_low_mid    = {[5'd1  : 5'd15]};
            bins addr_high_mid   = {[5'd16 : 5'd30]};
            bins same_addr_trans = (5'd0 => 5'd0), (5'd31 => 5'd31);
        }

        cp_data: coverpoint pkt.data_in {
            bins all_zeros     = {8'h00};
            bins all_ones      = {8'hFF};
            bins alt_pattern_1 = {8'hAA};
            bins alt_pattern_2 = {8'h55};
            bins general_data  = default;
        }

        cross_op_addr: cross cp_op, cp_addr;
    endgroup

    function new(mailbox #(ram_transaction) mon2cov_mbx);
        this.mon2cov_mbx = mon2cov_mbx;
        ram_cg = new();
    endfunction

    task run();
        forever begin
            mon2cov_mbx.get(pkt);
            ram_cg.sample();
        end
    endtask

    function void report();
        coverage_score = ram_cg.get_inst_coverage();
        $display("==================================================");
        $display("        FUNCTIONAL COVERAGE FINAL REPORT          ");
        $display(" Total Functional Coverage : %0.2f %%", coverage_score);
        $display("==================================================");
    endfunction
endclass
