class ram_test;
    ram_env env;
    
    function new(virtual ram_if.DRV drv_vif, virtual ram_if.MON mon_vif);
        env = new(drv_vif, mon_vif, 1000); 
    endfunction

    task run();
        env.run();
        
        wait(env.scb.pass_count + env.scb.fail_count >= env.gen.num_trxn);
        #20;
        env.scb.report(); 
        env.cov.report(); 
    endtask
endclass
