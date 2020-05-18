-- The Decoder scans each column by asserting a low to the pin corresponding to the column 
-- at 1KHz. After a column is asserted low, each row pin is checked. 
-- When a row pin is detected to be low, the key that was pressed could be determined.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keypad_decoder is
    Port (
	  clk : in  STD_LOGIC;
	  clear : in std_logic;
      Row : in  STD_LOGIC_VECTOR (3 downto 0);
	  Col : out  STD_LOGIC_VECTOR (3 downto 0);
	  char_we : out std_logic;
	  char_write_value : out std_logic_vector(3 downto 0);
	  char_write_addr : out std_logic_vector(6 downto 0);
	  display_enable_write : out std_logic		
       );
end keypad_decoder;

architecture Behavioral of keypad_decoder is

signal sclk : unsigned(19 downto 0);
signal fail_count : unsigned(1 downto 0):="00";
signal write_addr : unsigned(6 downto 0):= (others => '0');
signal cur:std_logic:='0';
signal last:std_logic:='0';

begin    
	last <= cur when rising_edge(clk);
    char_write_addr <= std_logic_vector(write_addr) when rising_edge(clk);    
	
	process(clk,cur,last)
	   begin
	   if rising_edge(clk) then
	       if clear='1' then
	           write_addr <= (others=>'0');           
	       elsif cur='1' and last='0' then
	           char_we <= '1';
	           display_enable_write<='1';
	           if write_addr = X"77" then
	                   write_addr <= (others => '0');
	           else 
	                   write_addr <= write_addr + 1;
	           end if;
	       else
	           char_we <= '0';
	           display_enable_write<='0';            
	       end if;    
	   end if;
	end process;
	       
	process(clk)
		begin 
		if clk'event and clk = '1' then
			if sclk = X"1E848" then 
				--C1
				Col<= "0111";
				sclk <= sclk+1;
				fail_count <= "00";
			-- check row pins
			elsif sclk = X"1E858" then	
				--R1
				if Row = "0111" then
					char_write_value <= "0001"; --1
				--R2
				elsif Row = "1011" then
					char_write_value <= "0100"; --4
				--R3
				elsif Row = "1101" then
					char_write_value <= "0111"; --7
				--R4
				elsif Row = "1110" then
					char_write_value <= "0000"; --0
				else fail_count <= fail_count + 1;	
				end if;
				sclk <= sclk+1;
			elsif sclk = X"3D090" then	
				--C2
				Col<= "1011";
				sclk <= sclk+1;
			-- check row pins
			elsif sclk = X"3D0A0" then	
				--R1
				if Row = "0111" then		
					char_write_value <= "0010"; --2
				--R2
				elsif Row = "1011" then
					char_write_value <= "0101"; --5
				--R3
				elsif Row = "1101" then
					char_write_value <= "1000"; --8
				--R4
				elsif Row = "1110" then
					char_write_value <= "1111"; --F
				else fail_count <= fail_count + 1;	
				end if;
				sclk <= sclk+1;	
			elsif sclk = X"5B8D8" then 
				--C3
				Col<= "1101";
				sclk <= sclk+1;
			-- check row pins
			elsif sclk = X"5B8E8" then 
				--R1
				if Row = "0111" then
					char_write_value <= "0011"; --3	
				--R2
				elsif Row = "1011" then
					char_write_value <= "0110"; --6
				--R3
				elsif Row = "1101" then
					char_write_value <= "1001"; --9
				--R4
				elsif Row = "1110" then
					char_write_value <= "1110"; --E
				else fail_count <= fail_count + 1;	
				end if;
				sclk <= sclk+1;
			elsif sclk = X"7A120" then 			
				--C4
				Col<= "1110";
				sclk <= sclk+1;
			-- check row pins
			elsif sclk = X"7A130" then 
				--R1
				if Row = "0111" then
					char_write_value <= "1010"; --A
					cur <= '1';	
				--R2
				elsif Row = "1011" then
					char_write_value <= "1011"; --B
					cur <= '1';
				--R3
				elsif Row = "1101" then
					char_write_value <= "1100"; --C
					cur <= '1';					
				--R4
				elsif Row = "1110" then
					char_write_value <= "1101"; --D
					cur <= '1';
				elsif fail_count = "11" then
					cur <= '0';
				else 
				     cur <= '1';
				end if;
				sclk <= X"00000";        
			else
				sclk <= sclk+1;	
			end if;
		end if;
	end process;
						 
end Behavioral;