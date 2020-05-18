library ieee;
use ieee.std_logic_1164.all;

entity rgb2tmds is
	port(
		-- reset and clocks
		rst : in std_logic;
		pixelclock : in std_logic;  -- slow pixel clock 1x
		serialclock : in std_logic; -- fast serial clock 5x

		-- video signals
		video_data : in std_logic_vector(23 downto 0);
		video_active  : in std_logic;
		hsync : in std_logic;
		vsync : in std_logic;

		-- tmds output ports
		clk_p : out std_logic;
		clk_n : out std_logic;
		data_p : out std_logic_vector(2 downto 0);
		data_n : out std_logic_vector(2 downto 0)
	);
end rgb2tmds;

architecture rtl of rgb2tmds is
	signal enred, engreen, enblue : std_logic_vector(9 downto 0) := (others => '0');
	signal sync : std_logic_vector(1 downto 0);

component tmds_encoder is
    Port ( clk     : in  STD_LOGIC;
           data    : in  STD_LOGIC_VECTOR (7 downto 0);
           ctrl       : in  STD_LOGIC_VECTOR (1 downto 0);
           en   : in  STD_LOGIC;
           encoded : out  STD_LOGIC_VECTOR (9 downto 0));
end component;

component serializer is
	port (
		rst      : in  std_logic;
		pixclk   : in  std_logic;  -- low speed pixel clock 1x
		serclk   : in  std_logic;  -- high speed serial clock 5x
		endata_i : in  std_logic_vector(9 downto 0);
		s_p      : out std_logic;
		s_n      : out std_logic
	);
end component;

begin

	sync <= vsync & hsync;

	-- tmds encoder
	tb : tmds_encoder
		port map (clk=>pixelclock, en=>video_active, ctrl=>sync, data=>video_data(7  downto 0), encoded=>enblue);
	tg : tmds_encoder
		port map (clk=>pixelclock, en=>video_active, ctrl=>"00", data=>video_data(15 downto 8), encoded=>engreen);
	tr : tmds_encoder
		port map (clk=>pixelclock, en=>video_active, ctrl=>"00", data=>video_data(23 downto 16), encoded=>enred);
	
	-- tmds output serializers
	ser_b: serializer
		port map (pixclk=>pixelclock, serclk=>serialclock, rst=>rst, endata_i=>enblue,  s_p=>data_p(0), s_n=>data_n(0));
	ser_g: serializer
		port map (pixclk=>pixelclock, serclk=>serialclock, rst=>rst, endata_i=>engreen, s_p=>data_p(1), s_n=>data_n(1));
	ser_r: serializer
		port map (pixclk=>pixelclock, serclk=>serialclock, rst=>rst, endata_i=>enred,   s_p=>data_p(2), s_n=>data_n(2));
	-- tmds clock serializer to phase align with data signals
	ser_c: serializer
		port map (pixclk=>pixelclock, serclk=>serialclock, rst=>rst, endata_i=>"1111100000", s_p=>clk_p, s_n=>clk_n);

end rtl;
