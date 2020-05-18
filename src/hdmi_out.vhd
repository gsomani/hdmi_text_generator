library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

entity hdmi_out is
	generic (
		OBJECT_SIZE  : natural := 10;
		PIXEL_SIZE   : natural := 24 -- RGB pixel total size. (R + G + B)
	);
	port(
		clk, rst,clear : in std_logic;
		-- tmds output ports
		clk_p : out std_logic;
		clk_n : out std_logic;
		data_p : out std_logic_vector(2 downto 0);
		data_n : out std_logic_vector(2 downto 0);
		Row : in  STD_LOGIC_VECTOR (3 downto 0);
	    Col : out  STD_LOGIC_VECTOR (3 downto 0)
);
end hdmi_out;

architecture rtl of hdmi_out is

	signal pixclk,serclk : std_logic;
	signal video_active   : std_logic := '0';
	signal video_data     : std_logic_vector(PIXEL_SIZE-1 downto 0);
	signal vsync, hsync   : std_logic := '0';
	signal pixel_x,pixel_y        : std_logic_vector(OBJECT_SIZE-1 downto 0);
	signal background_rgb   : std_logic_vector(PIXEL_SIZE-1 downto 0) := x"FFFFFF"; -- white
	signal font_rgb :std_logic_vector(PIXEL_SIZE-1 downto 0) := X"000000";
	signal rgb:std_logic_vector(PIXEL_SIZE-1 downto 0);
	    
component clock_gen is
	port(
		clk_i  : in  std_logic; --  input clock
		clk0_o : out std_logic; -- serial clock
		clk1_o : out std_logic  --  pixel clock
	);
end component;

component rgb2tmds is
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
end component;

component timing_generator is
	generic (
		OBJECT_SIZE  : natural := 12
	);
	port(
		clk           : in  std_logic;
		hsync, vsync  : out std_logic;
		video_active  : out std_logic;
		pixel_x       : out std_logic_vector(OBJECT_SIZE-1 downto 0);
		pixel_y       : out std_logic_vector(OBJECT_SIZE-1 downto 0)
	);
end component;

component objectbuffer is
	generic (
		OBJECT_SIZE : natural := 16;
		PIXEL_SIZE : natural := 24
	);
	port (
	    clk :in std_logic;
	    clear : in std_logic;
		video_active       : in  std_logic;
		pixel_x, pixel_y   : in  std_logic_vector(OBJECT_SIZE-1 downto 0);
		background_rgb,font_rgb: in  std_logic_vector(PIXEL_SIZE-1 downto 0);
		rgb                : out std_logic_vector(PIXEL_SIZE-1 downto 0);
		Row : in  STD_LOGIC_VECTOR (3 downto 0);
	    Col : out  STD_LOGIC_VECTOR (3 downto 0)
	);
end component;

begin
	clock: clock_gen
		port map (clk_i=>clk, clk0_o=>serclk, clk1_o=>pixclk);

	-- video timing
	timing: timing_generator
		generic map (OBJECT_SIZE => OBJECT_SIZE)
		port map (clk=>pixclk, hsync=>hsync, vsync=>vsync, video_active=>video_active, pixel_x=>pixel_x, pixel_y=>pixel_y);

	-- tmds signaling
	tmds_signaling: rgb2tmds
		port map (rst=>rst, pixelclock=>pixclk, serialclock=>serclk,
		video_data=>video_data, video_active=>video_active, hsync=>hsync, vsync=>vsync,
		clk_p=>clk_p, clk_n=>clk_n, data_p=>data_p, data_n=>data_n);

	objbuf: objectbuffer
		generic map (OBJECT_SIZE, PIXEL_SIZE)
		port map (pixclk,clear,video_active,pixel_x,pixel_y,background_rgb,font_rgb,video_data,Row,Col);
	
end rtl;
