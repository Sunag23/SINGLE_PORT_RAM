class ram_monitor;
    mailbox #(ram_transaction) mon2scr_mbx;
    mailbox #(ram_transaction) mon2cov_mbx; 
    virtual ram_if.MON ram_vif;
    
    
    function new(mailbox #(ram_transaction) mon2scr_mbx, 
                 mailbox #(ram_transaction) mon2cov_mbx, 
                 virtual ram_if.MON ram_vif);
        this.mon2scr_mbx = mon2scr_mbx;
        this.mon2cov_mbx = mon2cov_mbx; 
        this.ram_vif     = ram_vif;
    endfunction

    task run();
        ram_transaction read_pipeline_pkt = null;
        
        
        @(posedge ram_vif.mon_cb.reset); 
        
        forever begin
            @(ram_vif.mon_cb);
            
            
            if (read_pipeline_pkt != null) begin
                read_pipeline_pkt.data_out = ram_vif.mon_cb.data_out;
                mon2scr_mbx.put(read_pipeline_pkt);
                mon2cov_mbx.put(read_pipeline_pkt.clone()); 
                read_pipeline_pkt = null;
            end

            
            if (!ram_vif.mon_cb.reset) begin
                ram_transaction pkt = new();
                pkt.reset    = 1'b0;
                pkt.data_out = ram_vif.mon_cb.data_out;
                mon2scr_mbx.put(pkt);
                mon2cov_mbx.put(pkt.clone()); 
            end
            
            else if (ram_vif.mon_cb.write_enb) begin
                ram_transaction pkt = new();
                pkt.reset     = 1'b1;
                pkt.write_enb = 1'b1;
                pkt.read_enb  = ram_vif.mon_cb.read_enb;
                pkt.address   = ram_vif.mon_cb.address;
                pkt.data_in   = ram_vif.mon_cb.data_in;
                mon2scr_mbx.put(pkt);
                mon2cov_mbx.put(pkt.clone()); 
            end
            else if (ram_vif.mon_cb.read_enb) begin
                
                read_pipeline_pkt = new();
                read_pipeline_pkt.reset     = 1'b1;
                read_pipeline_pkt.write_enb = 1'b0;
                read_pipeline_pkt.read_enb  = 1'b1;
                read_pipeline_pkt.address   = ram_vif.mon_cb.address;
            end
        end
    endtask
endclass
