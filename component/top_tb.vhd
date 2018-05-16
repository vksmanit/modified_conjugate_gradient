library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.headers.all;

entity top_tb is
end entity top_tb;


architecture arch of top_tb is

--- component instantiation of top
    component top is
        port (
            clk, reset : in std_logic;
            address : in std_logic_vector(6 downto 0);
            read : in std_logic;
            write : in std_logic;
            readdata : out std_logic_vector_32;
            writedata : in std_logic_vector_32
        );
    end component top;

    -- signals 
    signal clk, reset, read, write : std_logic := '0';
    signal address : std_logic_vector (6 downto 0);
    signal readdata, writedata : std_logic_vector_32;

    procedure iowrite ( signal write            : out std_logic;
                        signal writedata        : out std_logic_vector_32;
                        signal address          : out std_logic_vector(6 downto 0);
                               address_value    : std_logic_vector(6 downto 0);
                               data             : std_logic_vector_32) is
    begin
        wait for 80 ns;
        address <= address_value;
        writedata <= data;
        write <= '1';
        wait for 0 ns;
       -- report "iowrite : address [" & integer'image (to_integer (unsigned (address_value))) & "], "
         --   & "writedata [" & integer'image (to_integer (unsigned (data))) & "]";
        wait for 40 ns;
        write <= '0';
        wait for 0 ns;
    end procedure;


    procedure ioread  ( signal read            : out std_logic;
                        signal readdata        : in  std_logic_vector_32;
                        signal address         : out std_logic_vector (6 downto 0);
                               address_value   : in  std_logic_vector (6 downto 0);
                               readdata_value  : out std_logic_vector_32) is
    begin
        wait for 80 ns;
        address   <= address_value;
        read      <= '1';
        wait for 0 ns;
        wait for 41 ns;
        ---report "ioread : address [" & integer'image (to_integer (unsigned (address_value))) & "], "
           --           & "readdata [" & integer'image (to_integer (unsigned (readdata))) & "]";
        readdata_value := readdata;
        read     <= '0';
        wait for 39 ns;
    end procedure;

begin

    uut : top port map (clk => clk, reset => reset, address => address, read => read, write => write, readdata => readdata, writedata => writedata);

    clk <= not clk after 20 ns;
    reset <= '1' after 0 ns, '0' after 80 ns;
    P1: process
        variable readdata_value : std_logic_vector_32;
   
    
    
    
    begin
        -- let it reset 
        wait for 140 ns;

        -- 1. write matrix data of hex equivalent of floating points value

        iowrite (write, writedata, address, "0000001", x"3c23d70a"); --1
        iowrite (write, writedata, address, "0000010", x"00000000"); --2
        iowrite (write, writedata, address, "0000011", x"bc23d70a"); --3
        iowrite (write, writedata, address, "0000100", x"00000000"); --4
        iowrite (write, writedata, address, "0000101", x"00000000"); --5
        iowrite (write, writedata, address, "0000110", x"00000000"); --6
        iowrite (write, writedata, address, "0000111", x"00000000"); --7
        iowrite (write, writedata, address, "0001000", x"00000000"); --8
        iowrite (write, writedata, address, "0001001", x"3ca3d70a"); --9
        iowrite (write, writedata, address, "0001010", x"bc23d70a"); --10
        iowrite (write, writedata, address, "0001011", x"00000000"); --11
        iowrite (write, writedata, address, "0001100", x"3f800000"); --12
        iowrite (write, writedata, address, "0001101", x"00000000"); --13
        iowrite (write, writedata, address, "0001110", x"00000000"); --14
        iowrite (write, writedata, address, "0001111", x"bc23d70a"); --15
        iowrite (write, writedata, address, "0010000", x"bc23d70a"); --16
        iowrite (write, writedata, address, "0010001", x"3cf5c28f"); --17
        iowrite (write, writedata, address, "0010010", x"3f800000"); --18
        iowrite (write, writedata, address, "0010011", x"00000000"); --19
        iowrite (write, writedata, address, "0010100", x"00000000"); --20
        iowrite (write, writedata, address, "0010101", x"00000000"); --21
        iowrite (write, writedata, address, "0010110", x"00000000"); --22
        iowrite (write, writedata, address, "0010111", x"00000000"); --23
        iowrite (write, writedata, address, "0011000", x"bf800000"); --24
        iowrite (write, writedata, address, "0011001", x"469c4000"); --25
        iowrite (write, writedata, address, "0011010", x"461c4000"); --26
        iowrite (write, writedata, address, "0011011", x"461c4000"); --27
        iowrite (write, writedata, address, "0011100", x"00000000"); --28
        iowrite (write, writedata, address, "0011101", x"00000000"); --29
        iowrite (write, writedata, address, "0011110", x"bf800000"); --30
        iowrite (write, writedata, address, "0011111", x"00000000"); --31
        iowrite (write, writedata, address, "0100000", x"461c4000"); --32
        iowrite (write, writedata, address, "0100001", x"469c4000"); --33
        iowrite (write, writedata, address, "0100010", x"461c4000"); --34
        iowrite (write, writedata, address, "0100011", x"00000000"); --35
        iowrite (write, writedata, address, "0100100", x"00000000"); --36
        iowrite (write, writedata, address, "0100101", x"00000000"); --37
        iowrite (write, writedata, address, "0100110", x"00000000"); --38
        iowrite (write, writedata, address, "0100111", x"461c4000"); --39
        iowrite (write, writedata, address, "0101000", x"461c4000"); --40
        iowrite (write, writedata, address, "0101001", x"469c4000"); --41
        iowrite (write, writedata, address, "0101010", x"00000000"); --42
        iowrite (write, writedata, address, "0101011", x"00000000"); --43
        iowrite (write, writedata, address, "0101100", x"00000000"); --44
        iowrite (write, writedata, address, "0101101", x"00000000"); --45
        iowrite (write, writedata, address, "0101110", x"00000000"); --46
        iowrite (write, writedata, address, "0101111", x"00000000"); --47
        iowrite (write, writedata, address, "0110000", x"00000000"); --48
        iowrite (write, writedata, address, "0110001", x"469c4000"); --49
        iowrite (write, writedata, address, "0110010", x"ba83126f"); --50
        iowrite (write, writedata, address, "0110011", x"3a83126f"); --51
        iowrite (write, writedata, address, "0110100", x"00000000"); --52
        iowrite (write, writedata, address, "0110101", x"41200000"); --53
        iowrite (write, writedata, address, "0110110", x"00000000"); --54
        iowrite (write, writedata, address, "0110111", x"41200000"); --55
        iowrite (write, writedata, address, "0111000", x"41200000"); --56
  --    rrrrrrte (write, writedata, address, "111010", x""); --2       58
  --     iowrite (write, writedata, address, "111011", x""); --3       59
  --     iowrite (write, writedata, address, "111100", x""); --1
  --     iowrite (write, writedata, address, "111101", x""); --1
  --     iowrite (write, writedata, address, "111110", x""); --2
  --     iowrite (write, writedata, address, "111111", x""); --3

        -- 2. write 1 to control & status register to trigger the operation 
        iowrite (write, writedata, address, "0000000", x"00000001");

  --    rrrrrrte (write, writedata, address, "111010", x""); --2       58
  --     iowrite (write, writedata, address, "111011", x""); --3       59
  --     iowrite (write, writedata, address, "111100", x""); --1
  --     iowrite (write, writedata, address, "111101", x""); --1
  --     iowrite (write, writedata, address, "111110", x""); --2
  --     iowrite (write, writedata, address, "111111", x""); --3
        -- 3. wait till status become 0
    --   loop  
    --       ioread (read , readdata, address, "0000000", readdata_value);
    --       exit when readdata_value = x"00000000";
    --   end loop;

        --4 read and display output values
       --ioread (read, readdata, address, "0111010", readdata_value);
       --ioread (read, readdata, address, "0111011", readdata_value);
       --ioread (read, readdata, address, "0111100", readdata_value);
       --ioread (read, readdata, address, "0111101", readdata_value);
       --ioread (read, readdata, address, "0111110", readdata_value);
       --ioread (read, readdata, address, "0111111", readdata_value);
       --ioread (read, readdata, address, "1000000", readdata_value);
        wait ;
    end process;
end architecture arch;

