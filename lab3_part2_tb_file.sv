// test bench 2 for Lab 3 stretch with independent left/straight
// CSE140L   
// expanded version -- try the simpler traffic_tb first if
//  you do not pass this one
// CSE140L   Lab 3   stretch
import light_package ::*;
module lab3_part2_tbf;

logic clk = 0,
      reset = 1,			  // should put your design in all-red
      e_left_sensor = 0,	  // e-bound left turn traffic
	  e_str_sensor  = 0,	  // e-bound thru traffic
	  w_left_sensor = 0,	  // w-bound left turn traffic
	  w_str_sensor  = 0,      // w-bound thru traffic
	  ns_sensor     = 0;      // traffic on n-s street
colors e_left_light,           // left arrow e turn onto n
	  e_str_light,	          // straight ahead e
	  w_left_light,           // left arrow w turn onto s
	  w_str_light,            // straight ahead w
	  ns_light;	              // n-s (no left/thru differentiation)

// your controller goes here
// input ports = logics above
// output ports = colors (enums) above (each 2 bits wide)
traffic_light_controller dut(.*);

colors e_l, e_s, w_l, w_s, ns;
assign e_l = e_left_light;
assign e_s = e_str_light ;
assign w_l = w_left_light;
assign w_s = w_str_light ;
assign ns  = ns_light    ;

int fi;
always begin
  #3ns; 
// print active sensors into result file
  if(e_left_sensor)
    $fwrite(fi,"el  ");
  else
    $fwrite(fi,"    ");
  if(e_str_sensor)
    $fwrite(fi,"es  ");
  else
    $fwrite(fi,"    ");
  if(w_left_sensor)
    $fwrite(fi,"wl  ");
  else
    $fwrite(fi,"    ");
  if(w_str_sensor)
    $fwrite(fi,"ws  ");
  else
    $fwrite(fi,"    ");
  if(ns_sensor)
    $fwrite(fi,"ns  ");
  else
    $fwrite(fi,"    ");
  $fwrite(fi,"    ");
// print yellow and green states into result file
  case(e_left_light)
	green:   $fwrite(fi, "elg   ");
	yellow:	 $fwrite(fi, "ely   ");
	default: $fwrite(fi, "      ");
  endcase
  case(e_str_light)
	green:   $fwrite(fi, "esg   ");
	yellow:	 $fwrite(fi, "esy   ");
	default: $fwrite(fi, "      ");
  endcase
  case(w_left_light)
	green:   $fwrite(fi, "wlg   ");
	yellow:	 $fwrite(fi, "wly   ");
	default: $fwrite(fi, "      ");
  endcase
  case(w_str_light)
	green:   $fwrite(fi, "wsg   ");
	yellow:	 $fwrite(fi, "wsy   ");
	default: $fwrite(fi, "      ");
  endcase
  case(ns_light)
    green:   $fdisplay(fi, "nsg   %t",$time);
	yellow:  $fdisplay(fi, "nsy   %t",$time);
	default: $fdisplay(fi, "      %t",$time);
  endcase
  if(e_left_light && (w_str_light || ns_light)) $fdisplay(fi, "*****error*****");
  if(w_left_light && (e_str_light || ns_light)) $fdisplay(fi, "*****error*****");
  if(w_str_light && ns_light) 				   $fdisplay(fi, "*****error*****");
  if(e_str_light && ns_light)                  $fdisplay(fi, "*****error*****");
  #2ns clk = 1'b1;
  #5ns clk = 1'b0;
/*  case({ew_left_light,ew_str_light,ns_light})
    6'b00_00_00: $fdisplay(fi, "           %t",$time);
	6'b01_00_00: $fdisplay(fi, "y          %t",$time);
	6'b10_00_00: $fdisplay(fi, "g          %t",$time);
	6'b00_01_00: $fdisplay(fi, "   y       %t",$time);
	6'b00_10_00: $fdisplay(fi, "   g       %t",$time);
	6'b00_00_01: $fdisplay(fi, "       y   %t",$time);
	6'b00_00_10: $fdisplay(fi, "       g   %t",$time);
	default    : $fdisplay(fi, "***ERROR** %t",$time);
  endcase 	 */
end

logic [3:0] test_cnt;          // lets testbench track tests
initial begin
  $dumpfile("dump.vcd");
  $dumpvars;
  fi = $fopen("lab3_rslt1_stretch.txt","w");
  $fdisplay(fi, "e   e   w   w   n        e     e     w     w     n");	   // header for y, g status display
  $fdisplay(fi, "l   s   l   s   s        l     s     l     s     s");
  test_cnt       = 4'd0;
  #20ns reset    = 1'b0;
  #10ns;
// Test E_LEFT to W_STR without more traffic
  test_cnt++                 ;
  e_left_sensor       = 1'b1 ;
  #30ns w_left_sensor = 1'b1 ;
  #60ns e_left_sensor = 1'b0 ;
  #20ns e_str_sensor  = 1'b1 ;
  #30ns w_str_sensor  = 1'b1 ;
  #60ns e_str_sensor  = 1'b0 ;
  #10ns w_str_sensor  = 1'b0;
  #30ns w_left_sensor = 1'b0;
  #200ns;

// Now set traffic at NS. Green NS lasts past sensor falling
  test_cnt++                  ;
  ns_sensor           = 1'b1  ;
  #60ns ns_sensor     = 1'b0  ;
  #200ns;

// Check NS again, but hold for more than 5 cycles.
//   NS should cycle green-yellow-red when side traffic appears
  test_cnt++;
  ns_sensor              = 1'b1;
  #100ns e_left_sensor   = 1'b1;
  #200ns ns_sensor       = 1'b0;
  #20ns  e_left_sensor   = 1'b0;
  #100ns;

// All five sensors become 1 at once.
//  EW_STR should come first, then LEFT, then NS
  test_cnt++;
  e_left_sensor  = 1'b1;
  e_str_sensor   = 1'b1;
  w_left_sensor  = 1'b1;
  w_str_sensor   = 1'b1;
  ns_sensor      = 1'b1;
  #1000ns;
  w_left_sensor  = 1'b0;
  #200ns;
  e_str_sensor   = 1'b0;
  ns_sensor      = 1'b0;
  #40ns;
  w_str_sensor   = 1'b0;
  #20ns;
  e_left_sensor  = 1'b0;
  #200ns;

// All
  test_cnt++;
  $stop;
end

endmodule
