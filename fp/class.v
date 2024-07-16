module fp_class (

    value, qNaN, sNaN, zero, infinity, normal ,subnormal

);

  input [15:0]value;
  output qNaN, sNaN, zero, infinity, normal ,subnormal;

  wire exp_zero, exp_ones, mant_zero;

  assign exp_zero = ~|value[14:10];
  assign exp_ones = &value[14:10];
  assign mant_zero = ~|value[9:0];

  assign sNaN = exp_ones & ~value[9] & ~mant_zero;
  assign qNaN = exp_ones & value[9];
  assign zero = exp_zero & mant_zero;
  assign infinity = exp_ones & mant_zero;
  assign subnormal = exp_zero & ~mant_zero;
  assign normal = ~exp_ones & ~exp_ones;

  

endmodule