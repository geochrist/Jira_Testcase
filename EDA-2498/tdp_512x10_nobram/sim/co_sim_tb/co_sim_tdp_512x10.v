
module co_sim_tdp_512x10;

    reg clkA, clkB, weA, weB;
    reg [3:0] addrA, addrB;
    reg [511:0] dinA, dinB;
    wire [511:0] doutA, doutB, doutA_net, doutB_net;

    integer mismatch=0;
    reg [6:0]cycle, i;

    tdp_512x10 golden(.*);
    tdp_512x10_post_synth netlist(.*, .doutA(doutA_net), .doutB(doutB_net));


    
    //clock//
    initial begin
        clkA = 1'b0;
        forever #10 clkA = ~clkA;
    end
    initial begin
        clkB = 1'b0;
        forever #5 clkB = ~clkB;
    end

    initial begin
        for(integer i = 0; i<10; i=i+1) begin 
            golden.ram[i] ='b0;
        end 
    end
    initial begin
    {weA,weB, addrA,addrB, dinA, dinB, cycle, i} = 0;
 
 
    repeat (1) @ (negedge clkA);
    addrA <= 'd1; addrB <= 'd2; weA <=1'b1; weB <=1'b1; dinA<= {$random}; dinB<= {$random};
    compare(cycle);
    repeat (1) @ (negedge clkA);
    addrA <= 'd1; addrB <= 'd2; weA <=1'b0; weB <=1'b0; dinA<= {$random}; dinB<= {$random};
    compare(cycle);

    for (integer i=0; i<512; i=i+1)begin
        repeat (1) @ (negedge clkA)

        addrA <= $urandom_range(0,4); addrB <= $urandom_range(5,9); weA <=1'b1; weB <=1'b1; dinA<= {$random}; dinB<= {$random};
        cycle = cycle +1;
     
        compare(cycle);

    end

    for (integer i=0; i<512; i=i+1)begin
        repeat (1) @ (negedge clkB)

        addrA <= $urandom_range(0,4); addrB <= $urandom_range(5,9); weA <=1'b0; weB <=1'b0; dinA<= {$random}; dinB<= {$random};
        cycle = cycle +1;
     
        compare(cycle);

    end

    for (integer i=0; i<512; i=i+1)begin
        repeat (1) @ (negedge clkA)

        addrA <= $urandom_range(0,4); addrB <= $urandom_range(5,9); weA <=1'b0; weB <=1'b1; dinA<= {$random}; dinB<= {$random};
        cycle = cycle +1;
     
        compare(cycle);

    end

    for (integer i=0; i<512; i=i+1)begin
        repeat (1) @ (negedge clkB)

        addrA <= $urandom_range(0,4); addrB <= $urandom_range(5,9); weA <=1'b1; weB <=1'b0; dinA<= {$random}; dinB<= {$random};
        cycle = cycle +1;
     
        compare(cycle);

    end
    
    //random
    for (integer i=0; i<512; i=i+1)begin
        repeat (1) @ (negedge clkA)
        addrA <= $urandom_range(0,4); addrB <= $urandom_range(5,9); weA <={$random};  weB <={$random};  dinA<= {$random}; dinB<= {$random};
        cycle = cycle +1;
       
        compare(cycle);
    end
    if(mismatch == 0)
        $display("\n**** All Comparison Matched ***\nSimulation Passed");
    else
        $display("%0d comparison(s) mismatched\nERROR: SIM: Simulation Failed", mismatch);
    

    repeat (10) @(negedge clkA); $finish;
    end

    task compare(input integer cycle);
    //$display("\n Comparison at cycle %0d", cycle);
    if(doutA !== doutA_net) begin
        $display("doutA mismatch. Golden: %0h, Netlist: %0h, Time: %0t", doutA, doutA_net,$time);
        mismatch = mismatch+1;
    end

     if(doutB !== doutB_net) begin
        $display("doutB mismatch. Golden: %0h, Netlist: %0h, Time: %0t", doutB, doutB_net,$time);
        mismatch = mismatch+1;
    end
    
    
    endtask


initial begin
    $dumpfile("tb.vcd");
    $dumpvars;
end
endmodule