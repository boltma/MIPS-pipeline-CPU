module DataMemory(reset, clk, Address, Write_data, Read_data, MemRead, MemWrite);
	input reset, clk;
	input [31:0] Address, Write_data;
	input MemRead, MemWrite;
	output [31:0] Read_data;
	
	parameter RAM_SIZE = 512;
	parameter RAM_SIZE_BIT = 9;
	
	reg [31:0] RAM_data[RAM_SIZE - 1: 0];
	assign Read_data = MemRead? RAM_data[Address[RAM_SIZE_BIT + 1:2]]: 32'h00000000;
	
	initial begin
		RAM_data[0] <= 32'hf92aafe5;
		RAM_data[1] <= 32'hd8c96445;
		RAM_data[2] <= 32'h413b86e7;
		RAM_data[3] <= 32'heed9798e;
		RAM_data[4] <= 32'h26917447;
		RAM_data[5] <= 32'hc70b2634;
		RAM_data[6] <= 32'h8c292a90;
		RAM_data[7] <= 32'h0caa22b8;
		RAM_data[8] <= 32'hcc90d96b;
		RAM_data[9] <= 32'hce6c75bf;
		RAM_data[10] <= 32'ha75cd7cc;
		RAM_data[11] <= 32'hadcb3cc6;
		RAM_data[12] <= 32'h0c57c5e0;
		RAM_data[13] <= 32'hbf6c6a41;
		RAM_data[14] <= 32'h72122d31;
		RAM_data[15] <= 32'he5f62ca8;
		RAM_data[16] <= 32'h3ba10801;
		RAM_data[17] <= 32'h12175244;
		RAM_data[18] <= 32'hda8f195f;
		RAM_data[19] <= 32'h79c8e19e;
		RAM_data[20] <= 32'h82243076;
		RAM_data[21] <= 32'hf57b713c;
		RAM_data[22] <= 32'hcba9a374;
		RAM_data[23] <= 32'h79dc6c10;
		RAM_data[24] <= 32'h51e8f18d;
		RAM_data[25] <= 32'hdf021e88;
		RAM_data[26] <= 32'h836ab8df;
		RAM_data[27] <= 32'h63c4cc75;
		RAM_data[28] <= 32'h6d6c2403;
		RAM_data[29] <= 32'h2b7d9cca;
		RAM_data[30] <= 32'hb54596bc;
		RAM_data[31] <= 32'h9af3b2ad;
		RAM_data[32] <= 32'h3a3c59cd;
		RAM_data[33] <= 32'hd4dd1e60;
		RAM_data[34] <= 32'h63a76745;
		RAM_data[35] <= 32'h01d4fc88;
		RAM_data[36] <= 32'hb1db06d1;
		RAM_data[37] <= 32'hc9903dee;
		RAM_data[38] <= 32'hf2ed014b;
		RAM_data[39] <= 32'h1586f253;
		RAM_data[40] <= 32'hbc59d67f;
		RAM_data[41] <= 32'hdb4e4582;
		RAM_data[42] <= 32'hc56f747b;
		RAM_data[43] <= 32'h0b621a03;
		RAM_data[44] <= 32'h44ba8088;
		RAM_data[45] <= 32'h89dff8dd;
		RAM_data[46] <= 32'h17807a89;
		RAM_data[47] <= 32'h4aef4aed;
		RAM_data[48] <= 32'hc15b9d72;
		RAM_data[49] <= 32'h13c267e7;
		RAM_data[50] <= 32'h30f53087;
		RAM_data[51] <= 32'he57256ee;
		RAM_data[52] <= 32'h688ae195;
		RAM_data[53] <= 32'h3209dcb5;
		RAM_data[54] <= 32'hc40b4a14;
		RAM_data[55] <= 32'h4afbc79f;
		RAM_data[56] <= 32'h7086de1f;
		RAM_data[57] <= 32'h4d3c7db7;
		RAM_data[58] <= 32'hcc05dac6;
		RAM_data[59] <= 32'hf1d74e4c;
		RAM_data[60] <= 32'h3acc77bc;
		RAM_data[61] <= 32'h27ba4dfd;
		RAM_data[62] <= 32'hc021dc50;
		RAM_data[63] <= 32'hfdae1f0b;
		RAM_data[64] <= 32'ha01025fc;
		RAM_data[65] <= 32'he929ac75;
		RAM_data[66] <= 32'h34853173;
		RAM_data[67] <= 32'he9785495;
		RAM_data[68] <= 32'h53a8b12d;
		RAM_data[69] <= 32'hc09dab51;
		RAM_data[70] <= 32'h5e731cbe;
		RAM_data[71] <= 32'h2f1d2bf2;
		RAM_data[72] <= 32'hb5639da2;
		RAM_data[73] <= 32'h13f9c7de;
		RAM_data[74] <= 32'h20139cb0;
		RAM_data[75] <= 32'h6137d3a4;
		RAM_data[76] <= 32'hfb4e1bc8;
		RAM_data[77] <= 32'hf7fb85ca;
		RAM_data[78] <= 32'hb537521e;
		RAM_data[79] <= 32'h9fb00237;
		RAM_data[80] <= 32'h2abc4889;
		RAM_data[81] <= 32'hf33356c8;
		RAM_data[82] <= 32'h7514645f;
		RAM_data[83] <= 32'h4fc11da8;
		RAM_data[84] <= 32'h90dba56a;
		RAM_data[85] <= 32'h08dafb8a;
		RAM_data[86] <= 32'h74d1d72c;
		RAM_data[87] <= 32'h6d99f189;
		RAM_data[88] <= 32'h5c062667;
		RAM_data[89] <= 32'h0eed0f4d;
		RAM_data[90] <= 32'he5a6ce69;
		RAM_data[91] <= 32'h78f2a147;
		RAM_data[92] <= 32'hdbde7e1c;
		RAM_data[93] <= 32'h34b09742;
		RAM_data[94] <= 32'hc98a4889;
		RAM_data[95] <= 32'h4398030d;
		RAM_data[96] <= 32'h4b33a282;
		RAM_data[97] <= 32'h2aec446d;
		RAM_data[98] <= 32'h2cacd5b3;
		RAM_data[99] <= 32'he7a57964;
		RAM_data[100] <= 32'hcf833ca5;
		RAM_data[101] <= 32'h202d3474;
		RAM_data[102] <= 32'h92a74b24;
		RAM_data[103] <= 32'hb85a3fd8;
		RAM_data[104] <= 32'ha4ef8d5e;
		RAM_data[105] <= 32'h84f89d70;
		RAM_data[106] <= 32'h5f566ea0;
		RAM_data[107] <= 32'hc392977f;
		RAM_data[108] <= 32'h3f4e7ec8;
		RAM_data[109] <= 32'h08d9bf0a;
		RAM_data[110] <= 32'h44cdd3b4;
		RAM_data[111] <= 32'h49b78bc7;
		RAM_data[112] <= 32'h2617e54f;
		RAM_data[113] <= 32'he99e5fbb;
		RAM_data[114] <= 32'ha409934b;
		RAM_data[115] <= 32'hdb0bb199;
		RAM_data[116] <= 32'h20319745;
		RAM_data[117] <= 32'hf1073ef3;
		RAM_data[118] <= 32'hc1b77621;
		RAM_data[119] <= 32'h8337b3b4;
		RAM_data[120] <= 32'hc8a42c19;
		RAM_data[121] <= 32'hbb5a99d6;
		RAM_data[122] <= 32'ha013f691;
		RAM_data[123] <= 32'h3a853843;
		RAM_data[124] <= 32'h62bb82e7;
		RAM_data[125] <= 32'h2487fe58;
		RAM_data[126] <= 32'hbc8e61d2;
		RAM_data[127] <= 32'h894a7c44;
	end
	
	integer i;
	always @(posedge reset or posedge clk)
		if (reset)
			for (i = 128; i < RAM_SIZE; i = i + 1)
				RAM_data[i] <= 32'h00000000;
		else if (MemWrite)
			RAM_data[Address[RAM_SIZE_BIT + 1:2]] <= Write_data;
			
endmodule
