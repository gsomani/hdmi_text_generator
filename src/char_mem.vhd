-- This memory can store 20x6 characters where each character is
-- 4 bits. The memory is dual ported providing a port
-- to read the characters and a port to write the characters.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity char_mem is
   port(
      clk: in std_logic;
      clear :in std_logic;
      char_read_addr : in std_logic_vector(6 downto 0);
      char_write_addr: in std_logic_vector(6 downto 0);
      char_we : in std_logic;
      char_write_value : in std_logic_vector(3 downto 0);
      char_read_value : out std_logic_vector(3 downto 0);
      display_enable_write : in std_logic;
      display_enable_read : out std_logic	
   );
end char_mem;

architecture arch of char_mem is

   constant CHAR_RAM_DEPTH: integer := 120;
   constant CHAR_RAM_ADDR_WIDTH: integer := 7; -- 120 characters
   constant CHAR_RAM_WIDTH: integer := 4;  -- 4 bits per character
   
   type char_ram_type is array (0 to CHAR_RAM_DEPTH-1)
     of std_logic_vector(CHAR_RAM_WIDTH-1 downto 0);
    
   signal display_mem : std_logic_vector(0 to CHAR_RAM_DEPTH-1):=(others => '0');
		
   -- character memory signal
   signal char_ram : char_ram_type := (others => X"0");
    
begin

  -- character memory concurrent statement
  process(clk)
  begin
    if (clk'event and clk='1') then
      if (clear='1') then
         char_ram <= (others => X"0");
         display_mem <= (others => '0');
      elsif (char_we = '1') then
        char_ram(to_integer(unsigned(char_write_addr))) <= char_write_value;
        display_mem(to_integer(unsigned(char_write_addr))) <= display_enable_write;
      end if;
    end if;
  end process;
  char_read_value <= char_ram(to_integer(unsigned(char_read_addr)));
  display_enable_read <= display_mem(to_integer(unsigned(char_read_addr)));
     
end arch;

