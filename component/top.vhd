library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.headers.all;

entity top is 
    port (
        clk, reset : in std_logic;
        address : in std_logic_vector(6 downto 0);
        write, read : in std_logic;
        readdata : out std_logic_vector_32;
        writedata : in std_logic_vector_32
    );
end entity top ;

architecture arch of top is 
    --- component declaration 
    --- counter 
    component counter is 
        port (
            clk, reset : in std_logic;
            count : out std_logic_vector(4 downto 0)
        );
    end component counter;
    --- fp_mult 
    component fp_mult is 
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		dataa		: IN std_logic_vector_32; --(31 DOWNTO 0);
		datab		: IN std_logic_vector_32; -- (31 DOWNTO 0);
		result		: OUT std_logic_vector_32-- (31 DOWNTO 0)
	);
    end component fp_mult;

    -- fp_add
    component fp_add is 
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		dataa		: IN std_logic_vector_32; --(31 DOWNTO 0);
		datab		: IN std_logic_vector_32; -- (31 DOWNTO 0);
		result		: OUT std_logic_vector_32-- (31 DOWNTO 0)
	);

    end component fp_add;
    -- fp_abs
    component fp_abs is 
        port (
            clock : in std_logic;
            data : in std_logic_vector_32;
            result : out std_logic_vector_32
        );
    end component fp_abs;

    component fp_div is 
	PORT
	(
		aclr		: IN STD_LOGIC ;
		clock		: IN STD_LOGIC ;
		dataa		: IN std_logic_vector_32; --(31 DOWNTO 0);
		datab		: IN std_logic_vector_32; -- (31 DOWNTO 0);
		result		: OUT std_logic_vector_32-- (31 DOWNTO 0)
	);
    end component fp_div;

    component fp_add_and_sub is 
	PORT
	(
		aclr		: IN STD_LOGIC ;
		add_sub  : IN STD_LOGIC;
		clock		: IN STD_LOGIC ;
		dataa		: IN std_logic_vector_32; --(31 DOWNTO 0);
		datab		: IN std_logic_vector_32; -- (31 DOWNTO 0);
		result		: OUT std_logic_vector_32-- (31 DOWNTO 0)
	);
    end component fp_add_and_sub;

    component max_finder is 
    port (
        max_finder_input0 : in std_logic_vector_32;
        max_finder_input1 : in std_logic_vector_32;
        max_finder_input2 : in std_logic_vector_32;
        max_finder_input3 : in std_logic_vector_32;
        max_finder_input4 : in std_logic_vector_32;
        max_finder_input5 : in std_logic_vector_32;
        max_finder_input6 : in std_logic_vector_32;
        max_finder_output : out std_logic_vector_32
    );
    end component max_finder;

 -- input signal provided by users;
    signal A : matrix; 
    signal x : dim1 := ((others=> (others=>'0')));--(others =>(others)=>'0');
    signal B : dim1;
    signal mcg_index : std_logic_vector_32;
    -- signal defined 
    signal control_and_status_reg : std_logic_vector_32;
    signal state : tState;

    --- signal definition according to modified conjugate gradient method
    signal r : dim1;
    signal rold : dim1;
    signal p : dim1;
    signal Ap : dim1;
    signal reset_counter : std_logic;
    signal count_counter : std_logic_vector (4 downto 0);


    -- signal represeting the connection of multiplier and adder chain require for 7x7 matrix and 7x1 vector
    signal mult1_reg1 : std_logic_vector_32 ;    signal mult1_out_add1_in : std_logic_vector_32 ; -- := x"00000000"
    signal mult1_reg2 : std_logic_vector_32 ;    signal mult2_out_add1_in : std_logic_vector_32 ; -- := x"00000000"
    signal mult2_reg1 : std_logic_vector_32 ;    signal mult3_out_add2_in : std_logic_vector_32 ; -- := x"00000000"
    signal mult2_reg2 : std_logic_vector_32 ;    signal mult4_out_add2_in : std_logic_vector_32 ; -- := x"00000000"
    signal mult3_reg1 : std_logic_vector_32 ;    signal mult5_out_add3_in : std_logic_vector_32 ; -- := x"00000000"
    signal mult3_reg2 : std_logic_vector_32 ;    signal mult6_out_add3_in : std_logic_vector_32 ; -- := x"00000000"
    signal mult4_reg1 : std_logic_vector_32 ;    signal mult7_out_add4_in : std_logic_vector_32 ; -- := x"00000000"
    signal mult4_reg2 : std_logic_vector_32 ;    signal mult8_out_add4_in : std_logic_vector_32 ; -- := x"00000000"
    signal mult5_reg1 : std_logic_vector_32 ;    signal add1_out_add5_in : std_logic_vector_32 ;  -- := x"00000000"
    signal mult5_reg2 : std_logic_vector_32 ;    signal add2_out_add5_in : std_logic_vector_32 ;  -- := x"00000000"
    signal mult6_reg1 : std_logic_vector_32 ;    signal add3_out_add6_in : std_logic_vector_32 ;  -- := x"00000000"
    signal mult6_reg2 : std_logic_vector_32 ;    signal add4_out_add6_in : std_logic_vector_32 ;  -- := x"00000000"
    signal mult7_reg1 : std_logic_vector_32 ;    signal add5_out_add7_in : std_logic_vector_32 ;  -- := x"00000000"
    signal mult7_reg2 : std_logic_vector_32 ;    signal add6_out_add7_in : std_logic_vector_32 ;  -- := x"00000000"
    signal add7_out : std_logic_vector_32;
    signal mult8_reg1 : std_logic_vector_32 := x"00000000";    
    signal mult8_reg2 : std_logic_vector_32 := x"00000000";  --  signal add6_out : std_logic_vector_32;
    -- we will initiate all the values to "00000000" b/z we are using this chain also for 
    -- getting <r,p> and <r, Ap> & <p, Ap>  

    -- signals for add_sub units
    signal add_sub_control_for_add_sub0 : std_logic;
    signal add_sub_control_for_add_sub1 : std_logic;
    signal add_sub_control_for_add_sub2 : std_logic;
    signal add_sub_control_for_add_sub3 : std_logic;
    signal add_sub_control_for_add_sub4 : std_logic;
    signal add_sub_control_for_add_sub5 : std_logic;
    signal add_sub_control_for_add_sub6 : std_logic;
    signal add_sub0_reg1, add_sub0_reg2 : std_logic_vector_32;
    signal add_sub1_reg1, add_sub1_reg2 : std_logic_vector_32;
    signal add_sub2_reg1, add_sub2_reg2 : std_logic_vector_32;
    signal add_sub3_reg1, add_sub3_reg2 : std_logic_vector_32;
    signal add_sub4_reg1, add_sub4_reg2 : std_logic_vector_32;
    signal add_sub5_reg1, add_sub5_reg2 : std_logic_vector_32;
    signal add_sub6_reg1, add_sub6_reg2 : std_logic_vector_32;
    signal add_sub0_out : std_logic_vector_32;
    signal add_sub1_out : std_logic_vector_32;
    signal add_sub2_out : std_logic_vector_32;
    signal add_sub3_out : std_logic_vector_32;
    signal add_sub4_out : std_logic_vector_32;
    signal add_sub5_out : std_logic_vector_32;
    signal add_sub6_out : std_logic_vector_32;
    -- signals for division unit
    signal div1_reg1, div1_reg2, div1_out : std_logic_vector_32;
    -- signals for mult_for_alpha_and_beta units
    signal mult_for_alpha_and_beta_00_reg1 : std_logic_vector_32;
    signal mult_for_alpha_and_beta_01_reg1 : std_logic_vector_32;
    signal mult_for_alpha_and_beta_02_reg1 : std_logic_vector_32;
    signal mult_for_alpha_and_beta_03_reg1 : std_logic_vector_32;
    signal mult_for_alpha_and_beta_04_reg1 : std_logic_vector_32;
    signal mult_for_alpha_and_beta_05_reg1 : std_logic_vector_32;
    signal mult_for_alpha_and_beta_06_reg1 : std_logic_vector_32;
    signal mult_for_alpha_and_beta_00_reg2 : std_logic_vector_32;
    signal mult_for_alpha_and_beta_01_reg2 : std_logic_vector_32;
    signal mult_for_alpha_and_beta_02_reg2 : std_logic_vector_32;
    signal mult_for_alpha_and_beta_03_reg2 : std_logic_vector_32;
    signal mult_for_alpha_and_beta_04_reg2 : std_logic_vector_32;
    signal mult_for_alpha_and_beta_05_reg2 : std_logic_vector_32;
    signal mult_for_alpha_and_beta_06_reg2 : std_logic_vector_32;
    signal mult_for_alpha_and_beta_00_out  : std_logic_vector_32;
    signal mult_for_alpha_and_beta_01_out  : std_logic_vector_32;
    signal mult_for_alpha_and_beta_02_out  : std_logic_vector_32;
    signal mult_for_alpha_and_beta_03_out  : std_logic_vector_32;
    signal mult_for_alpha_and_beta_04_out  : std_logic_vector_32;
    signal mult_for_alpha_and_beta_05_out  : std_logic_vector_32;
    signal mult_for_alpha_and_beta_06_out  : std_logic_vector_32;
    -- signals of max_finder units 
    signal max_finder_input0 : std_logic_vector_32;
    signal max_finder_input1 : std_logic_vector_32;
    signal max_finder_input2 : std_logic_vector_32;
    signal max_finder_input3 : std_logic_vector_32;
    signal max_finder_input4 : std_logic_vector_32;
    signal max_finder_input5 : std_logic_vector_32;
    signal max_finder_input6 : std_logic_vector_32;
	signal max_finder_output : std_logic_vector_32;
    -- signals for abs units
    signal fp_abs0_reg, fp_abs0_out : std_logic_vector_32;
    signal fp_abs1_reg, fp_abs1_out : std_logic_vector_32;
    signal fp_abs2_reg, fp_abs2_out : std_logic_vector_32;
    signal fp_abs3_reg, fp_abs3_out : std_logic_vector_32;
    signal fp_abs4_reg, fp_abs4_out : std_logic_vector_32;
    signal fp_abs5_reg, fp_abs5_out : std_logic_vector_32;
    signal fp_abs6_reg, fp_abs6_out : std_logic_vector_32;

    --- others signals 
    signal alpha_num_arg1 : std_logic_vector_32;
    signal alpha_num_arg2 : std_logic_vector_32;
    signal alpha_dem_arg1 : std_logic_vector_32;
    signal alpha_dem_arg2 : std_logic_vector_32;
    signal alpha_num , alpha_dem :std_logic_vector_32;
    signal alpha : std_logic_vector_32;
    signal alpha_mult_Ap, alpha_mult_p : dim1; --std_logic_vector_32;
    signal beta_num_arg1, beta_num_arg2 : std_logic_vector_32;
    signal beta_num : std_logic_vector_32;
    signal beta : std_logic_vector_32;
    signal beta_mult_p : dim1; --std_logic_vector_32;
    signal r_minus_rold : dim1; 
    signal abs_r_minus_rold : dim1;
    signal max_abs_r_minus_rold : std_logic_vector_32;


    signal tol : std_logic_vector_32 := x"358637bd";
    signal comp1, comp2 : std_logic_vector ( 7 downto 0);

begin 

    mult1 : fp_mult port map (aclr => '0', dataa => mult1_reg1, datab => mult1_reg2, clock => clk, result => mult1_out_add1_in);
    mult2 : fp_mult port map (aclr => '0', dataa => mult2_reg1, datab => mult2_reg2, clock => clk, result => mult2_out_add1_in);
    mult3 : fp_mult port map (aclr => '0', dataa => mult3_reg1, datab => mult3_reg2, clock => clk, result => mult3_out_add2_in);
    mult4 : fp_mult port map (aclr => '0', dataa => mult4_reg1, datab => mult4_reg2, clock => clk, result => mult4_out_add2_in);
    mult5 : fp_mult port map (aclr => '0', dataa => mult5_reg1, datab => mult5_reg2, clock => clk, result => mult5_out_add3_in);
    mult6 : fp_mult port map (aclr => '0', dataa => mult6_reg1, datab => mult6_reg2, clock => clk, result => mult6_out_add3_in);
    mult7 : fp_mult port map (aclr => '0', dataa => mult7_reg1, datab => mult7_reg2, clock => clk, result => mult7_out_add4_in);
    mult8 : fp_mult port map (aclr => '0', dataa => mult8_reg1, datab => mult8_reg2, clock => clk, result => mult8_out_add4_in);

    add1 : fp_add port map (aclr => '0', dataa => mult1_out_add1_in, datab => mult2_out_add1_in, clock => clk, result => add1_out_add5_in);
    add2 : fp_add port map (aclr => '0', dataa => mult3_out_add2_in, datab => mult4_out_add2_in, clock => clk, result => add2_out_add5_in);
    add3 : fp_add port map (aclr => '0', dataa => mult5_out_add3_in, datab => mult6_out_add3_in, clock => clk, result => add3_out_add6_in);
    add4 : fp_add port map (aclr => '0', dataa => mult7_out_add4_in, datab => mult8_out_add4_in, clock => clk, result => add4_out_add6_in);
    add5 : fp_add port map (aclr => '0', dataa => add1_out_add5_in, datab => add2_out_add5_in,   clock => clk, result => add5_out_add7_in);
    add6 : fp_add port map (aclr => '0', dataa => add3_out_add6_in, datab => add4_out_add6_in,   clock => clk, result => add6_out_add7_in);
    add7 : fp_add port map (aclr => '0', dataa => add5_out_add7_in, datab => add6_out_add7_in,   clock => clk, result => add7_out);

    add_sub0 : fp_add_and_sub port map (aclr => '0', add_sub => add_sub_control_for_add_sub0, dataa => add_sub0_reg1, datab => add_sub0_reg2, clock => clk, result => add_sub0_out); 
    add_sub1 : fp_add_and_sub port map (aclr => '0', add_sub => add_sub_control_for_add_sub1, dataa => add_sub1_reg1, datab => add_sub1_reg2, clock => clk, result => add_sub1_out); 
    add_sub2 : fp_add_and_sub port map (aclr => '0', add_sub => add_sub_control_for_add_sub2, dataa => add_sub2_reg1, datab => add_sub2_reg2, clock => clk, result => add_sub2_out); 
    add_sub3 : fp_add_and_sub port map (aclr => '0', add_sub => add_sub_control_for_add_sub3, dataa => add_sub3_reg1, datab => add_sub3_reg2, clock => clk, result => add_sub3_out); 
    add_sub4 : fp_add_and_sub port map (aclr => '0', add_sub => add_sub_control_for_add_sub4, dataa => add_sub4_reg1, datab => add_sub4_reg2, clock => clk, result => add_sub4_out); 
    add_sub5 : fp_add_and_sub port map (aclr => '0', add_sub => add_sub_control_for_add_sub5, dataa => add_sub5_reg1, datab => add_sub5_reg2, clock => clk, result => add_sub5_out); 
    add_sub6 : fp_add_and_sub port map (aclr => '0', add_sub => add_sub_control_for_add_sub6, dataa => add_sub6_reg1, datab => add_sub6_reg2, clock => clk, result => add_sub6_out); 

    div1 : fp_div port map (aclr => '0', dataa => div1_reg1, datab => div1_reg2, clock => clk, result => div1_out);  -- divisor used for calculate alpha & beta

    mult_for_alpha_and_beta_00 : fp_mult port map (aclr => '0', dataa => mult_for_alpha_and_beta_00_reg1, datab => mult_for_alpha_and_beta_00_reg2, clock => clk, result => mult_for_alpha_and_beta_00_out);
    mult_for_alpha_and_beta_01 : fp_mult port map (aclr => '0', dataa => mult_for_alpha_and_beta_01_reg1, datab => mult_for_alpha_and_beta_01_reg2, clock => clk, result => mult_for_alpha_and_beta_01_out);
    mult_for_alpha_and_beta_02 : fp_mult port map (aclr => '0', dataa => mult_for_alpha_and_beta_02_reg1, datab => mult_for_alpha_and_beta_02_reg2, clock => clk, result => mult_for_alpha_and_beta_02_out);
    mult_for_alpha_and_beta_03 : fp_mult port map (aclr => '0', dataa => mult_for_alpha_and_beta_03_reg1, datab => mult_for_alpha_and_beta_03_reg2, clock => clk, result => mult_for_alpha_and_beta_03_out);
    mult_for_alpha_and_beta_04 : fp_mult port map (aclr => '0', dataa => mult_for_alpha_and_beta_04_reg1, datab => mult_for_alpha_and_beta_04_reg2, clock => clk, result => mult_for_alpha_and_beta_04_out);
    mult_for_alpha_and_beta_05 : fp_mult port map (aclr => '0', dataa => mult_for_alpha_and_beta_05_reg1, datab => mult_for_alpha_and_beta_05_reg2, clock => clk, result => mult_for_alpha_and_beta_05_out);
    mult_for_alpha_and_beta_06 : fp_mult port map (aclr => '0', dataa => mult_for_alpha_and_beta_06_reg1, datab => mult_for_alpha_and_beta_06_reg2, clock => clk, result => mult_for_alpha_and_beta_06_out);

    counter_component_01 : counter port map (clk => clk, reset => reset_counter, count => count_counter);

    max_finder_component_01 : max_finder port map (max_finder_input0 => max_finder_input0,
                                                   max_finder_input1 => max_finder_input1, 
                                                   max_finder_input2 => max_finder_input2,
                                                   max_finder_input3 => max_finder_input3,
                                                   max_finder_input4 => max_finder_input4,
                                                   max_finder_input5 => max_finder_input5, 
                                                   max_finder_input6 => max_finder_input6,
                                                   max_finder_output => max_finder_output);


   fp_abs0 : fp_abs port map( clock => clk, data => fp_abs0_reg, result => fp_abs0_out);
   fp_abs1 : fp_abs port map( clock => clk, data => fp_abs1_reg, result => fp_abs1_out);
   fp_abs2 : fp_abs port map( clock => clk, data => fp_abs2_reg, result => fp_abs2_out);
   fp_abs3 : fp_abs port map( clock => clk, data => fp_abs3_reg, result => fp_abs3_out);
   fp_abs4 : fp_abs port map( clock => clk, data => fp_abs4_reg, result => fp_abs4_out);
   fp_abs5 : fp_abs port map( clock => clk, data => fp_abs5_reg, result => fp_abs5_out);
   fp_abs6 : fp_abs port map( clock => clk, data => fp_abs6_reg, result => fp_abs6_out);

   P_top_01:  process (clk)
       variable out_data : std_logic_vector_32;
      -- variable int_address : integer := to_integer(unsigned(address));
      -- variable int_mcg_index : integer := to_integer(unsigned(mcg_index);
   begin 
        if (rising_edge(clk)) then 
            if (read = '1') then 
               -- case int_address is 
					case address is 
                   --when 0 => out_data := control_and_status_reg;
                   --when 1 => out_data := A(0)(0);  when 11 => out_data := A(1)(3);   when 21 => out_data := A(2)(6);   when 31 => out_data := A(4)(2);
                   --when 2 => out_data := A(0)(1);  when 12 => out_data := A(1)(4);   when 22 => out_data := A(3)(0);   when 32 => out_data := A(4)(3);
                   --when 3 => out_data := A(0)(2);  when 13 => out_data := A(1)(5);   when 23 => out_data := A(3)(1);   when 33 => out_data := A(4)(4);
                   --when 4 => out_data := A(0)(3);  when 14 => out_data := A(1)(6);   when 24 => out_data := A(3)(2);   when 34 => out_data := A(4)(5);
                   --when 5 => out_data := A(0)(4);  when 15 => out_data := A(2)(0);   when 25 => out_data := A(3)(3);   when 35 => out_data := A(4)(6);
                   --when 6 => out_data := A(0)(5);  when 16 => out_data := A(2)(1);   when 26 => out_data := A(3)(4);   when 36 => out_data := A(5)(0);
                   --when 7 => out_data := A(0)(6);  when 17 => out_data := A(2)(2);   when 27 => out_data := A(3)(5);   when 37 => out_data := A(5)(1);
                   --when 8 => out_data := A(1)(0);  when 18 => out_data := A(2)(3);   when 28 => out_data := A(3)(6);   when 38 => out_data := A(5)(2);
                   --when 9 => out_data := A(1)(1);  when 19 => out_data := A(2)(4);   when 29 => out_data := A(4)(0);   when 39 => out_data := A(5)(3);
                   --when 10 => out_data := A(1)(2); when 20 => out_data := A(2)(5);   when 30 => out_data := A(4)(1);   when 40 => out_data := A(5)(4);
                   --
                   --when 41 => out_data := A(5)(5);   when 51 => out_data := b(1);          when 61 => out_data := x(3);
                   --when 42 => out_data := A(5)(6);   when 52 => out_data := b(2);          when 62 => out_data := x(4);
                   --when 43 => out_data := A(6)(0);   when 53 => out_data := b(3);          when 63 => out_data := x(5);
                   --when 44 => out_data := A(6)(1);   when 54 => out_data := b(4);          when 64 => out_data := x(6);
                   --when 45 => out_data := A(6)(2);   when 55 => out_data := b(5);         
                   --when 46 => out_data := A(6)(3);   when 56 => out_data := b(6);
                   --when 47 => out_data := A(6)(4);   when 57 => out_data := mcg_index;
                   --when 48 => out_data := A(6)(5);   when 58 => out_data := x(0);
                   --when 49 => out_data := A(6)(6);   when 59 => out_data := x(1);
                   --when 50 => out_data := b(0);      when 60 => out_data := x(2);
                     when "0000000"  => out_data := control_and_status_reg;
                     when "0000001"  => out_data :=  A(0)(0) ;
                     when "0000010"  => out_data :=  A(0)(1) ;
                     when "0000011"  => out_data :=  A(0)(2) ;
                     when "0000100"  => out_data :=  A(0)(3) ;
                     when "0000101"  => out_data :=  A(0)(4) ;
                     when "0000110"  => out_data :=  A(0)(5) ;
                     when "0000111"  => out_data :=  A(0)(6) ;
                     when "0001000"  => out_data :=  A(1)(0) ;
                     when "0001001"  => out_data :=  A(1)(1) ;
                     when "0001010"  => out_data :=  A(1)(2) ;
                     when "0001011"  => out_data :=  A(1)(3) ;
                     when "0001100"  => out_data :=  A(1)(4) ;
                     when "0001101"  => out_data :=  A(1)(5) ;
                     when "0001110"  => out_data :=  A(1)(6) ;
                     when "0001111"  => out_data :=  A(2)(0) ;
                     when "0010000"  => out_data :=  A(2)(1) ;
                     when "0010001"  => out_data :=  A(2)(2) ;
                     when "0010010"  => out_data :=  A(2)(3) ;
                     when "0010011"  => out_data :=  A(2)(4) ;
                     when "0010100"  => out_data :=  A(2)(5) ;  
                     when "0010101"  => out_data :=  A(2)(6) ;
                     when "0010110"  => out_data :=  A(3)(0) ;
                     when "0010111"  => out_data :=  A(3)(1) ;
                     when "0011000"  => out_data :=  A(3)(2) ;
                     when "0011001"  => out_data :=  A(3)(3) ;
                     when "0011010"  => out_data :=  A(3)(4) ;
                     when "0011011"  => out_data :=  A(3)(5) ;
                     when "0011100"  => out_data :=  A(3)(6) ;
                     when "0011101"  => out_data :=  A(4)(0) ;
                     when "0011110"  => out_data :=  A(4)(1) ;
                     when "0011111"  => out_data :=  A(4)(2) ;
                     when "0100000"  => out_data :=  A(4)(3) ;  
                     when "0100001"  => out_data :=  A(4)(4) ;  
                     when "0100010"  => out_data :=  A(4)(5) ;  
                     when "0100011"  => out_data :=  A(4)(6) ;  
                     when "0100100"  => out_data :=  A(5)(0) ;  
                     when "0100101"  => out_data :=  A(5)(1) ;  
                     when "0100110"  => out_data :=  A(5)(2) ;  
                     when "0100111"  => out_data :=  A(5)(3) ;
                     when "0101000"  => out_data :=  A(5)(4) ;  
                     when "0101001"  => out_data :=  A(5)(5) ;
                     when "0101010"  => out_data :=  A(5)(6) ;
                     when "0101011"  => out_data :=  A(6)(0) ;
                     when "0101100"  => out_data :=  A(6)(1) ;
                     when "0101101"  => out_data :=  A(6)(2) ;
                     when "0101110"  => out_data :=  A(6)(3) ;
                     when "0101111"  => out_data :=  A(6)(4) ;
                     when "0110000"  => out_data :=  A(6)(5) ;
                     when "0110001"  => out_data :=  A(6)(6) ;
                     when "0110010"  => out_data :=  b(0) ; 
                     when "0110011"  => out_data :=  b(1) ;
                     when "0110100"  => out_data :=  b(2) ;
                     when "0110101"  => out_data :=  b(3) ;
                     when "0110110"  => out_data :=  b(4) ;
                     when "0110111"  => out_data :=  b(5) ;
                     when "0111000"  => out_data :=  b(6) ;
                     when "0111001"  => out_data := mcg_index ;
                     when "0111010"  => out_data := x(0);
                     when "0111011"  => out_data := x(1); 
                     when "0111100"  => out_data := x(2);
                     when "0111101"  => out_data := x(3);
                     when "0111110"  => out_data := x(4);
                     when "0111111"  => out_data := x(5);
                     when "1000000"  => out_data := x(6);
                    when others => null;
                end case ;
                readdata <= out_data;
            elsif ( write = '1') then 
               -- case int_address is 
					case address is 
                    when "0000000" => 
                        if ( writedata = x"00000001") then 
                            state <= stSTART;
                        end if;
                        control_and_status_reg <= writedata;
                   --when  1 =>  A(0)(0) <= writedata;   when 11 =>  A(1)(3) <= writedata;   when 21 =>  A(2)(6) <= writedata;   when 31 =>  A(4)(2) <= writedata;
                   --when  2 =>  A(0)(1) <= writedata;   when 12 =>  A(1)(4) <= writedata;   when 22 =>  A(3)(0) <= writedata;   when 32 =>  A(4)(3) <= writedata;
                   --when  3 =>  A(0)(2) <= writedata;   when 13 =>  A(1)(5) <= writedata;   when 23 =>  A(3)(1) <= writedata;   when 33 =>  A(4)(4) <= writedata;
                   --when  4 =>  A(0)(3) <= writedata;   when 14 =>  A(1)(6) <= writedata;   when 24 =>  A(3)(2) <= writedata;   when 34 =>  A(4)(5) <= writedata;
                   --when  5 =>  A(0)(4) <= writedata;   when 15 =>  A(2)(0) <= writedata;   when 25 =>  A(3)(3) <= writedata;   when 35 =>  A(4)(6) <= writedata;
                   --when  6 =>  A(0)(5) <= writedata;   when 16 =>  A(2)(1) <= writedata;   when 26 =>  A(3)(4) <= writedata;   when 36 =>  A(5)(0) <= writedata;
                   --when  7 =>  A(0)(6) <= writedata;   when 17 =>  A(2)(2) <= writedata;   when 27 =>  A(3)(5) <= writedata;   when 37 =>  A(5)(1) <= writedata;
                   --when  8 =>  A(1)(0) <= writedata;   when 18 =>  A(2)(3) <= writedata;   when 28 =>  A(3)(6) <= writedata;   when 38 =>  A(5)(2) <= writedata;
                   --when  9 =>  A(1)(1) <= writedata;   when 19 =>  A(2)(4) <= writedata;   when 29 =>  A(4)(0) <= writedata;   when 39 =>  A(5)(3) <= writedata;
                   --when 10 =>  A(1)(2) <= writedata;   when 20 =>  A(2)(5) <= writedata;   when 30 =>  A(4)(1) <= writedata;   when 40 =>  A(5)(4) <= writedata;
                   --
                   --when 41 =>  A(5)(5) <= writedata;   when 50 =>  b(0) <= writedata;
                   --when 42 =>  A(5)(6) <= writedata;   when 51 =>  b(1) <= writedata;
                   --when 43 =>  A(6)(0) <= writedata;   when 52 =>  b(2) <= writedata;
                   --when 44 =>  A(6)(1) <= writedata;   when 53 =>  b(3) <= writedata;
                   --when 45 =>  A(6)(2) <= writedata;   when 54 =>  b(4) <= writedata;
                   --when 46 =>  A(6)(3) <= writedata;   when 55 =>  b(5) <= writedata;
                   --when 47 =>  A(6)(4) <= writedata;   when 56 =>  b(6) <= writedata;
                   --when 48 =>  A(6)(5) <= writedata;   when 57 =>  mcg_index <= writedata;
                   --when 49 =>  A(6)(6) <= writedata;   
                   --when others => null;                    
                     --when "0000000" 
                     when "0000001"  =>  A(0)(0) <= writedata;
                     when "0000010"  =>  A(0)(1) <= writedata;
                     when "0000011"  =>  A(0)(2) <= writedata;
                     when "0000100"  =>  A(0)(3) <= writedata;
                     when "0000101"  =>  A(0)(4) <= writedata;
                     when "0000110"  =>  A(0)(5) <= writedata;
                     when "0000111"  =>  A(0)(6) <= writedata;
                     when "0001000"  =>  A(1)(0) <= writedata;
                     when "0001001"  =>  A(1)(1) <= writedata;
                     when "0001010"  =>  A(1)(2) <= writedata;
                     when "0001011"  =>  A(1)(3) <= writedata;
                     when "0001100"  =>  A(1)(4) <= writedata;
                     when "0001101"  =>  A(1)(5) <= writedata;
                     when "0001110"  =>  A(1)(6) <= writedata;
                     when "0001111"  =>  A(2)(0) <= writedata;
                     when "0010000"  =>  A(2)(1) <= writedata;
                     when "0010001"  =>  A(2)(2) <= writedata;
                     when "0010010"  =>  A(2)(3) <= writedata;
                     when "0010011"  =>  A(2)(4) <= writedata;
                     when "0010100"  =>  A(2)(5) <= writedata;  
                     when "0010101"  =>  A(2)(6) <= writedata;
                     when "0010110"  =>  A(3)(0) <= writedata;
                     when "0010111"  =>  A(3)(1) <= writedata;
                     when "0011000"  =>  A(3)(2) <= writedata;
                     when "0011001"  =>  A(3)(3) <= writedata;
                     when "0011010"  =>  A(3)(4) <= writedata;
                     when "0011011"  =>  A(3)(5) <= writedata;
                     when "0011100"  =>  A(3)(6) <= writedata;
                     when "0011101"  =>  A(4)(0) <= writedata;
                     when "0011110"  =>  A(4)(1) <= writedata;
                     when "0011111"  =>  A(4)(2) <= writedata;
                     when "0100000"  =>  A(4)(3) <= writedata;  
                     when "0100001"  =>  A(4)(4) <= writedata;  
                     when "0100010"  =>  A(4)(5) <= writedata;  
                     when "0100011"  =>  A(4)(6) <= writedata;  
                     when "0100100"  =>  A(5)(0) <= writedata;  
                     when "0100101"  =>  A(5)(1) <= writedata;  
                     when "0100110"  =>  A(5)(2) <= writedata;  
                     when "0100111"  =>  A(5)(3) <= writedata;
                     when "0101000"  =>  A(5)(4) <= writedata;  
                     when "0101001"  =>  A(5)(5) <= writedata;
                     when "0101010"  =>  A(5)(6) <= writedata;
                     when "0101011"  =>  A(6)(0) <= writedata;
                     when "0101100"  =>  A(6)(1) <= writedata;
                     when "0101101"  =>  A(6)(2) <= writedata;
                     when "0101110"  =>  A(6)(3) <= writedata;
                     when "0101111"  =>  A(6)(4) <= writedata;
                     when "0110000"  =>  A(6)(5) <= writedata;
                     when "0110001"  =>  A(6)(6) <= writedata;
                     when "0110010"  =>  b(0) <= writedata; 
                     when "0110011"  =>  b(1) <= writedata;
                     when "0110100"  =>  b(2) <= writedata;
                     when "0110101"  =>  b(3) <= writedata;
                     when "0110110"  =>  b(4) <= writedata;
                     when "0110111"  =>  b(5) <= writedata;
                     when "0111000"  =>  b(6) <= writedata;
                     when "0111001"  => mcg_index <= writedata;
                     when others => null;
                end case ;
            else 
                case state is 
                    when stSTART => 
                        control_and_status_reg <= x"00000003";
                        r <= b;
                        p <= b;
                        state <= stPROC_AP_ROW1;
                        reset_counter <= '1';
-- ===============================================================================================
  -- Calculation of A * p  starts 
-- ===============================================================================================
                    when stPROC_AP_ROW1 => 
                        mult1_reg1 <= A(0)(0); mult1_reg2 <= p(0);
                        mult2_reg1 <= A(0)(1); mult2_reg2 <= p(1);
                        mult3_reg1 <= A(0)(2); mult3_reg2 <= p(2);
                        mult4_reg1 <= A(0)(3); mult4_reg2 <= p(3);
                        mult5_reg1 <= A(0)(4); mult5_reg2 <= p(4);
                        mult6_reg1 <= A(0)(5); mult6_reg2 <= p(5);
                        mult7_reg1 <= A(0)(6); mult7_reg2 <= p(6);
                        reset_counter <= '0';
			--	    state <= stTEMP7;
			--	when stTEMP7 => 
                        state <= stPROC_AP_ROW2;
                    when stPROC_AP_ROW2 => 
                        mult1_reg1 <= A(1)(0); mult1_reg2 <= p(0);
                        mult2_reg1 <= A(1)(1); mult2_reg2 <= p(1);
                        mult3_reg1 <= A(1)(2); mult3_reg2 <= p(2);
                        mult4_reg1 <= A(1)(3); mult4_reg2 <= p(3);
                        mult5_reg1 <= A(1)(4); mult5_reg2 <= p(4);
                        mult6_reg1 <= A(1)(5); mult6_reg2 <= p(5);
                        mult7_reg1 <= A(1)(6); mult7_reg2 <= p(6);
			--	    state <= stTEMP8;
			--	when stTEMP8 => 
                        state <= stPROC_AP_ROW3;
                    when stPROC_AP_ROW3 => 
                        mult1_reg1 <= A(2)(0); mult1_reg2 <= p(0);
                        mult2_reg1 <= A(2)(1); mult2_reg2 <= p(1);
                        mult3_reg1 <= A(2)(2); mult3_reg2 <= p(2);
                        mult4_reg1 <= A(2)(3); mult4_reg2 <= p(3);
                        mult5_reg1 <= A(2)(4); mult5_reg2 <= p(4);
                        mult6_reg1 <= A(2)(5); mult6_reg2 <= p(5);
                        mult7_reg1 <= A(2)(6); mult7_reg2 <= p(6);
			--	    state <= stTEMP9;
			--	when stTEMP9 => 
                        state <= stPROC_AP_ROW4;

                    when stPROC_AP_ROW4 => 
                        mult1_reg1 <= A(3)(0); mult1_reg2 <= p(0);
                        mult2_reg1 <= A(3)(1); mult2_reg2 <= p(1);
                        mult3_reg1 <= A(3)(2); mult3_reg2 <= p(2);
                        mult4_reg1 <= A(3)(3); mult4_reg2 <= p(3);
                        mult5_reg1 <= A(3)(4); mult5_reg2 <= p(4);
                        mult6_reg1 <= A(3)(5); mult6_reg2 <= p(5);
                        mult7_reg1 <= A(3)(6); mult7_reg2 <= p(6);
			--	    state <= stTEMP10;
			--	when stTEMP10 => 
                        state <= stPROC_AP_ROW5;
                    when stPROC_AP_ROW5 => 
                        mult1_reg1 <= A(4)(0); mult1_reg2 <= p(0);
                        mult2_reg1 <= A(4)(1); mult2_reg2 <= p(1);
                        mult3_reg1 <= A(4)(2); mult3_reg2 <= p(2);
                        mult4_reg1 <= A(4)(3); mult4_reg2 <= p(3);
                        mult5_reg1 <= A(4)(4); mult5_reg2 <= p(4);
                        mult6_reg1 <= A(4)(5); mult6_reg2 <= p(5);
                        mult7_reg1 <= A(4)(6); mult7_reg2 <= p(6);
			--	    state <= stTEMP11;
			--	when stTEMP11 => 
                        state <= stPROC_AP_ROW6;
                    when stPROC_AP_ROW6 => 
                        mult1_reg1 <= A(5)(0);mult1_reg2 <= p(0);
                        mult2_reg1 <= A(5)(1);mult2_reg2 <= p(1);
                        mult3_reg1 <= A(5)(2);mult3_reg2 <= p(2);
                        mult4_reg1 <= A(5)(3);mult4_reg2 <= p(3);
                        mult5_reg1 <= A(5)(4);mult5_reg2 <= p(4);
                        mult6_reg1 <= A(5)(5);mult6_reg2 <= p(5);
                        mult7_reg1 <= A(5)(6);mult7_reg2 <= p(6);
			--	    state <= stTEMP12;
			--	when stTEMP12 => 
                        state <= stPROC_AP_ROW7;
                    when stPROC_AP_ROW7 => 
                        mult1_reg1 <= A(6)(0); mult1_reg2 <= p(0);
                        mult2_reg1 <= A(6)(1); mult2_reg2 <= p(1);
                        mult3_reg1 <= A(6)(2); mult3_reg2 <= p(2);
                        mult4_reg1 <= A(6)(3); mult4_reg2 <= p(3);
                        mult5_reg1 <= A(6)(4); mult5_reg2 <= p(4);
                        mult6_reg1 <= A(6)(5); mult6_reg2 <= p(5);
                        mult7_reg1 <= A(6)(6); mult7_reg2 <= p(6);
                       -- if (count_counter = "11010") then -- TODO
							if (count_counter >= "11001") then -- TODO
                            reset_counter <= '1';
                            state <= stPROC_AP_RESULT_APxb_0;
                        end if ;
-- ===============================================================================================
-- read Ap(0) from multiplier and adder chain 
-- ===============================================================================================
                    when stPROC_AP_RESULT_APxb_0 => 
                        Ap(0) <=  add7_out;
								--state <= stTEMP7;
						  --when stTEMP7 => 
						      state <= stPROC_AP_RESULT_APxb_1;
                    when stPROC_AP_RESULT_APxb_1 => 
                        Ap(1) <= add7_out;
                        state <= stPROC_AP_RESULT_APxb_2;
                    when stPROC_AP_RESULT_APxb_2 => 
                        Ap(2) <= add7_out;
                        state <= stPROC_AP_RESULT_APxb_3;
                    when stPROC_AP_RESULT_APxb_3 => 
                        Ap(3) <= add7_out;
                        --state <= stTEMP7;
                   -- when stTEMP7 =>
                        state <= stPROC_AP_RESULT_APxb_4;
                    when stPROC_AP_RESULT_APxb_4 => 
                        Ap(4) <= add7_out;
                        state <= stPROC_AP_RESULT_APxb_5;
                    when stPROC_AP_RESULT_APxb_5 => 
                        Ap(5) <= add7_out;
                        state <= stPROC_AP_RESULT_APxb_6;
                    when stPROC_AP_RESULT_APxb_6 => 
                        Ap(6) <= add7_out;
                        state <= stCalculate_alpha_s1; 
-- ===============================================================================================
-- calculate A*P ends here 
-- r0*p0 + r1*p1 + r2*p2(alpha_num_arg1) entered to adder_and_multiplier chain 
-- ===============================================================================================
                        
                    when stCalculate_alpha_s1 =>  --TODO : how we can integrate with mcg_index
                        mult1_reg1 <= r(0);         mult1_reg2 <= p(0);
                        mult2_reg1 <= r(1);         mult2_reg2 <= p(1);
                        mult3_reg1 <= r(2);         mult3_reg2 <= p(2);
                        mult4_reg1 <= x"00000000";  mult4_reg2 <= x"00000000";
                        mult5_reg1 <= x"00000000";  mult5_reg2 <= x"00000000";
                        mult6_reg1 <= x"00000000";  mult6_reg2 <= x"00000000";
                        mult7_reg1 <= x"00000000";  mult7_reg2 <= x"00000000";
                        
                        reset_counter <= '0';
                        state <= stCalculate_alpha_s2;
-- ===============================================================================================
-- r3*p3 + r4*p4 + r5*p5 + r6*p6 (alpha_num_arg2) entered to adder_and_multiplier chain 
-- ===============================================================================================
                    when stCalculate_alpha_s2 => 
                        mult1_reg1 <= r(3);         mult1_reg2 <= p(3);
                        mult2_reg1 <= r(4);         mult2_reg2 <= p(4);
                        mult3_reg1 <= r(5);         mult3_reg2 <= p(5);
                        mult4_reg1 <= r(6);         mult4_reg2 <= p(6);
                        mult5_reg1 <= x"00000000";  mult5_reg2 <= x"00000000";
                        mult6_reg1 <= x"00000000";  mult6_reg2 <= x"00000000";
                        mult7_reg1 <= x"00000000";  mult7_reg2 <= x"00000000";
                        state <= stCalculate_alpha_s3;
-- ===============================================================================================
-- p0 * Ap0 + p1 *Ap1 + p2 * Ap2 (alpha_dem_arg1) entered into adder_and_multiplier chain 
-- ===============================================================================================
                    when stCalculate_alpha_s3 =>
                        mult1_reg1 <= p(0);         mult1_reg2 <= Ap(0);
                        mult2_reg1 <= p(1);         mult2_reg2 <= Ap(1);
                        mult3_reg1 <= p(2);         mult3_reg2 <= Ap(2);
                        mult4_reg1 <= x"00000000";  mult4_reg2 <= x"00000000";
                        mult5_reg1 <= x"00000000";  mult5_reg2 <= x"00000000";
                        mult6_reg1 <= x"00000000";  mult6_reg2 <= x"00000000";
                        mult7_reg1 <= x"00000000";  mult7_reg2 <= x"00000000";
                        state <= stCalculate_alpha_s4;
-- ===============================================================================================
-- p3 * Ap3 + p4 *Ap4 + p5 * Ap5 + p6 * Ap6 (alpha_dem_arg1) entered into adder_and_multiplier chain 
-- ===============================================================================================
                    when stCalculate_alpha_s4 => 
                        mult1_reg1 <= p(3);         mult1_reg2 <= Ap(3);
                        mult2_reg1 <= p(4);         mult2_reg2 <= Ap(4);
                        mult3_reg1 <= p(5);         mult3_reg2 <= Ap(5);
                        mult4_reg1 <= p(6);         mult4_reg2 <= Ap(6);
                        mult5_reg1 <= x"00000000";  mult5_reg2 <= x"00000000";
                        mult6_reg1 <= x"00000000";  mult6_reg2 <= x"00000000";
                        mult7_reg1 <= x"00000000";  mult7_reg2 <= x"00000000";
                        if (count_counter >= "11010") then -- todo after 26 clock cycle our result comes
                            reset_counter <= '1';
                            alpha_num_arg1 <= add7_out;
                            state <= stCalculate_alpha_num_arg2_read;
                        --    state <= stCalculate_alpha_num_arg1_read;
                        end if ;
-- ===============================================================================================
-- reading of alpha_num_arg1, alpha_num_arg2, alpha_dem_arg1, alpha_dem_arg2 starts here
-- ===============================================================================================
              ---      when stCalculate_alpha_num_arg1_read =>
              --          alpha_num_arg1 <= add7_out;
              --          state <= stCalculate_alpha_num_arg2_read;
                    when stCalculate_alpha_num_arg2_read => 
                        alpha_num_arg2 <= add7_out;
                        state <= stCalculate_alpha_dem_arg1_read;
                    when stCalculate_alpha_dem_arg1_read =>
                        alpha_dem_arg1 <= add7_out;
                        state <= stCalculate_alpha_dem_arg2_read;
                    when stCalculate_alpha_dem_arg2_read => 
                        alpha_dem_arg2 <= add7_out;
-- ===============================================================================================
-- alpha_num_arg1 and alpha_num_arg2 is given to the add_sub1 unit 
-- ===============================================================================================
                        add_sub1_reg1 <= alpha_num_arg1;
                        add_sub1_reg2 <= alpha_num_arg2;
                        add_sub_control_for_add_sub1<= '0'; -- '0' is for substraction 
                        reset_counter <= '0';
                        state <= stCalculate_alpha_num_and_dem_s1;
-- ===============================================================================================
-- alpha_dem_arg1 and alpha_dem_arg2 is given to the add_sub1 unit 
-- ===============================================================================================
                    when stCalculate_alpha_num_and_dem_s1 => 
                        add_sub1_reg1 <= alpha_dem_arg1;
                        add_sub1_reg2 <= alpha_dem_arg2;
                        add_sub_control_for_add_sub1 <= '0';
                        if (count_counter = "00111") then  -- todo
                            reset_counter <= '1';
                            alpha_num <= add_sub1_out;
                            state <= stCalculate_alpha_num_and_dem_s3;
                   --         state <= stCalculate_alpha_num_and_dem_s2;
                        end if;
-- ===============================================================================================
-- reading alpha_num and alpha_dem from output of add_sub1_out 
-- ===============================================================================================
                 --   when stCalculate_alpha_num_and_dem_s2 => 
                 --       alpha_num <= add_sub1_out;
                 --       state <= stCalculate_alpha_num_and_dem_s3;
                    when stCalculate_alpha_num_and_dem_s3 => 
                        alpha_dem <= add_sub1_out;
                        state <= stCalculate_alpha_begin;
-- ===============================================================================================
-- alpha_num and alpha_dem is subjected to divider to calculate alpha 
-- ===============================================================================================
                    when stCalculate_alpha_begin => 
                        div1_reg1 <= alpha_num;
                        div1_reg2 <= alpha_dem;
                        reset_counter <= '0';
                        state <= stCalculate_alpha_end;
                    when stCalculate_alpha_end =>
                        if (count_counter = "00110") then  -- todo -- how much cycle a divider takes to give output ??
                            reset_counter <= '1';
                            alpha <= div1_out;
                            state <= st_alpha_mult_p_s1;
                            --state <= st_alpha_read;
                        end if;
-- ===============================================================================================
-- alpha reads out from div_out register
-- ===============================================================================================
                  --  when st_alpha_read => 
                  --      alpha <= div1_out;
                  --      state <= st_alpha_mult_p_s1;
                    when st_alpha_mult_p_s1 => 
-- ===============================================================================================
-- alpha and p is given to mult_for_alpha_and_beta_01 unit to calculate alpha * p --> todo : how to handle vectors here --> DONE
-- ===============================================================================================
                        mult_for_alpha_and_beta_00_reg1 <= alpha;
                        mult_for_alpha_and_beta_00_reg2 <= p(0);
                        mult_for_alpha_and_beta_01_reg1 <= alpha;
                        mult_for_alpha_and_beta_01_reg2 <= p(1);
                        mult_for_alpha_and_beta_02_reg1 <= alpha;
                        mult_for_alpha_and_beta_02_reg2 <= p(2);
                        mult_for_alpha_and_beta_03_reg1 <= alpha;
                        mult_for_alpha_and_beta_03_reg2 <= p(3);
                        mult_for_alpha_and_beta_04_reg1 <= alpha;
                        mult_for_alpha_and_beta_04_reg2 <= p(4);
                        mult_for_alpha_and_beta_05_reg1 <= alpha;
                        mult_for_alpha_and_beta_05_reg2 <= p(5);
                        mult_for_alpha_and_beta_06_reg1 <= alpha;
                        mult_for_alpha_and_beta_06_reg2 <= p(6);
                        reset_counter <= '0'; --TODO
                        state <= stTEMP1;
                    when stTEMP1 => 
                        if (count_counter = "00101") then  -- todo : after how many cycle after multipler is giving output
                            reset_counter <= '1';
 --                           state <= stCalculate_x_new;
                            state <= stREAD_alpha_mult_p;
                        end if ;
                    when stREAD_alpha_mult_p => 
                        alpha_mult_p(0) <= mult_for_alpha_and_beta_00_out;
                        alpha_mult_p(1) <= mult_for_alpha_and_beta_01_out;
                        alpha_mult_p(2) <= mult_for_alpha_and_beta_02_out;
                        alpha_mult_p(3) <= mult_for_alpha_and_beta_03_out;
                        alpha_mult_p(4) <= mult_for_alpha_and_beta_04_out;
                        alpha_mult_p(5) <= mult_for_alpha_and_beta_05_out;
                        alpha_mult_p(6) <= mult_for_alpha_and_beta_06_out;
                        state <= stCalculate_x_new;
-- ===============================================================================================
-- Calculate then x_new, which x = x + alpha * p; -- todo : what about vector
-- ===============================================================================================
                    when stCalculate_x_new => 
                        add_sub0_reg1 <= x(0);
                        add_sub0_reg2 <= alpha_mult_p(0);
                        add_sub_control_for_add_sub0 <= '1'; -- '1' is for adder
                        add_sub1_reg1 <= x(1);
                        add_sub1_reg2 <= alpha_mult_p(1);
                        add_sub_control_for_add_sub1 <= '1'; -- '1' is for adder
                        add_sub2_reg1 <= x(2);
                        add_sub2_reg2 <= alpha_mult_p(2);
                        add_sub_control_for_add_sub2 <= '1'; -- '1' is for adder
                        add_sub3_reg1 <= x(3);
                        add_sub3_reg2 <= alpha_mult_p(3);
                        add_sub_control_for_add_sub3 <= '1'; -- '1' is for adder
                        add_sub4_reg1 <= x(4);
                        add_sub4_reg2 <= alpha_mult_p(4);
                        add_sub_control_for_add_sub4 <= '1'; -- '1' is for adder
                        add_sub5_reg1 <= x(5);
                        add_sub5_reg2 <= alpha_mult_p(5);
                        add_sub_control_for_add_sub5 <= '1'; -- '1' is for adder
                        add_sub6_reg1 <= x(6);
                        add_sub6_reg2 <= alpha_mult_p(6);
                        add_sub_control_for_add_sub6 <= '1'; -- '1' is for adder
                        reset_counter <= '0'; 
                        state <= stTEMP2;
                    when stTEMP2 => 
                        if (count_counter = "00110") then  --TODO
                            reset_counter <= '1';
                            state <= st_alpha_mult_AP_s1 ;
                        end if;
-- ===============================================================================================
-- x_new -> here x, is read out from add_sub1_out register 
-- Also alpha and Ap is given to mult_for_alpha_and_beta_01 unit to calculate alpha * Ap 
-- ===============================================================================================
                    when st_alpha_mult_AP_s1 => 
                        x(0) <= add_sub0_out;
                        x(1) <= add_sub1_out;
                        x(2) <= add_sub2_out;
                        x(3) <= add_sub3_out;
                        x(4) <= add_sub4_out;
                        x(5) <= add_sub5_out;
                        x(6) <= add_sub6_out;
                        mult_for_alpha_and_beta_00_reg1 <= alpha;
                        mult_for_alpha_and_beta_00_reg2 <= Ap(0);
                        mult_for_alpha_and_beta_01_reg1 <= alpha;
                        mult_for_alpha_and_beta_01_reg2 <= Ap(1);
                        mult_for_alpha_and_beta_02_reg1 <= alpha;
                        mult_for_alpha_and_beta_02_reg2 <= Ap(2);
                        mult_for_alpha_and_beta_03_reg1 <= alpha;
                        mult_for_alpha_and_beta_03_reg2 <= Ap(3);
                        mult_for_alpha_and_beta_04_reg1 <= alpha;
                        mult_for_alpha_and_beta_04_reg2 <= Ap(4);
                        mult_for_alpha_and_beta_05_reg1 <= alpha;
                        mult_for_alpha_and_beta_05_reg2 <= Ap(5);
                        mult_for_alpha_and_beta_06_reg1 <= alpha;
                        mult_for_alpha_and_beta_06_reg2 <= Ap(6);
                        reset_counter <= '0';
                        state <= st_alpha_mult_AP_s2;
                    when st_alpha_mult_AP_s2 => 
                        if (count_counter = "00100") then --todo
                            reset_counter <= '1';
                            state <= stTEMP3;
                        end if ;
-- ===============================================================================================
-- alpha_mult_Ap is read out from mult_for_alpha_and_beta_01_out register
-- ===============================================================================================
                    when stTEMP3 => 
                        alpha_mult_Ap(0) <= mult_for_alpha_and_beta_00_out;
                        alpha_mult_Ap(1) <= mult_for_alpha_and_beta_01_out;
                        alpha_mult_Ap(2) <= mult_for_alpha_and_beta_02_out;
                        alpha_mult_Ap(3) <= mult_for_alpha_and_beta_03_out;
                        alpha_mult_Ap(4) <= mult_for_alpha_and_beta_04_out;
                        alpha_mult_Ap(5) <= mult_for_alpha_and_beta_05_out;
                        alpha_mult_Ap(6) <= mult_for_alpha_and_beta_06_out;
                        state <= stCalculate_r_new_s1;
-- ===============================================================================================
-- Calculate then r_new, which r = r - alpha * Ap; -- todo : what about vector --> DONE
-- ===============================================================================================
                    when stCalculate_r_new_s1 => 
                        rold <= r ; -- store value of r to rold to calculate the error 
                        add_sub0_reg1 <= r(0);
                        add_sub0_reg2 <= alpha_mult_Ap(0);
                        add_sub_control_for_add_sub0 <= '0'; -- '0' is for substractor
                        add_sub1_reg1 <= r(1);
                        add_sub1_reg2 <= alpha_mult_Ap(1);
                        add_sub_control_for_add_sub1 <= '0'; -- '0' is for substractor
                        add_sub2_reg1 <= r(2);
                        add_sub2_reg2 <= alpha_mult_Ap(2);
                        add_sub_control_for_add_sub2 <= '0'; -- '0' is for substractor
                        add_sub3_reg1 <= r(3);
                        add_sub3_reg2 <= alpha_mult_Ap(3);
                        add_sub_control_for_add_sub3 <= '0'; -- '0' is for substractor
                        add_sub4_reg1 <= r(4);
                        add_sub4_reg2 <= alpha_mult_Ap(4);
                        add_sub_control_for_add_sub4 <= '0'; -- '0' is for substractor
                        add_sub5_reg1 <= r(5);
                        add_sub5_reg2 <= alpha_mult_Ap(5);
                        add_sub_control_for_add_sub5 <= '0'; -- '0' is for substractor
                        add_sub6_reg1 <= r(6);
                        add_sub6_reg2 <= alpha_mult_Ap(6);
                        add_sub_control_for_add_sub6 <= '0'; -- '0' is for substractor
                        reset_counter <= '0' ;
                        state <= stCalculate_r_new_s2;
                    when stCalculate_r_new_s2 => 
                        if (count_counter = "00110") then -- TODO 
                            reset_counter <= '1';
                            state <= stCalculate_beta_s1;
                        end if;
                 --   when stREAD_rnew => 
-- ===============================================================================================
-- Read r_new form add_sub units  
-- also, r0 * Ap0 + r1 *Ap1 + r2 * Ap2 (beta_num_arg1) entered into adder_and_multiplier chain 
-- ===============================================================================================
                    when stCalculate_beta_s1 =>  --TODO : how we can integrate with mcg_index
                        r(0) <= add_sub0_out;
                        r(1) <= add_sub1_out;
                        r(2) <= add_sub2_out;
                        r(3) <= add_sub3_out;
                        r(4) <= add_sub4_out;
                        r(5) <= add_sub5_out;
                        r(6) <= add_sub6_out;
                        state <= stTEMP8;
                    when stTEMP8 => 
                        mult1_reg1 <= r(0);         mult1_reg2 <= Ap(0);
                        mult2_reg1 <= r(1);         mult2_reg2 <= Ap(1);
                        mult3_reg1 <= r(2);         mult3_reg2 <= Ap(2);
                        mult4_reg1 <= x"00000000";  mult4_reg2 <= x"00000000";
                        mult5_reg1 <= x"00000000";  mult5_reg2 <= x"00000000";
                        mult6_reg1 <= x"00000000";  mult6_reg2 <= x"00000000";
                        mult7_reg1 <= x"00000000";  mult7_reg2 <= x"00000000";
                        reset_counter <= '0';
                        state <= stCalculate_beta_s2;
-- ===============================================================================================
-- r3 * Ap3 + r4 *Ap4 + r5 * Ap5 + r6 * Ap6 (beta_num_arg2) entered into adder_and_multiplier chain 
-- ===============================================================================================
                    when stCalculate_beta_s2 => 
                        mult1_reg1 <= r(3);         mult1_reg2 <= Ap(3);
                        mult2_reg1 <= r(4);         mult2_reg2 <= Ap(4);
                        mult3_reg1 <= r(5);         mult3_reg2 <= Ap(5);
                        mult4_reg1 <= r(6);         mult4_reg2 <= Ap(6);
                        mult5_reg1 <= x"00000000";  mult5_reg2 <= x"00000000";
                        mult6_reg1 <= x"00000000";  mult6_reg2 <= x"00000000";
                        mult7_reg1 <= x"00000000";  mult7_reg2 <= x"00000000";
                        state <= stCalculate_beta_s3;
-- ===============================================================================================
-- no need to calculate beta_dem_arg1 and beta_dem_arg2 because they are same as that for alpha, 
-- hence avoiding calculation and saving some clock cycle
-- ===============================================================================================
                    when stCalculate_beta_s3 =>
                        if (count_counter = "11001") then --todo 26 cycles 
                            reset_counter <= '1';
                            state <= stRead_beta_num_arg1;
                        end if;
-- ===============================================================================================
-- reading beta_num_arg1 and beta_num_arg2 from add7_out register 
-- ===============================================================================================
                    when stRead_beta_num_arg1 => 
                        beta_num_arg1 <= add7_out;
                        state <= stRead_beta_num_arg2;
                    when stRead_beta_num_arg2 => 
                        beta_num_arg2 <= add7_out;
                        state <= stCalculate_beta_num_s1;
-- ===============================================================================================
-- beta_num_arg1 and beta_num_arg2 is given to add_sub1 unit to get beta_num
-- ===============================================================================================
                    when stCalculate_beta_num_s1 => 
                        add_sub1_reg1 <= beta_num_arg2;
                        add_sub1_reg2 <= beta_num_arg1;
                        add_sub_control_for_add_sub1 <= '0'; -- '0' is for substraction 
                        reset_counter <= '0'; 
                        state <= stCalculate_beta_num_s2;
                    when stCalculate_beta_num_s2 => 
                        if (count_counter = "00110") then  -- todo 
                            reset_counter <= '1';
                            state <= stTEMP4;
                        end if;
-- ===============================================================================================
-- beta_num is read out from add_sub1_out register
-- ===============================================================================================
                    when stTEMP4 => 
                            beta_num <= add_sub1_out;
                            state <= stCalculate_beta;
-- ===============================================================================================
-- beta_num and alpha_dem (same as beta_dem) is given to input of divisor unit
-- ===============================================================================================
                    when stCalculate_beta => 
                        div1_reg1 <= beta_num;
                        div1_reg2 <= alpha_dem;
                        reset_counter <= '0';
                        state <= stRead_beta_s1;
                    when stRead_beta_s1 => 
                        if (count_counter = "00101") then  -- todo : after how much cycle divisor get result
                            reset_counter <= '1';
                            state <= stTEMP5;
                        end if ;
-- ===============================================================================================
-- beta is readed out from div1_out register 
-- ===============================================================================================
                    when stTEMP5 => 
                            beta <= div1_out;
                            state <= stCalculate_p_s1;
-- ===============================================================================================
-- calulate p_new (here p); p = r + beta * p;  -- todo : what about vectors 
-- beta and p is given input to mult_for_alpha_and_beta_01 unit
-- ===============================================================================================
                    when stCalculate_p_s1 => 
                        mult_for_alpha_and_beta_00_reg1 <= beta;
                        mult_for_alpha_and_beta_00_reg2 <= p(0);
                        mult_for_alpha_and_beta_01_reg1 <= beta;
                        mult_for_alpha_and_beta_01_reg2 <= p(1);
                        mult_for_alpha_and_beta_02_reg1 <= beta;
                        mult_for_alpha_and_beta_02_reg2 <= p(2);
                        mult_for_alpha_and_beta_03_reg1 <= beta;
                        mult_for_alpha_and_beta_03_reg2 <= p(3);
                        mult_for_alpha_and_beta_04_reg1 <= beta;
                        mult_for_alpha_and_beta_04_reg2 <= p(4);
                        mult_for_alpha_and_beta_05_reg1 <= beta;
                        mult_for_alpha_and_beta_05_reg2 <= p(5);
                        mult_for_alpha_and_beta_06_reg1 <= beta;
                        mult_for_alpha_and_beta_06_reg2 <= p(6);
                        reset_counter <= '0';
                        state <= stCalculate_p_s2;
                    when stCalculate_p_s2 => 
                        if (count_counter = "00100") then  -- todo : 5 cycle after multiplier is giving output -- verify ???
                            reset_counter <= '1';
                            state <= stTEMP6;
                        end if ;
                    when stTEMP6 => 
                        beta_mult_p(0) <= mult_for_alpha_and_beta_00_out;
                        beta_mult_p(1) <= mult_for_alpha_and_beta_01_out;
                        beta_mult_p(2) <= mult_for_alpha_and_beta_02_out;
                        beta_mult_p(3) <= mult_for_alpha_and_beta_03_out;
                        beta_mult_p(4) <= mult_for_alpha_and_beta_04_out;
                        beta_mult_p(5) <= mult_for_alpha_and_beta_05_out;
                        beta_mult_p(6) <= mult_for_alpha_and_beta_06_out;
                        state <= stCalculate_p_s3;
-- ===============================================================================================
-- beta_mult_p and r is given to add_sub1 unit
-- ===============================================================================================
                    when stCalculate_p_s3 => 
                        add_sub0_reg1 <= r(0);
                        add_sub0_reg2 <= beta_mult_p(0);
                        add_sub_control_for_add_sub0 <= '1'; -- '1' is for adder
                        add_sub1_reg1 <= r(1);
                        add_sub1_reg2 <= beta_mult_p(1);
                        add_sub_control_for_add_sub1 <= '1'; -- '1' is for adder
                        add_sub2_reg1 <= r(2);
                        add_sub2_reg2 <= beta_mult_p(2);
                        add_sub_control_for_add_sub2 <= '1'; -- '1' is for adder
                        add_sub3_reg1 <= r(3);
                        add_sub3_reg2 <= beta_mult_p(3);
                        add_sub_control_for_add_sub3 <= '1'; -- '1' is for adder
                        add_sub4_reg1 <= r(4);
                        add_sub4_reg2 <= beta_mult_p(4);
                        add_sub_control_for_add_sub4 <= '1'; -- '1' is for adder
                        add_sub5_reg1 <= r(5);
                        add_sub5_reg2 <= beta_mult_p(5);
                        add_sub_control_for_add_sub5 <= '1'; -- '1' is for adder
                        add_sub6_reg1 <= r(6);
                        add_sub6_reg2 <= beta_mult_p(6);
                        add_sub_control_for_add_sub6 <= '1'; -- '1' is for adder
                        reset_counter <= '0';
                        state <= stCalculate_p;
                    when stCalculate_p => 
                        if (count_counter = "00110") then  -- todo : 7 cycles 
                            reset_counter <= '1';
                            state <= stREAD_p;
                        end if ;
-- ===============================================================================================
-- P_new is readed out from add_sub units 
-- ===============================================================================================
                    when stREAD_p => 
                        p(0) <= add_sub0_out;
                        p(1) <= add_sub1_out;
                        p(2) <= add_sub2_out;
                        p(3) <= add_sub3_out;
                        p(4) <= add_sub4_out;
                        p(5) <= add_sub5_out;
                        p(6) <= add_sub6_out;
                        state <= stCalculate_r_minus_rold;
-- ===============================================================================================
-- dicision takeing unit --> for iteration of loop again 
-- calculating r_minus_rold = r - rold;
-- r and rold is given to add_sub units
-- ===============================================================================================
                    when stCalculate_r_minus_rold => 
                        add_sub0_reg1 <= r(0);
                        add_sub0_reg2 <= rold(0);
                        add_sub_control_for_add_sub0 <= '0'; -- '0' is for substractor
                        add_sub1_reg1 <= r(1);
                        add_sub1_reg2 <= rold(1);
                        add_sub_control_for_add_sub1 <= '0'; -- '0' is for substractor
                        add_sub2_reg1 <= r(2);
                        add_sub2_reg2 <= rold(2);
                        add_sub_control_for_add_sub2 <= '0'; -- '0' is for substractor
                        add_sub3_reg1 <= r(3);
                        add_sub3_reg2 <= rold(3);
                        add_sub_control_for_add_sub3 <= '0'; -- '0' is for substractor
                        add_sub4_reg1 <= r(4);
                        add_sub4_reg2 <= rold(4);
                        add_sub_control_for_add_sub4 <= '0'; -- '0' is for substractor
                        add_sub5_reg1 <= r(5);
                        add_sub5_reg2 <= rold(5);
                        add_sub_control_for_add_sub5 <= '0'; -- '0' is for substractor
                        add_sub6_reg1 <= r(6);
                        add_sub6_reg2 <= rold(6);
                        add_sub_control_for_add_sub6 <= '0'; -- '0' is for substractor
                        reset_counter <= '0';
                        state <= stREAD_r_minus_rold_s1; 
-- ===============================================================================================
-- r_minus_rold is readed out from add_sub_out registers 
-- ===============================================================================================
                    when stREAD_r_minus_rold_s1=>
                        if (count_counter = "00110") then 
                            reset_counter <= '1';
                            state <= stREAD_r_minus_rold_s2;
                        end if;
                    when stREAD_r_minus_rold_s2 => 
                        r_minus_rold(0) <= add_sub0_out;
                        r_minus_rold(1) <= add_sub1_out;
                        r_minus_rold(2) <= add_sub2_out;
                        r_minus_rold(3) <= add_sub3_out;
                        r_minus_rold(4) <= add_sub4_out;
                        r_minus_rold(5) <= add_sub5_out;
                        r_minus_rold(6) <= add_sub6_out;
                        state <= stABS_r_minus_rold_s1;
-- ===============================================================================================
-- Converting r-rold to abs(r-rold); used abs floating point ip 
-- ===============================================================================================
                    when stABS_r_minus_rold_s1 => 
                        fp_abs0_reg <= r_minus_rold(0);
                        fp_abs1_reg <= r_minus_rold(1);
                        fp_abs2_reg <= r_minus_rold(2);
                        fp_abs3_reg <= r_minus_rold(3);
                        fp_abs4_reg <= r_minus_rold(4);
                        fp_abs5_reg <= r_minus_rold(5);
                        fp_abs6_reg <= r_minus_rold(6);
                        state <= stTEMP10;
                    when stTEMP10 => 
                        state <= stABS_r_minus_rold_s2;

                    when stABS_r_minus_rold_s2 => 
                        abs_r_minus_rold(0) <= fp_abs0_out;
                        abs_r_minus_rold(1) <= fp_abs1_out;
                        abs_r_minus_rold(2) <= fp_abs2_out;
                        abs_r_minus_rold(3) <= fp_abs3_out;
                        abs_r_minus_rold(4) <= fp_abs4_out;
                        abs_r_minus_rold(5) <= fp_abs5_out;
                        abs_r_minus_rold(6) <= fp_abs6_out;
                        state <= stFind_max_in_abs;
-- ===============================================================================================
-- finding max(abs(r-rold)) to get maximum error in r and rold 
-- This is max_finder unit which results in psudo max finder, that is it just check exponent part
-- ===============================================================================================
                    when stFind_max_in_abs => 
                        max_finder_input0 <= abs_r_minus_rold(0);
                        max_finder_input1 <= abs_r_minus_rold(1);
                        max_finder_input2 <= abs_r_minus_rold(2);
                        max_finder_input3 <= abs_r_minus_rold(3);
                        max_finder_input4 <= abs_r_minus_rold(4);
                        max_finder_input5 <= abs_r_minus_rold(5);
                        max_finder_input6 <= abs_r_minus_rold(6);
                        state <= stCompare_max_with_epsilon ;
-- ===============================================================================================
-- Calculating : error, if greater than tolerance go st stPROC_AP_ROW1 else go to stFINISH; 
-- here we are comparing only exponent part, no need to compare all bits
-- ===============================================================================================
                    when stCompare_max_with_epsilon => 
                        max_abs_r_minus_rold <= max_finder_output;
                     --   comp1  <= max_abs_r_minus_rold(30 downto 23);
                       -- comp2  <= tol(30 downto 23);
                        --state <= stTEMP11;
                        --when stTEMP11 => 
                          --  comp1 <= max_abs_r_minus_rold (30 downto 23);
                           -- comp2 <= tol(30 downto 23);
                            state <= stTEMP12;
                    when stTEMP12 => 
                        comp1 <= max_abs_r_minus_rold(30 downto 23);
                        comp2 <= tol(30 downto 23);
                        --if (to_integer(unsigned(max_abs_r_minus_rold(30 downto 23))) > to_integer(unsigned(tol(30 downto 23)))) then  
                        if ( max_abs_r_minus_rold(30 downto 23) < tol(30 downto 23)) then
                    --        report "out1 [ " & integer'image(to_integer(unsigned(max_abs_r_minus_rold(30 downto 23)))) & "]";
                        --if (comp1 < comp2) then 
                            state <= stFINISH;
                        else 
                            state <= stPROC_AP_ROW1;
                        end if;
-- ===============================================================================================
-- write "00000000" to control and status reg to get result in nios terminal 
-- ===============================================================================================
                    when stFINISH =>
                        control_and_status_reg <= x"00000000";
                        state <= stIDLE;
                    when stIDLE => 
                        state <= stIDLE;
                    when others => null;
                end case;
            end if ;
            end if;
        end process;

end architecture arch;
