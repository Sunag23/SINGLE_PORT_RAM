class ram_scoreboard;
    mailbox #(ram_transaction) mon2scr_mbx;
    mailbox #(ram_transaction) ref2scr_mbx;
    ram_transaction packet_mon;
    ram_transaction packet_ref;

    int pass_count = 0;
    int fail_count = 0;
    int fd; 

    function new(mailbox #(ram_transaction) mon2scr_mbx, mailbox #(ram_transaction) ref2scr_mbx);
        this.mon2scr_mbx = mon2scr_mbx;
        this.ref2scr_mbx = ref2scr_mbx;
        this.fd = $fopen("scoreboard_report.txt", "w");
        if (this.fd == 0) begin
            $fatal("[SCOREBOARD] Failed to open scoreboard_report.txt");
        end
    endfunction

    task run();
        forever begin
            mon2scr_mbx.get(packet_mon);
            ref2scr_mbx.get(packet_ref);

            if (packet_mon.reset == 1'b0) begin
                if (packet_mon.data_out === 8'hZZ) begin
                    $display("[SCOREBOARD] [PASS] RESET active: Output correctly went to High-Z (8'hZZ)");
                    $fdisplay(fd, "[SCOREBOARD] [PASS] RESET active: Output correctly went to High-Z (8'hZZ)");
                    pass_count++;
                end
                else begin
                    $error("[SCOREBOARD] [FAIL] RESET active: Expected 8'hZZ, but got %0h", packet_mon.data_out);
                    $fdisplay(fd, "[SCOREBOARD] [FAIL] RESET active: Expected 8'hZZ, but got %0h", packet_mon.data_out);
                    fail_count++;
                end
            end
            else begin
                if (packet_mon.read_enb == 1'b1 && packet_mon.write_enb == 1'b0) begin
                    if (packet_mon.data_out === packet_ref.data_out) begin
                        $display("[SCOREBOARD] [PASS] READ at Addr: %0d | Expected: %0h | Actual: %0h, | RESET= %b", 
                                 packet_mon.address, packet_ref.data_out, packet_mon.data_out,packet_mon.reset);
                        $fdisplay(fd, "[SCOREBOARD] [PASS] READ at Addr: %0d | Expected: %0h | Actual: %0h, | RESET = %b", 
                                 packet_mon.address, packet_ref.data_out, packet_mon.data_out,packet_mon.reset);
                        pass_count++;
                    end
                    else begin
                        $error("[SCOREBOARD] [FAIL] READ Mismatch at Addr: %0d | Expected: %0h | Actual: %0h, | RESET=%b", 
                               packet_mon.address, packet_ref.data_out, packet_mon.data_out,packet_mon.reset);
                        $fdisplay(fd, "[SCOREBOARD] [FAIL] READ Mismatch at Addr: %0d | Expected: %0h | Actual: %0h, | RESET=%b", 
                               packet_mon.address, packet_ref.data_out, packet_mon.data_out,packet_mon.reset);
                        fail_count++;
                    end
                end
                else if (packet_mon.write_enb == 1'b1 && packet_mon.read_enb == 1'b0) begin
                    $display("[SCOREBOARD] [PASS] WRITE at Addr: %0d | Data: %0h", 
                             packet_mon.address, packet_mon.data_in);
                    $fdisplay(fd, "[SCOREBOARD] [PASS] WRITE at Addr: %0d | Data: %0h", 
                             packet_mon.address, packet_mon.data_in);
                    pass_count++;
                end
            end
        end
    endtask

    function void report();
        $display("            RAM SCOREBOARD FINAL REPORT            ");
        $display(" Total Passed Comparisons : %0d", pass_count);
        $display(" Total Failed Comparisons : %0d", fail_count);
        $display("==================================================");
        
        $fdisplay(fd, "            RAM SCOREBOARD FINAL REPORT            ");
        $fdisplay(fd, " Total Passed Comparisons : %0d", pass_count);
        $fdisplay(fd, " Total Failed Comparisons : %0d", fail_count);
        $fdisplay(fd, "==================================================");
        $fclose(fd);
    endfunction
endclass
