library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity objectbuffer is
	generic (
		OBJECT_SIZE : natural := 12;
		PIXEL_SIZE : natural := 24
	);
	port (
	    clk :in std_logic;
	    clear :in std_logic;
		video_active       : in  std_logic;
		pixel_x, pixel_y   : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
		background_rgb,font_rgb: in  std_logic_vector(PIXEL_SIZE-1 downto 0);
		rgb                : out std_logic_vector(PIXEL_SIZE-1 downto 0);
		Row : in  STD_LOGIC_VECTOR (3 downto 0);
	    Col : out  STD_LOGIC_VECTOR (3 downto 0)
	);
end objectbuffer;

architecture rtl of objectbuffer is

    -- signals that holds the x, y coordinates
	signal pix_x, pix_y: unsigned (OBJECT_SIZE-1 downto 0);

	signal pixel_on: std_logic;
	signal char_we :std_logic;
	signal char_write_value :std_logic_vector(3 downto 0);
	signal char_write_addr,char_read_addr,char_addr:std_logic_vector(6 downto 0);
	signal char_read_value :std_logic_vector(3 downto 0);
	signal bitPosition_x,bitPosition_y : integer;
	signal display_enable_write,display_enable_read : std_logic;
	signal addr,data: std_logic_vector(7 downto 0);
    signal bit_value, pix_on: std_logic;
    
	
component font_rom is
   port(
      addr: in std_logic_vector(7 downto 0);
      data: out std_logic_vector(7 downto 0)
   );
end component;

component char_mem is
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
end component;

component keypad_decoder is
    Port (
		  clk : in  STD_LOGIC;
		  clear :in std_logic;
          Row : in  STD_LOGIC_VECTOR (3 downto 0);
	  Col : out  STD_LOGIC_VECTOR (3 downto 0);
	  char_we : out std_logic;
	  char_write_value : out std_logic_vector(3 downto 0);
	  char_write_addr : out std_logic_vector(6 downto 0);
	  display_enable_write : out std_logic		
    
	  );
end component;

component pix_to_charAddr is
	port (
		pix_x: in integer;
		pix_y: in integer;
		char_addr: out std_logic_vector(6 downto 0);
		bitPosition_x : out integer;
		bitPosition_y : out integer 
	);
end component;

begin

	pix_x <= unsigned(pixel_x);
	pix_y <= unsigned(pixel_y);
	
	addr <= std_logic_vector(   unsigned(char_read_value & X"0") + to_unsigned(bitPosition_y,4)    );
    
    font: font_rom port map(addr,data);
    bit_value <= data(7-bitPosition_x);
    pixel_on <= bit_value and display_enable_read;

	keypad: keypad_decoder 
	       port map (clk,clear,Row,Col,char_we,char_write_value,char_write_addr,display_enable_write);
	             
	pix_font_encode:pix_to_charAddr 
		port map(to_integer(pix_x),to_integer(pix_y),char_addr,bitPosition_x,bitPosition_y);
	
	char_memory: char_mem
	       port map (clk,clear,char_addr,char_write_addr,char_we,char_write_value,char_read_value,display_enable_write,display_enable_read);
	

	process(video_active, pixel_on,font_rgb,background_rgb) is
	begin
		if video_active='0' then
			rgb <= x"000000"; --blank
		else
			if pixel_on='1' then
				rgb <= font_rgb;
			else
				rgb <= background_rgb;
			end if;
		end if;
	end process;

end rtl;