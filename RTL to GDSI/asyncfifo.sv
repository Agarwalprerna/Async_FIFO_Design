`timescale 1ns/1ps
module asyncfifo (
    input logic wclk,
    input logic rclk,
    input logic we,
    input logic re,
    input logic[31:0] din,
    input logic rstn,
    output reg [31:0] dout,
    output reg  empty,
    output reg  full
);
//===========================================================
//All write pointers
//===========================================================
logic[6:0] wr_ptr;
logic[6:0] wr_ptr_next;
logic[6:0] wr_ptr_gray;
logic[6:0] wr_ptr_gray_next;
logic[6:0] sacrifical_lamb_wr;//This lamb sacrficies itself and its only purpose is to resolve metstability(pretty important role)
logic[6:0] wr_ptr_gray_sync;
// logic[6:0] wr_ptr_gray_decoded;
//============================================================
// All read pointers
//============================================================
logic[6:0] rd_ptr;
logic[6:0] rd_ptr_next;
logic[6:0] rd_ptr_gray;
logic[6:0] rd_ptr_gray_next;
logic[6:0] sacrifical_lamb_rd;
logic[6:0] rd_ptr_gray_sync;
// logic[6:0] rd_ptr_gray_decoded;
//============================================================
//The almighty memory block
//============================================================
logic[31:0]mem[0:63];
//============================================================
grayEncoder wgcoded(
    .normal(wr_ptr),
    .encoded(wr_ptr_gray)
);
grayEncoder wgcoded_next(
    .normal(wr_ptr_next),
    .encoded(wr_ptr_gray_next)
);
grayEncoder rgcoded(
    .normal(rd_ptr),
    .encoded(rd_ptr_gray)
);
grayEncoder rgcoded_next(
    .normal(rd_ptr_next),
    .encoded(rd_ptr_gray_next)
);
// grayDecoder gdecoded(
//     .encoded(wr_ptr_gray_sync),
//     .decoded(wr_ptr_gray_decoded)
// );
always_ff @( posedge wclk or negedge rstn ) begin 
    if (!rstn) begin
        wr_ptr<=0;
        full<=0;
        sacrifical_lamb_rd<=0;
        rd_ptr_gray_sync<=0;
    end
    else begin
        sacrifical_lamb_rd<=rd_ptr_gray;
        rd_ptr_gray_sync<=sacrifical_lamb_rd;
        if(wr_ptr_gray_next == {~rd_ptr_gray_sync[6:5], rd_ptr_gray_sync[4:0]})begin
            full<=1;
        end
        else if (wr_ptr_gray_next!=rd_ptr_gray_sync) begin
            full<=0;
        end
        if (we&!full) begin
                mem[wr_ptr[5:0]]<=din;
                wr_ptr<=wr_ptr_next;
        end
    end
end
always_ff @( posedge rclk or negedge rstn ) begin 
    if (!rstn) begin
        rd_ptr<=0;
        sacrifical_lamb_wr<=0;
        wr_ptr_gray_sync<=0;
        empty<=0;
        dout<=0;
    end
    else   begin
        sacrifical_lamb_wr<=wr_ptr_gray;
        wr_ptr_gray_sync<=sacrifical_lamb_wr;
         if(rd_ptr_gray_next==wr_ptr_gray_sync)begin
                empty<=1;
        end
        else if (rd_ptr_gray_next!=wr_ptr_gray_sync) begin
            empty<=0;
        end
        if (re) begin
            if(!empty) begin
                dout<=mem[rd_ptr[5:0]];
                rd_ptr<=rd_ptr_next;
            end
        end
    end
end
 
always_comb begin 
    wr_ptr_next=wr_ptr;
    rd_ptr_next=rd_ptr;
    if (we&&!full) begin
        wr_ptr_next=wr_ptr+1;
    end
    if (re&&!empty) begin
        rd_ptr_next=rd_ptr+1;
    end
end
endmodule