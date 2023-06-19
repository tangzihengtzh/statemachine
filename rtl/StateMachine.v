module StateMachine 
(
    input wire sys_clk,
    input wire sys_rst,

    input [3:0] key,
    output reg [3:0]ledpin
);

	reg [1:0]encode;
	
	parameter INIT = 4'b0000;
	parameter S1 = 4'b0001;
	parameter S2 = 4'b0010;
	parameter S3 = 4'b0100;
	parameter S4 = 4'b1000;
	
	reg[3:0] cur_st;
	reg[3:0] nex_st;
	
	initial begin
		cur_st<=INIT;
		nex_st<=INIT;
		ledpin<=4'b1111;
	end
	
	always@(posedge sys_clk)begin
		if(sys_rst==1'b0)
			cur_st<=INIT;
		else
			cur_st<=nex_st;
	end
		
	always@(*)begin
		case (key)
            4'b1110:encode<=2'b00;
            4'b1101:encode<=2'b01;
            4'b1011:encode<=2'b10;
            4'b0111:encode<=2'b11;
        endcase
	end
	
	wire key_down;
	assign key_down=(key[0]&key[1]&key[2]&key[3]);
	wire key_down_flag;
	
	key_filter key_filter_inst0
	(
		   .sys_clk(sys_clk),
			.sys_rst_n(sys_rst),
			.key_in(key_down),
			.key_flag(key_down_flag)
	);
	
	always@(negedge key_down_flag)begin
		if(sys_rst==1'b0)
			nex_st<=INIT;
		else begin
			case (cur_st)
				INIT:begin
					if(encode == 2'b00)
						nex_st<=S1;
					else
						nex_st<=INIT;
				end
				S1:begin
					if(encode == 2'b01)
						nex_st<=S2;
					else
						nex_st<=S1;
				end
				S2:begin
					if(encode == 2'b10)
						nex_st<=S3;
					else if(encode == 2'b00)
								nex_st <= S1;
							else
								nex_st<=INIT;
				end
				S3:begin
					if(encode == 2'b11)
						nex_st<=S4;
					else if(encode == 2'b00)
								nex_st <= S1;
							else
								nex_st<=INIT;
				end
				S4:begin 
						if(encode == 2'b00)
							nex_st <= S1;
						else
							nex_st<=INIT;
				end
			endcase
		end
	end
	
	always@(posedge sys_clk)begin
		case (cur_st)
			INIT:begin
				ledpin<=4'b1111;
			end
			S1:begin
				ledpin<=4'b1110;
			end
			S2:begin
				ledpin<=4'b1100;
			end
			S3:begin
				ledpin<=4'b1000;
			end
			S4:begin
				ledpin<=4'b0000;	
			end
		endcase
			
	end
	
	 
endmodule