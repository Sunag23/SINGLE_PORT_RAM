class ram_env;
    ram_generator       gen;
    ram_driver          drv;
    ram_monitor         mon;
    ram_reference_model ref_model;
    ram_scoreboard      scb;
    ram_coverage        cov; 

    mailbox #(ram_transaction) gen2drv_mbx;
    mailbox #(ram_transaction) drv2ref_mbx;
    mailbox #(ram_transaction) mon2scr_mbx;
    mailbox #(ram_transaction) ref2scr_mbx;
    mailbox #(ram_transaction) mon2cov_mbx; 
    event drv_done;

    function new(virtual ram_if.DRV drv_vif, virtual ram_if.MON mon_vif, int num_trxn);
        gen2drv_mbx = new();
        drv2ref_mbx = new();
        mon2scr_mbx = new();
        ref2scr_mbx = new();
        mon2cov_mbx = new(); 
        gen       = new(gen2drv_mbx, drv_done, num_trxn);
        drv       = new(drv_vif, gen2drv_mbx, drv2ref_mbx, drv_done);
        mon       = new(mon2scr_mbx, mon2cov_mbx, mon_vif); 
        ref_model = new(drv2ref_mbx, ref2scr_mbx);
        scb       = new(mon2scr_mbx, ref2scr_mbx);
        cov       = new(mon2cov_mbx); 
    endfunction

    task run();
        fork
            gen.gen();
            drv.drv();
            mon.run();
            ref_model.run();
            scb.run();
            cov.run(); 
        join_any
    endtask
endclass
