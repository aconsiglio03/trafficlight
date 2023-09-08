// maps 2'b00, 01, 10 to red, yellow, green, respectively
// allows 2'b11, but it will not get a name associated with it 
package light_package;

  typedef enum logic[1:0] {red,yellow,green} colors;

endpackage