library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tmds_encoder is
    Port ( clk     : in  STD_LOGIC;
           data    : in  STD_LOGIC_VECTOR (7 downto 0);
           ctrl    : in  STD_LOGIC_VECTOR (1 downto 0);
           en   : in  STD_LOGIC;
           encoded : out  STD_LOGIC_VECTOR (9 downto 0));
end tmds_encoder;

architecture Behavioral of tmds_encoder is
   signal xored  : STD_LOGIC_VECTOR (8 downto 0);
   signal xnored : STD_LOGIC_VECTOR (8 downto 0);
   
   signal ones                : integer range 0 to 8;
   signal data_word           : std_logic_vector(8 downto 0);
   signal data_word_inv       : std_logic_vector (8 downto 0);
   signal data_word_disparity : signed(4 downto 0);
   signal dc_bias             : signed(4 downto 0) := (others => '0');
begin

    -- create xor encodings
	xored(0) <= data(0);
	encode_xor: for i in 1 to 7 generate
	begin
		xored(i) <= data(i) xor xored(i - 1);
	end generate;
	xored(8) <= '1';

	-- create xnor encodings
	xnored(0) <= data(0);
	encode_xnor: for i in 1 to 7 generate
	begin
		xnored(i) <= data(i) xnor xnored(i - 1);
	end generate;
	xnored(8) <= '0';   
   
   -- Count how many ones are set in data
   process(data) is
		variable c : integer range 0 to 8;
	begin
		c := 0;
		for i in 0 to 7 loop
			if data(i) = '1' then
				c := c + 1;
			end if;
		end loop;
		ones <= c;
	end process;
 
   -- use xnored or xored data based on the ones
       data_word <= xnored when ones > 4 or (ones = 4 and data(0) = '0') else xored;
       data_word_inv <= NOT(data_word); 

   -- Work out the DC bias of the dataword;
   process(data_word) is
		variable c : integer range 0 to 8;
	begin
		c := 0;
		for i in 0 to 7 loop
			if data_word(i) = '1' then
				c := c + 1;
			end if;
		end loop;
		data_word_disparity <= (to_signed(c-4, 4)) & '0';
	end process;
   
   -- Now work out what the output should be
   process(clk)
   begin
      if rising_edge(clk) then
         if en = '0' then 
            -- In the control periods, all values have and have balanced bit count
            case ctrl is            
               when "00"   => encoded <= "1101010100";
               when "01"   => encoded <= "0010101011";
               when "10"   => encoded <= "0101010100";
               when others => encoded <= "1010101011";
            end case;
            dc_bias <= (others => '0');
         else
            if dc_bias = "00000" or data_word_disparity = "00000" then
               -- dataword has no disparity
               if data_word(8) = '1' then
                  encoded <= "01" & data_word(7 downto 0);
                  dc_bias <= dc_bias + data_word_disparity;
               else
                  encoded <= "10" & data_word_inv(7 downto 0);
                  dc_bias <= dc_bias - data_word_disparity;
               end if;
            elsif (dc_bias(4) = '0' and data_word_disparity(4) = '0') or 
                  (dc_bias(4) = '1' and data_word_disparity(4) = '1') then
               encoded <= '1' & data_word(8) & data_word_inv(7 downto 0);
               if(data_word(8)='1') then dc_bias <= dc_bias - data_word_disparity + 2;
	       else dc_bias <= dc_bias - data_word_disparity;
	       end if;
            else
               encoded <= '0' & data_word;
	       if(data_word(8)='1') then dc_bias <= dc_bias + data_word_disparity - 2;
	       else dc_bias <= dc_bias + data_word_disparity;
               end if;	
            end if;
         end if;
      end if;
   end process;      
end Behavioral;