module Visual_Pong(clk, VGA_R,VGA_B,VGA_G,VGA_BLANK_N, VGA_SYNC_N , VGA_HS, VGA_VS, rst, VGA_CLK, Button3, Button2, Button1, Button0);

    output [7:0] VGA_R, VGA_B, VGA_G;
    output VGA_HS, VGA_VS, VGA_BLANK_N, VGA_CLK, VGA_SYNC_N;
    input clk, rst;
	 input Button0, Button1, Button2, Button3;
	 wire WireButton0, WireButton1, WireButton2, WireButton3;
    wire CLK108;
	 wire [30:0]X, Y;
	 reg [31:0]P1In, P2In;
	 reg [31:0]ballX, ballY;
	 
	 reg winCond=0;
	 
	 assign WireButton0=Button0;
	 assign WireButton1=Button1;
	 assign WireButton2=Button2;
	 assign WireButton3=Button3;	 
	 assign refresh= (X==0)&&(Y==0);
	 
	 //paddle 1's parameters
	 localparam P1_L=31'd100;
	 localparam P1_R=31'd125;
	 localparam P1_T=31'd75; //P1In
	 localparam P1_B=31'd100+P1_T; //P1In
	 assign Paddle1=((X>=P1_L)&&(X<=P1_R)&&(Y>=(P1_T+P1In))&&(Y<=(P1In+P1_B)));
	 
	//paddle 2 parameters   										
	localparam P2_L=31'd1125;
	localparam P2_R=31'd1150;
	localparam P2_T=31'd75;
	localparam P2_B=31'd100+P2_T;
	assign Paddle2=((X>=P2_L)&&(X<=P2_R)&&(Y>=(P2_T+P2In))&&(Y<=(P2_B+P2In)));

	//Ball_Parameters
	localparam Ball_L= 31'd100;
	localparam Ball_R= Ball_L+31'd20;
	localparam Ball_T= 31'd75 ;
	localparam Ball_B=Ball_T+31'd20;
	assign Ball=((X>=Ball_L + ballX)&&(X<=Ball_R + ballX)&&(Y>=Ball_T+ ballY)&&(Y<=Ball_B+ ballY));
	reg ballDirectionX=1;
	reg ballDirectionY=1;
	 
	 reg black;
	
    clock108(rst, clk, CLK_108, locked);

    wire hblank, vblank, clkLine, blank;

    H_SYNC(CLK_108, VGA_HS, hblank, clkLine, X);
    V_SYNC(clkLine, VGA_VS, vblank, Y);


    //drawing shapes	
	 always@(*)
		begin
			if(Paddle1 | Paddle2| Ball)//Paddle1
				black=1'b0;
			else
				black=1'b1;
		end
	
	
	reg temp;
	reg [31:0]count;
	

	always@(posedge clk)	
	begin
				if(count>=31'd100010)
					count<=0;
				else
					count<=count+1;
			
				//Paddle1
				if(WireButton0==1'b0 && count==31'd100000) // jimmy said to input a counter here
					P1In<=P1In+31'd1;
				else
					temp<=temp;
				
				if(WireButton1==1'b0 && count==31'd100000)
					P1In<=P1In-31'd1;	
				else
					temp<=temp;	
			
				if(P1In>31'd700)
					P1In<=31'd700;
				else
					temp<=temp;
		
				if(P1In<31'd25)
					P1In<=31'd25;	
				else
					temp<=temp;
			
		
				//paddle2
				if(WireButton3==1'b0 && count==31'd100000) // jimmy said to input a counter here
					P2In<=P2In+31'd1;
				else
					temp<=temp;
				
				if(WireButton2==1'b0 && count==31'd100000)
					P2In<=P2In-31'd1;	
				else
					temp<=temp;	
			
				if(P2In>31'd700)
					P2In<=31'd700;
				else
					temp<=temp;
		
				if(P2In<31'd25)
					P2In<=31'd25;	
				else
					temp<=temp;
			
		
	


				//ball movement
				if(count==31'd100000)
					begin
						//ball in X direction
						if(winCond && WireButton0 && WireButton1 && WireButton2 && WireButton3)
							begin
								ballX<=31'd500;
								P1In<=31'd350;
								P2In<=31'd350;
							end
						else if(ballDirectionX)
							begin
								ballX<=ballX+1;
								winCond<=0;
							end	
						else
							begin
								ballX<=ballX-1;
								winCond<=0;
							end

						if(ballX>=31'd1005 && ((P2In)<=(ballY+31'd10)) &&(P2In+31'd100)>=(ballY+31'd10) &&~winCond)
							begin
								ballX<=31'd1004;
								ballDirectionX<=1'b0;
							end
						else if(ballX>=31'd1005)
							winCond<=1;
						else
							temp<=temp;
							
						if(winCond)
							temp<=temp;
						else if(ballX<=31'd25 && ((P1In)<=(ballY+31'd10)) &&(P1In+31'd100)>=(ballY+31'd10) && ~winCond)
							begin
								ballX<=31'd26;
								ballDirectionX<=1'b1;
							end
						else if(ballX<=31'd20)
							begin
								winCond<=1;
							end
						else
							temp<=temp;

						//ball in y direction
						if(winCond && WireButton0 && WireButton1 && WireButton2 && WireButton3)
						begin
							ballY<=31'd400;
						end
                  else if(ballDirectionY)
						begin
							ballY<=ballY+1;	
						end
						else
						begin
							ballY<=ballY-1;
						end
						if(ballY>=31'd800)
							begin
								ballY<=31'd799;
								ballDirectionY<=1'b0;
							end
						else
							temp<=temp;
						if(ballY<=31'd50)
							begin
								ballY<=31'd51;
								ballDirectionY<=1;
							end
						else
							temp<=temp;
							

					end
				else	
					temp<=temp;

	end

	color(clk,VGA_R,VGA_B,VGA_G, black );
    assign VGA_CLK = CLK_108;
    assign VGA_BLANK_N = VGA_VS&VGA_HS;
    assign VGA_SYNC_N = 1'b0;
	 
	 
endmodule

module countingRefresh(X, Y, clk, count);
input [31:0]X, Y;
input clk;
output [7:0]count;
reg[7:0]count;
always@(posedge clk)
begin
	if(X==0 &&Y==0)
		count<=count+1;
	else if(count==7'd11)
		count<=0;
	else
		count<=count;
end

endmodule

module color(clk, red, blue, green, black);

     input clk, black;
    output [7:0] red, blue, green;
	 reg[7:0] red, green, blue;
	always@(*)
	begin
		if(black==1'b1)
		begin
		 red = 8'd0;
		 blue = 8'd0;
		 green = 8'd0;
		end 
		else
		begin
		 red = 8'd255;
		 blue = 8'd255;
		 green = 8'd255;
		end
	end
	 
endmodule

module H_SYNC(clk, hout, bout, newLine, Xcount);

    input clk;
    output hout, bout, newLine;
	 output [31:0] Xcount;
	 
	
    reg [31:0] count = 32'd0;
    reg hsync, blank, new1;

    always @(posedge clk) begin
        if (count <  1688)
            count <= Xcount + 1;
        else 
            count <= 0;
    end 

    always @(*) begin
        if (count == 0)
            new1 = 1;
        else
            new1 = 0;
    end 

    always @(*) begin
        if (count > 1279) 
            blank = 1;
        else 
            blank = 0;
    end

    always @(*) begin
        if (count < 1328)
            hsync = 1;
        else if (count > 1327 && count < 1440)
            hsync = 0;
        else    
            hsync = 1;
        end
    assign Xcount=count;
    assign hout = hsync;
    assign bout = blank;
    assign newLine = new1;

endmodule

module V_SYNC(clk, vout, bout, Ycount);

    input clk;
    output vout, bout;
    output [31:0]Ycount; 
	  
    reg [31:0] count = 32'd0;
    reg vsync, blank;

    always @(posedge clk) begin
        if (count <  1066)
            count <= Ycount + 1;
        else 
            count <= 0;
    end 

    always @(*) begin
        if (count < 1024) 
            blank = 1;
        else 
            blank = 0;
    end

    always @(*) begin
        if (count < 1025)
            vsync = 1;
        else if (count > 1024 && count < 1028)
            vsync = 0;
        else    
            vsync = 1;
        end
    assign Ycount=count;
    assign vout = vsync;
    assign bout = blank;

endmodule

 //synopsys translate_off
`timescale 1 ps / 1 ps
 //synopsys translate_on
module clock108 (areset, inclk0, c0, locked);

    input     areset;
    input     inclk0;
    output    c0;
    output    locked;

`ifndef ALTERA_RESERVED_QIS
 //synopsys translate_off
`endif

tri0      areset;

`ifndef ALTERA_RESERVED_QIS
 //synopsys translate_on
`endif

    wire [0:0] sub_wire2 = 1'h0;
    wire [4:0] sub_wire3;
    wire  sub_wire5;
    wire  sub_wire0 = inclk0;
    wire [1:0] sub_wire1 = {sub_wire2, sub_wire0};
    wire [0:0] sub_wire4 = sub_wire3[0:0];
    wire  c0 = sub_wire4;
    wire  locked = sub_wire5;

	 
	 
altpll  altpll_component (
            .areset (areset),
            .inclk (sub_wire1),
            .clk (sub_wire3),
            .locked (sub_wire5),
            .activeclock (),
            .clkbad (),
            .clkena ({6{1'b1}}),
            .clkloss (),
            .clkswitch (1'b0),
            .configupdate (1'b0),
            .enable0 (),
            .enable1 (),
            .extclk (),
            .extclkena ({4{1'b1}}),
            .fbin (1'b1),
            .fbmimicbidir (),
            .fbout (),
            .fref (),
            .icdrclk (),
            .pfdena (1'b1),
            .phasecounterselect ({4{1'b1}}),
            .phasedone (),
            .phasestep (1'b1),
            .phaseupdown (1'b1),
            .pllena (1'b1),
            .scanaclr (1'b0),
            .scanclk (1'b0),
            .scanclkena (1'b1),
            .scandata (1'b0),
            .scandataout (),
            .scandone (),
            .scanread (1'b0),
            .scanwrite (1'b0),
            .sclkout0 (),
            .sclkout1 (),
            .vcooverrange (),
            .vcounderrange ());
defparam
    altpll_component.bandwidth_type = "AUTO",
    altpll_component.clk0_divide_by = 25,
    altpll_component.clk0_duty_cycle = 50,
    altpll_component.clk0_multiply_by = 54,
    altpll_component.clk0_phase_shift = "0",
    altpll_component.compensate_clock = "CLK0",
    altpll_component.inclk0_input_frequency = 20000,
    altpll_component.intended_device_family = "Cyclone IV E",
    altpll_component.lpm_hint = "CBX_MODULE_PREFIX=clock108",
    altpll_component.lpm_type = "altpll",
    altpll_component.operation_mode = "NORMAL",
    altpll_component.pll_type = "AUTO",
    altpll_component.port_activeclock = "PORT_UNUSED",
    altpll_component.port_areset = "PORT_USED",
    altpll_component.port_clkbad0 = "PORT_UNUSED",
    altpll_component.port_clkbad1 = "PORT_UNUSED",
    altpll_component.port_clkloss = "PORT_UNUSED",
    altpll_component.port_clkswitch = "PORT_UNUSED",
    altpll_component.port_configupdate = "PORT_UNUSED",
    altpll_component.port_fbin = "PORT_UNUSED",
    altpll_component.port_inclk0 = "PORT_USED",
    altpll_component.port_inclk1 = "PORT_UNUSED",
    altpll_component.port_locked = "PORT_USED",
    altpll_component.port_pfdena = "PORT_UNUSED",
    altpll_component.port_phasecounterselect = "PORT_UNUSED",
    altpll_component.port_phasedone = "PORT_UNUSED",
    altpll_component.port_phasestep = "PORT_UNUSED",
    altpll_component.port_phaseupdown = "PORT_UNUSED",
    altpll_component.port_pllena = "PORT_UNUSED",
    altpll_component.port_scanaclr = "PORT_UNUSED",
    altpll_component.port_scanclk = "PORT_UNUSED",
    altpll_component.port_scanclkena = "PORT_UNUSED",
    altpll_component.port_scandata = "PORT_UNUSED",
    altpll_component.port_scandataout = "PORT_UNUSED",
    altpll_component.port_scandone = "PORT_UNUSED",
    altpll_component.port_scanread = "PORT_UNUSED",
    altpll_component.port_scanwrite = "PORT_UNUSED",
    altpll_component.port_clk0 = "PORT_USED",
    altpll_component.port_clk1 = "PORT_UNUSED",
    altpll_component.port_clk2 = "PORT_UNUSED",
    altpll_component.port_clk3 = "PORT_UNUSED",
    altpll_component.port_clk4 = "PORT_UNUSED",
    altpll_component.port_clk5 = "PORT_UNUSED",
    altpll_component.port_clkena0 = "PORT_UNUSED",
    altpll_component.port_clkena1 = "PORT_UNUSED",
    altpll_component.port_clkena2 = "PORT_UNUSED",
    altpll_component.port_clkena3 = "PORT_UNUSED",
    altpll_component.port_clkena4 = "PORT_UNUSED",
    altpll_component.port_clkena5 = "PORT_UNUSED",
    altpll_component.port_extclk0 = "PORT_UNUSED",
    altpll_component.port_extclk1 = "PORT_UNUSED",
    altpll_component.port_extclk2 = "PORT_UNUSED",
    altpll_component.port_extclk3 = "PORT_UNUSED",
    altpll_component.self_reset_on_loss_lock = "OFF",
    altpll_component.width_clock = 5;


endmodule
