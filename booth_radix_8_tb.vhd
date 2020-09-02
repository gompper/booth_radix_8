library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;			 

entity tb_booth_radix_8_struct is
end tb_booth_radix_8_struct;

architecture tb of tb_booth_radix_8_struct is

    component booth_radix_8
        port (Ny   : in std_logic_vector (7 downto 0);
              Nx   : in std_logic_vector (7 downto 0);
              prod : out std_logic_vector (13 downto 0);
			  reset: in std_logic;
              clk  : in std_logic);
    end component;

    signal Ny   : std_logic_vector (7 downto 0);
    signal Nx   : std_logic_vector (7 downto 0);
    signal prod : std_logic_vector (13 downto 0);
    signal clk  : std_logic;
    signal reset  : std_logic;

    constant TbPeriod : time := 10 ns; -- EDIT Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : booth_radix_8
    port map (Ny   => Ny,
              Nx   => Nx,
              prod => prod,
              clk  => clk,
			  reset => reset);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- EDIT: Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- EDIT Adapt initialization as needed
        Ny <= (others => '0');
        Nx <= (others => '0');
		reset <= '1';
		wait for TbPeriod;
		reset <= '0';

		Ny <= std_logic_vector(to_signed(4,Ny'length));
		Nx <= std_logic_vector(to_signed(9,Nx'length));

		 wait for 2*TbPeriod;
		
		Ny <= std_logic_vector(to_signed(6,Ny'length));
		Nx <= std_logic_vector(to_signed(11,Nx'length));

		wait for 2*TbPeriod;
		
		 Ny <= std_logic_vector(to_signed(-7,Ny'length));
		 Nx <= std_logic_vector(to_signed(-12,Nx'length));
		
		wait for 2*TbPeriod;
		
		Ny <= std_logic_vector(to_signed(-18,Ny'length));
		Nx <= std_logic_vector(to_signed(17,Nx'length));

        -- EDIT Add stimuli here
        wait for 100 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;