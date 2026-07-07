class ram_reference_model;
    mailbox #(ram_transaction) drv2ref_mbx;
    mailbox #(ram_transaction) ref2scr_mbx;
    logic [7:0] mem [0:31];

    function new(mailbox #(ram_transaction) drv2ref_mbx, mailbox #(ram_transaction) ref2scr_mbx);
        this.drv2ref_mbx = drv2ref_mbx;
        this.ref2scr_mbx = ref2scr_mbx;
        foreach(mem[i]) mem[i] = 8'hxx;
    endfunction

    task run();
        ram_transaction packet_ref;
        forever begin
            drv2ref_mbx.get(packet_ref);

            if (!packet_ref.reset) begin
                packet_ref.data_out = 8'hZZ;
            end
            else begin
                packet_ref.data_out = 8'hZZ;
                // [FIX] Removed "&& !read_enb" so simultaneous (1,1) is predicted cleanly!
                if (packet_ref.write_enb) begin
                    if (packet_ref.address < 32)
                        mem[packet_ref.address] = packet_ref.data_in;
                end
                else if (packet_ref.read_enb) begin
                    if (packet_ref.address < 32)
                        packet_ref.data_out = mem[packet_ref.address];
                end
            end
            ref2scr_mbx.put(packet_ref);
        end
    endtask
endclass
