library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pix_to_charAddr is
	port (
		pix_x: in integer;
		pix_y: in integer;
		char_addr: out std_logic_vector(6 downto 0);
		bitPosition_x : out integer;
		bitPosition_y : out integer 
	);
end pix_to_charAddr;

architecture rtl of pix_to_charAddr is

	constant SMALL_FONT_WIDTH:integer:=8;
	constant SMALL_FONT_HEIGHT:integer:=16;
	constant LARGE_FONT_WIDTH:integer:=40;
	constant LARGE_FONT_HEIGHT:integer:=80;
	constant ROW_LENGTH:integer:= 20;
	constant COL_LENGTH:integer:= 6;	
	constant FONT_MAG:integer:=5;

	signal charPosition_x:integer;
	signal charPosition_y:integer;
	signal addr:integer;

begin
    
    charPosition_x <= pix_x/LARGE_FONT_WIDTH;
    charPosition_y <= pix_y/LARGE_FONT_HEIGHT;
    addr <=  (charPosition_y * ROW_LENGTH) + charPosition_x;
    char_addr <= std_logic_vector(to_unsigned(addr,7));
    bitPosition_x <= (pix_x mod LARGE_FONT_WIDTH) / FONT_MAG;
    bitPosition_y <= (pix_y mod LARGE_FONT_HEIGHT) / FONT_MAG;	
   	  
end rtl;