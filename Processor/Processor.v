module Processor(Clock, Reset, DIN, Run, Done, Bus);
input Clock, Reset, Run;
input [8:0] DIN;
output Done;
reg [8:0] IR, R0, R1, R2, R3, R4, R5, R6, R7, A, G;
output reg [8:0] Bus;
wire [8:0] IR_;
assign IR_ = IR;
wire [22:0] z;
Control_Unit C(Clock, Run, Reset, IR_, z);
assign Done = z[22];
//MUX which judges the BUS output
always @(*)
begin
	casex(z[13:6])
	8'b1xxxxxxx: Bus = R7;
	8'b01xxxxxx: Bus = R6;
	8'b001xxxxx: Bus = R5;
	8'b0001xxxx: Bus = R4;
	8'b00001xxx: Bus = R3;
	8'b000001xx: Bus = R2;
	8'b0000001x: Bus = R1;
	8'b00000001: Bus = R0;
	endcase
	if(z[4])
		Bus = G;
	if(z[3])
		Bus = DIN;
end
//Eabers for registers and adding and subtracting
always @(posedge Clock, negedge Reset)
	if(!Reset)
	begin
		IR = 0;
		R0 = 0;
		R1 = 0;
		R2 = 0;
		R3 = 0;
		R4 = 0;
		R5 = 0;
		R6 = 0;
		R7 = 0;
		A = 0;
		G = 0;
	end
	else
	begin
		casex(z[21:14])
		8'b1xxxxxxx: R7 = Bus;
		8'b01xxxxxx: R6 = Bus;
		8'b001xxxxx: R5 = Bus;
		8'b0001xxxx: R4 = Bus;
		8'b00001xxx: R3 = Bus;
		8'b000001xx: R2 = Bus;
		8'b0000001x: R1 = Bus;
		8'b00000001: R0 = Bus;
		endcase
		if(z[2])
			A = Bus;
		if(z[1])
		if(z[0])
			G = A - Bus;
		else
			G = A + Bus;
		if(z[5])
			IR = DIN;
	end
endmodule