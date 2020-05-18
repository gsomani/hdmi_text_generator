library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timing_generator is
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
end timing_generator;

architecture rtl of timing_generator is

	type video_timing_type is record
		H_VIDEO : integer;
		H_FP    : integer;
		H_SYNC  : integer;
		H_BP    : integer;
		H_TOTAL : integer;
		V_VIDEO : integer;
		V_FP    : integer;
		V_SYNC  : integer;
		V_BP    : integer;
		V_TOTAL : integer;
		H_POL   : std_logic;
		V_POL   : std_logic;
		ACTIVE  : std_logic;
	end record;

	constant WVGA_TIMING : video_timing_type := (
		H_VIDEO =>  800,
		H_FP    =>   40,
		H_SYNC  =>   48,
		H_BP    =>   40,
		H_TOTAL =>  928,
		V_VIDEO =>  480,
		V_FP    =>   13,
		V_SYNC  =>    3,
		V_BP    =>   29,
		V_TOTAL =>  525,
		H_POL   =>  '0',
		V_POL   =>  '0',
		ACTIVE  =>  '1'
	);

	-- horizontal and vertical counters
	signal hcount : unsigned(OBJECT_SIZE-1 downto 0) := (others => '0');
	signal vcount : unsigned(OBJECT_SIZE-1 downto 0) := (others => '0');
	signal timings : video_timing_type := WVGA_TIMING;

begin

	timings <= WVGA_TIMING;

	-- pixel counters
	process (clk) is
	begin
		if rising_edge(clk) then
			if (hcount = timings.H_TOTAL) then
				hcount <= (others => '0');
				if (vcount = timings.V_TOTAL) then
					vcount <= (others => '0');
				else
					vcount <= vcount + 1;
				end if;
			else
				hcount <= hcount + 1;
			end if;
		end if;
	end process;

	-- generate video_active, hsync, and vsync signals based on the counters
	video_active <= timings.ACTIVE when (hcount < timings.H_VIDEO) and (vcount < timings.V_VIDEO ) else not timings.ACTIVE;
	hsync <= timings.H_POL when (hcount >= timings.H_VIDEO + timings.H_FP) and (hcount < timings.H_TOTAL - timings.H_BP) else not timings.H_POL;
	vsync <= timings.V_POL when (vcount >= timings.V_VIDEO + timings.V_FP) and (vcount < timings.V_TOTAL - timings.V_BP) else not timings.V_POL;

	-- send pixel locations
	pixel_x <= std_logic_vector(hcount + 1) when hcount < (timings.H_VIDEO - 1) else (others => '0');
	pixel_y <= std_logic_vector(vcount + 1) when vcount < (timings.V_VIDEO - 1) else (others => '0');
	
end rtl;