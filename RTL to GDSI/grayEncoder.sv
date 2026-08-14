`timescale 1ns/1ps
module grayEncoder (
    input logic[6:0] normal,
    output logic[6:0] encoded
);
assign encoded[6]=normal[6];//MSB copied as it is
int i;
always_comb begin 
        for (i = 5;i>=0 ;i=i-1 ) begin
            encoded[i] = normal[i] ^ normal[i+1];
        end
end
    
endmodule