library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.headers.all;

entity max_finder is 
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
end entity max_finder;

architecture arch of max_finder is 
    signal a0 : std_logic_vector (7 downto 0);
    signal a1 : std_logic_vector (7 downto 0);
    signal a2 : std_logic_vector (7 downto 0);
    signal a3 : std_logic_vector (7 downto 0);
    signal a4 : std_logic_vector (7 downto 0);
    signal a5 : std_logic_vector (7 downto 0);
    signal a6 : std_logic_vector (7 downto 0);
    signal sig_max_number : std_logic_vector(7 downto 0);

begin 
    a0 <= max_finder_input0(30 downto 23);
    a1 <= max_finder_input1(30 downto 23);
    a2 <= max_finder_input2(30 downto 23);
    a3 <= max_finder_input3(30 downto 23);
    a4 <= max_finder_input4(30 downto 23);
    a5 <= max_finder_input5(30 downto 23);
    a6 <= max_finder_input6(30 downto 23);

    process(a0,a1,a2,a3,a4,a5,a6)
        variable max_number    : std_logic_vector(7 downto 0);
        variable max_number_01 : std_logic_vector(7 downto 0);
        variable max_number_02 : std_logic_vector(7 downto 0);
        variable max_number_03 : std_logic_vector(7 downto 0);
        variable max_number_04 : std_logic_vector(7 downto 0);
        variable max_number_05 : std_logic_vector(7 downto 0);
    --    variable max_number_index : integer := 0;
    begin 
        if (a1 > a0 ) then 
            max_number_01 := a1;
           -- out_max_number := max_finder_input1;
           -- max_number_index := 1;
        else 
            max_number_01 := a0;
          --  out_max_number := max_finder_input0;
           -- max_number_index := 0;
        end if;
        if (a3 > a2) then 
            max_number_02 := a3;
            --max_number_index := 3;
        else 
            max_number_01 := a2;
            --max_number_index := 2;
        end if;
        if (a5 > a4) then 
            max_number_03 := a5;
            --max_number_index := 5;
        else 
            max_number_03 := a4;
            --max_number_index := 4;
        end if;
        ------------ first step -------------------
        if (max_number_01 > max_number_02) then 
            max_number_04 := max_number_01;
        else 
            max_number_04 := max_number_02;
        end if;
        if (max_number_03 > a6) then 
            max_number_05 := max_number_03;
        else 
            max_number_05 := a6;
        end if;
        ------------ first step -------------------
        if (max_number_04 > max_number_05) then 
            max_number := max_number_04;
        else 
            max_number := max_number_05;
        end if;

        sig_max_number <= max_number;
    end process;

    process (sig_max_number) 
    begin 
        if ( sig_max_number= a0) then 
            max_finder_output <= max_finder_input0;
        elsif ( sig_max_number= a1) then 
            max_finder_output <= max_finder_input1;
        elsif ( sig_max_number = a2) then 
            max_finder_output <= max_finder_input2;
        elsif ( sig_max_number = a3) then 
            max_finder_output <= max_finder_input3;
        elsif ( sig_max_number = a4) then 
            max_finder_output <= max_finder_input4;
        elsif ( sig_max_number = a5) then 
            max_finder_output <= max_finder_input5;
        elsif ( sig_max_number = a6) then 
            max_finder_output <= max_finder_input6;
        else 
            max_finder_output <= (others => '0');
        end if;
       --case sig_max_number is 
       --    when 0 => max_finder_output <= max_finder_inputs(0);
       --    when 1 => max_finder_output <= max_finder_inputs(1);
       --    when 2 => max_finder_output <= max_finder_inputs(2);
       --    when 3 => max_finder_output <= max_finder_inputs(3);
       --    when 4 => max_finder_output <= max_finder_inputs(4);
       --    when 5 => max_finder_output <= max_finder_inputs(5);
       --    when 6 => max_finder_output <= max_finder_inputs(6);
       --    when others => null;
       --end case;
    end process;



end architecture arch; 
