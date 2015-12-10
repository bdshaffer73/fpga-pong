module ps2lab1(
> // Clock Input (50 MHz)
> input  CLOCK\_50,
> //  Push Buttons
> input  [3:0]  KEY,
> //  DPDT Switches
> input  [17:0]  SW,
> //  7-SEG Displays
> output  [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
> //  LEDs
> output  [8:0]  LEDG,  //  LED Green[8:0]
> output  [17:0]  LEDR,  //  LED Red[17:0]
> //  PS2 data and clock lines
> input    PS2\_DAT,
> input    PS2\_CLK,
> //  GPIO Connections
> inout  [35:0]  GPIO\_0, GPIO\_1
);

//  set all inout ports to tri-state
assign  GPIO\_0    =  36'hzzzzzzzzz;
assign  GPIO\_1    =  36'hzzzzzzzzz;

wire RST;
assign RST = KEY[0](0.md);


// Connect dip switches to red LEDs
assign LEDR[17:0] = SW[17:0];

// turn off green LEDs
assign LEDG = 0;

wire reset = 1'b0;
wire [7:0] scan\_code;

reg [7:0] history[1:4];
wire read, scan\_ready;

oneshot pulser(
> .pulse\_out(read),
> .trigger\_in(scan\_ready),
> .clk(CLOCK\_50)
);

keyboard kbd(
> .keyboard\_clk(PS2\_CLK),
> .keyboard\_data(PS2\_DAT),
> .clock50(CLOCK\_50),
> .reset(reset),
> .read(read),
> .scan\_ready(scan\_ready),
> .scan\_code(scan\_code)
);
//stuff were sending over for the hex to display
hex\_7seg dsp0(history[1](1.md)[3:0],HEX0);
hex\_7seg dsp1(history[1](1.md)[7:4],HEX1);

hex\_7seg dsp2(history[2](2.md)[3:0],HEX2);
hex\_7seg dsp3(history[2](2.md)[7:4],HEX3);

hex\_7seg dsp4(history[3](3.md)[3:0],HEX4);
hex\_7seg dsp5(history[3](3.md)[7:4],HEX5);

hex\_7seg dsp6(history[4](4.md)[3:0],HEX6);
hex\_7seg dsp7(history[4](4.md)[7:4],HEX7);



always @(posedge scan\_ready)
begin
> history[4](4.md) <= history[3](3.md);
> history[3](3.md) <= history[2](2.md);
> history[2](2.md) <= history[1](1.md);
> history[1](1.md) <= scan\_code;
end


// blank remaining digits
/**wire [6:0] blank = 7'h7f;
assign HEX2 = blank;
assign HEX3 = blank;
assign HEX4 = blank;
assign HEX5 = blank;
assign HEX6 = blank;
assign HEX7 = blank;**/

endmodule



module keyboard(keyboard\_clk, keyboard\_data, clock50, reset, read, scan\_ready, scan\_code);
input keyboard\_clk;
input keyboard\_data;
input clock50; // 50 Mhz system clock
input reset;
input read;
output scan\_ready;
output [7:0] scan\_code;
reg ready\_set;
reg [7:0] scan\_code;
reg scan\_ready;
reg read\_char;
reg clock; // 25 Mhz internal clock

reg [3:0] incnt;
reg [8:0] shiftin;

reg [7:0] filter;
reg keyboard\_clk\_filtered;

// scan\_ready is set to 1 when scan\_code is available.
// user should set read to 1 and then to 0 to clear scan\_ready

always @ (posedge ready\_set or posedge read)
if (read == 1) scan\_ready <= 0;
else scan\_ready <= 1;

// divide-by-two 50MHz to 25MHz
always @(posedge clock50)
> clock <= ~clock;



// This process filters the raw clock signal coming from the keyboard
// using an eight-bit shift register and two AND gates

always @(posedge clock)
begin
> filter <= {keyboard\_clk, filter[7:1]};
> if (filter==8'b1111\_1111) keyboard\_clk\_filtered <= 1;
> else if (filter==8'b0000\_0000) keyboard\_clk\_filtered <= 0;
end


// This process reads in serial data coming from the terminal

always @(posedge keyboard\_clk\_filtered)
begin
> if (reset==1)
> begin
> > incnt <= 4'b0000;
> > read\_char <= 0;

> end
> else if (keyboard\_data==0 && read\_char==0)
> begin
> > read\_char <= 1;
> > ready\_set <= 0;

> end
> else
> begin
> > // shift in next 8 data bits to assemble a scan code
> > if (read\_char == 1)
> > > begin
> > > > if (incnt < 9)
> > > > begin
> > > > > incnt <= incnt + 1'b1;
> > > > > shiftin = { keyboard\_data, shiftin[8:1]};
> > > > > ready\_set <= 0;

> > > > end

> > > else
> > > > begin
> > > > > incnt <= 0;
> > > > > scan\_code <= shiftin[7:0];
> > > > > read\_char <= 0;
> > > > > ready\_set <= 1;

> > > > end

> > > end

> > end
end

endmodule


module oneshot(output reg pulse\_out, input trigger\_in, input clk);
reg delay;

always @ (posedge clk)
begin

> if (trigger\_in && !delay)
> pulse\_out <= 1'b1;
> > else pulse\_out <= 1'b0;
> > > delay <= trigger\_in;
end
endmodule

module hex\_7seg(hex\_digit,seg);
input [3:0] hex\_digit;
output [6:0] seg;
reg [6:0] seg;
// seg = {g,f,e,d,c,b,a};
// 0 is on and 1 is off

always @ (hex\_digit)
case (hex\_digit)

> 4'h0: seg = 7'b1000000;
> 4'h1: seg = 7'b1111001;     // ---a----
> 4'h2: seg = 7'b0100100;     // |      |
> 4'h3: seg = 7'b0110000;     // f      b
> 4'h4: seg = 7'b0011001;     // |      |
> 4'h5: seg = 7'b0010010;     // ---g----
> 4'h6: seg = 7'b0000010;     // |      |
> 4'h7: seg = 7'b1111000;     // e      c
> 4'h8: seg = 7'b0000000;     // |      |
> 4'h9: seg = 7'b0011000;     // ---d----
> 4'ha: seg = 7'b0001000;
> 4'hb: seg = 7'b0000011;
> 4'hc: seg = 7'b1000110;
> 4'hd: seg = 7'b0100001;
> 4'he: seg = 7'b0000110;
> 4'hf: seg = 7'b0001110;
endcase

endmodule