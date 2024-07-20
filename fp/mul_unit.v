module mul (
    op_a, op_b, p, sNaN_o, qNaN_o, infinity_o, zero_o, subnormal_o, normal_o
);
   
    input [15:0] op_a,op_b;
    output [15:0]p;

    output reg sNaN_o, qNaN_o, infinity_o, zero_o, subnormal_o, normal_o;
    
    wire a_sNaN, a_qNaN, a_zero, a_infinity, a_subnormal, a_normal;
    wire b_sNaN, b_qNaN, b_zero, b_infinity, b_subnormal, b_normal;

    fp_class uut1(op_a, a_sNaN, a_qNaN, a_zero, a_infinity, a_subnormal, a_normal);
    fp_class uut2(op_b, b_sNaN, b_qNaN, b_zero, b_infinity, b_subnormal, b_normal);

    reg p_temp;
    reg p_sign;

    reg [10:0]sig_a, sig_b;
    reg [6:0]exp_a,exp_b;
    reg [6:0]t1_exp,t2_exp;
    reg [21:0]raw_sig;
    reg [10:0]p_sig,t_sig;


    always @(*) begin
        p_temp = {1'b0,{5{1'b1}},1'b0,{9{1'b1}}};
        p_sign = op_a[15] ^ op_b[15];
        sig_a = {1'b1,op_a[9:0]};
        sig_b = {1'b1,op_b[9:0]};
        exp_a = op_a[14:10] - 15;
        exp_b = op_b[14:10] - 15;
        raw_sig = sig_a * sig_b;
        t1_exp = exp_a + exp_b;


    end



    always @(*) begin
        if(raw_sig[21] == 1) begin
            t_sig = raw_sig[21:11];
            t2_exp = t1_exp + 1;
            
        end
        else begin
            t_sig = raw_sig[20:10];
            t2_exp = t1_exp;
        end
    end

    always @(*) begin
        if(t2_exp < -24) begin
            p_temp = {p_sign,{15{1'b0}}}; // zero
            zero_o = 1;
        end

        else if(t2_exp < -14) begin
            p_sig = t_sig >> (-14 - t2_exp);
            p_temp = {p_sign, {5{1'b0}}, p_sig[9:0]}; //subnormal
            subnormal = 1;
        end

        else if (t2Exp > 15) // Infinity
          begin
            p_temp = {p_sign, {5{1'b1}}, {10{1'b0}}};
            infinity = 1;
          end

        else // Normal
          begin
            p_exp = t2_exp + 15;
            p_sig = t_sig;
            p_temp = {p_sign, p_exp[4:0], p_sig[9:0]};
            normal = 1;
          end
      
    end

    always @(*) begin
        if((a_sNaN | b_sNaN ) == 1) begin
            p_temp = (a_sNaN) ? a : b;
            sNaN_o = 1;
        end
        else if ((a_qNaN | b_qNaN ) == 1) begin
            p_temp = (a_qNaN) ? a : b;
            qNaN_o = 1;
        end
        else if((a_infinity | b_infinity) == 1) begin
            if((a_zero | b_zero) == 1) begin
                p_temp = {p_sign,{5{1'b1}},1'b1,9'h02A};
                qNaN_o = 1;
            end

            else begin
                p_temp = {p_sign,{5{1'b1},10'b0}};
                infinity_o = 1;
            end
        end

        else if(((a_zero | b_zero) || (a_subnormal & b_subnormal) == 1)) begin
            p_temp = {p_sign,{15{1'b0}}};
            zero_o = 1;
        end

    end



endmodule
