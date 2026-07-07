class ram_driver;
    mailbox #(ram_transaction) gen2drv_mbx;
    mailbox #(ram_transaction) drv2ref_mbx;
    virtual ram_if.DRV ram_vif;
    event drv_done;
    ram_transaction packet_drv;

    function new(
        virtual ram_if.DRV ram_vif,
        mailbox #(ram_transaction) gen2drv_mbx,
        mailbox #(ram_transaction) drv2ref_mbx,
        event drv_done
    );
        this.ram_vif     = ram_vif;
        this.gen2drv_mbx = gen2drv_mbx;
        this.drv2ref_mbx = drv2ref_mbx;
        this.drv_done    = drv_done;
    endfunction

    task drv();
        forever begin
            gen2drv_mbx.get(packet_drv);
            @(ram_vif.drv_cb);

                        packet_drv.reset = ram_vif.drv_cb.reset;

            ram_vif.drv_cb.write_enb <= packet_drv.write_enb;
            ram_vif.drv_cb.read_enb  <= packet_drv.read_enb;
            ram_vif.drv_cb.address   <= packet_drv.address;
            ram_vif.drv_cb.data_in   <= packet_drv.data_in;

            drv2ref_mbx.put(packet_drv.clone());
            ->drv_done;

            
            @(ram_vif.drv_cb);
            ram_vif.drv_cb.write_enb <= 1'b0;
            ram_vif.drv_cb.read_enb  <= 1'b0;
        end
    endtask
endclass
