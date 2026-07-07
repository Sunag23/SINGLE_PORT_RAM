class ram_generator;
    mailbox #(ram_transaction) gen2drv_mbx;
    int num_trxn;
    event drv_done;
    ram_transaction packet;

    function new(mailbox #(ram_transaction) gen2drv_mbx, event drv_done, int num_trxn);
        this.gen2drv_mbx = gen2drv_mbx;
        this.drv_done    = drv_done;
        this.num_trxn    = num_trxn;
        packet           = new();
    endfunction

    task gen();
        
        repeat(num_trxn) begin
            if(!packet.randomize()) begin
                $fatal("[GEN] Randomization failed");
            end
            else begin
                gen2drv_mbx.put(packet.clone());
                @(drv_done);
            end
        end

       
        
        packet.constraint_mode(0); 
        packet.write_enb = 1'b1;   
        packet.read_enb  = 1'b1;   
        packet.address   = 5'd15;  
        packet.data_in   = 8'hAA;  
        
        gen2drv_mbx.put(packet.clone());
        @(drv_done);
        
        packet.constraint_mode(1); 
    endtask
endclass
