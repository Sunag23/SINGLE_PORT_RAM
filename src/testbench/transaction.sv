class ram_transaction;
    rand bit        write_enb;
    rand bit        read_enb;
    rand bit [7:0]  data_in;
    rand bit [4:0]  address;      
    rand logic       reset;
         logic [7:0] data_out;

    function void copy(ram_transaction rhs);
        rhs.write_enb = write_enb;
        rhs.read_enb  = read_enb;
        rhs.data_in   = data_in;
        rhs.address   = address;
        rhs.reset     = reset;
        rhs.data_out  = data_out;
    endfunction

    function ram_transaction clone();
        ram_transaction t = new();
        copy(t);
        return t;
    endfunction

    constraint W_R  { write_enb != read_enb; } 
    constraint ADDR { address inside {[0:31]}; }
 
endclass
