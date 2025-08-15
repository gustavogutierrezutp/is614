 // And module as hello world de1-soc
 module and1(
 
   switch0, 		// 1 bit binary input
   switch1, 		// 1 bit binary input
   led0, 		   // 1 bit binary Output
  );
 
 
 input  switch0;
 input  switch1;
 output led0;
 assign led0 = switch0 & switch1;	
endmodule 