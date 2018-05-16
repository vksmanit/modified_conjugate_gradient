library ieee;
use ieee.std_logic_1164.all;
--use std_logic_unsigned.all;
use ieee.numeric_std.all;

entity counter is 
    port (
            clk , reset : in std_logic;
            count : out std_logic_vector (4 downto 0)
        );
end entity counter;

architecture arch of counter is 
signal tmp : integer ; --std_logic_vector(3 downto 0);
begin 

    P: process(clk, reset)
    begin 
        if (reset = '1') then 
            tmp <= 0;
        elsif(rising_edge(clk)) then 
            tmp <= tmp + 1;  
        end if ;
    end process;
--    count <= std_logic_vector(to_unsigned(c,count'length));
    count <= std_logic_vector(to_unsigned(tmp, count'length));
end architecture arch;
