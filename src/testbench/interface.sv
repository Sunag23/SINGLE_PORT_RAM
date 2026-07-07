interface ram_if(input bit clk, reset);

    logic write_enb;
    logic read_enb;
    logic [7:0] data_in;
    logic [4:0] address;      
    logic [7:0] data_out;

    clocking drv_cb @(posedge clk);
        default input #0 output #0;
        input reset;
        output write_enb, read_enb, data_in, address;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1step output #0;  
        input reset;
        input write_enb;
        input read_enb;
        input data_in;
        input address;
        input data_out;
    endclocking

    modport DRV(clocking drv_cb);
    modport MON(clocking mon_cb);

endinterface
