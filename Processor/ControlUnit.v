module Control_Unit(Clock, Run, Reset, IR, z);
//z = {Done, R0in, R1in, R2in, R3in, R4in, R5in, R6in, R7in, R0out, R1out, R2out, R3out, R4out, R5out, R6out, R7out, IRin, Gout, DINout, Ain, Gin, AddSub}
input Clock, Run, Reset;
input [8:0] IR;
output reg [22:0] z;
wire [7:0] RX;
reg [7:0] R_X;
wire [7:0] RY;
reg [7:0] R_Y;
reg [1:0] n_state, p_state;
//Setting states for different time steps of our processor
parameter [1:0] I = 4'b00, A = 4'b01, B = 4'b10, C = 4'b11;
always @(*)
	case(p_state)
	I: if(Run)
		n_state = A;
		else
		n_state = I;
	A: if((IR[8:6] == 3'b000)|(IR[8:6] == 3'b001))
		n_state = I;
		else
		n_state = B;
	B: if((IR[8:6] == 3'b000)|(IR[8:6] == 3'b001))
		n_state = I;
		else
		n_state = C;
	C: n_state = I;
	endcase
always @(posedge Clock, negedge Reset)
	if(!Reset)
		p_state = I;
	else
		p_state = n_state;
//Decoder to translate register names to the required control signal
dec3to8 DX(IR[5:3], RX, 1'b1);
dec3to8 DY(IR[2:0], RY, 1'b1);
always@(*)
begin
	R_X = RX;
	R_Y = RY;
	case(p_state)
	I: begin	//At t=0, when instruction is read
		z[5] = 1;
		z[22:6] = 0;
		z[4] = 0;
		z[3] = 1;
		z[2:0] = 0;
		end
	A: if(IR[8:6] == 3'b000)	//At t = 1, depending on the instruction given
		begin
		z[21:14] = R_X;
		z[13:6] = R_Y;
		z[22] = 1;
		z[5:0] = 0;
		end
		else
		if(IR[8:6] == 3'b001)
		begin
		z[21:14] = R_X;
		z[13:6] = 0;
		z[22] = 1;
		z[3] = 1;
		z[5:4] = 0;
		z[2:0] = 0;
		end
		else
		if(IR[8:6] == 3'b010)
		begin
		z[13:6] = R_X;
		z[21:14] = 0;
		z[22] = 0;
		z[2] = 1;
		z[5:3] = 0;
		z[1:0] = 0;
		end
		else
		if(IR[8:6] == 3'b011)
		begin
		z[13:6] = R_X;
		z[21:14] = 0;
		z[2] = 1;
		z[22] = 0;
		z[5:3] = 0;
		z[1:0] = 0;
		end
	B: if(IR[8:6] == 3'b010)		//At t = 2, depending on the instruction given
		begin
		z[13:6] = R_Y;
		z[21:14] = 0;
		z[22] = 0;
		z[1] = 1;
		z[5:2] = 0;
		z[0] = 0;
		end
		else
		if(IR[8:6] == 3'b011)
		begin
		z[13:6] = R_Y;
		z[21:14] = 0;
		z[0] = 1;
		z[1] = 1;
		z[5:2] = 0;
		z[22] = 0;
		end
		else
		begin
		z[5] = 1;
		z[22:6] = 0;
		z[4] = 0;
		z[3] = 1;
		z[2:0] = 0;
		end
	C: if(IR[8:6] == 3'b010)		//At t = 3, depending on the instruction given
		begin
		z[21:14] = R_X;
		z[13:6] = 0;
		z[4] = 1;
		z[5] = 0;
		z[22] = 1;
		z[3:0] = 0;
		end
		else
		if(IR[8:6] == 3'b011)
		begin
		z[13:6] = R_Y;
		z[21:14] = 0;
		z[0] = 1;
		z[1] = 1;
		z[5:2] = 0;
		z[22] = 0;
		end
		else
		begin
		z[21:14] = R_X;
		z[13:6] = 0;
		z[22] = 1;
		z[4] = 1;
		z[5] = 0;
		z[3:0] = 0;
		end
	endcase
end
endmodule