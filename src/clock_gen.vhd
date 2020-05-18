library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity clock_gen is
	port(
		clk_i  : in  std_logic; --  input clock
		clk0_o : out std_logic; -- serial clock
		clk1_o : out std_logic  --  pixel clock
	);
end clock_gen;

architecture rtl of clock_gen is

	signal pllclk0, pllclk1 : std_logic;
	signal clkfbout : std_logic;
	
	type pll_settings is record
	    CLKIN_PERIOD : real;  -- input clock period
		CLK_MULTIPLY : integer;      -- multiplier
		CLK_DIVIDE   : integer;      -- divider
		CLKOUT0_DIV  : integer;      -- serial clock divider
		CLKOUT1_DIV  : integer;      -- pixel clock divider
	end record;   
    
	constant WVGA_CLOCK : pll_settings := (
	    CLKIN_PERIOD => 8.000,  -- input clock period (8ns)
		CLK_MULTIPLY => 48 ,      -- multiplier
		CLK_DIVIDE   => 5 ,      -- divider
		CLKOUT0_DIV  => 8,      -- serial clock divider
		CLKOUT1_DIV  => 40     -- pixel clock divider
	);

	
begin

	-- buffer output clocks
	clk0buf: BUFG port map (I=>pllclk0, O=>clk0_o);
	clk1buf: BUFG port map (I=>pllclk1, O=>clk1_o);

	clock: PLLE2_BASE generic map (
		clkin1_period  => WVGA_CLOCK.CLKIN_PERIOD,
		clkfbout_mult  => WVGA_CLOCK.CLK_MULTIPLY,
		clkout0_divide => WVGA_CLOCK.CLKOUT0_DIV,
		clkout1_divide => WVGA_CLOCK.CLKOUT1_DIV,
		divclk_divide  => WVGA_CLOCK.CLK_DIVIDE
	)
	port map(
		rst      => '0',
		pwrdwn   => '0',
		clkin1   => clk_i,
		clkfbin  => clkfbout,
		clkfbout => clkfbout,
		clkout0  => pllclk0,
		clkout1  => pllclk1
	);
	
end rtl;
