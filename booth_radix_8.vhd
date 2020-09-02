-- Author 	: Urs Gompper
-- Date 	: 06-29-2020 

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity booth_radix_8 is
    Port( Ny 	: in  	std_logic_vector(7 downto 0);
          Nx 	: in 	std_logic_vector(7 downto 0);
		  prod 	: out	std_logic_vector(13 downto 0);
          clk 	: in 	std_logic;
		  reset : in 	std_logic
          );
  end booth_radix_8;

architecture behavioral of booth_radix_8 is

    COMPONENT FA -- Full Adder
        PORT(
		x , y , ci : IN STD_LOGIC ;
		s , co : OUT STD_LOGIC 
        );
    END COMPONENT;
	
	COMPONENT HA -- Half Adder
        PORT(
		x , y  : IN STD_LOGIC ;
		s , c : OUT STD_LOGIC 
        );
    END COMPONENT;

type action_array is array (0 to 2) of std_logic_vector(7 downto 0);
type control_array is array (0 to 2) of std_logic_vector(3 downto 0); 

signal Nx_comp 	: std_logic_vector(7 downto 0);
signal action 	: action_array;
signal control 	: control_array; 
signal pp1 : std_logic_vector(13 downto 0) := (others=>'0');
signal pp2 : std_logic_vector(10 downto 0) := (others=>'0');
signal N_x : std_logic_vector(13 downto 0) := (others=>'0');
signal N_y : std_logic_vector(10 downto 0) := (others=>'0');
signal N_z : std_logic_vector(7 downto 0) := (others=>'0');
signal c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,cout : std_logic := '0';

begin

-- 
process(clk,reset)
begin
	if reset = '1' then
		for i in 0 to 2 loop
			action(i)  <= (others => '0');
			control(i) <= (others => '0');
		end loop;
		Nx_comp <= (others=>'0');
	elsif rising_edge(clk) then 
		for i in 0 to 2 loop
			case control(i) is
				when "0000" => action(i) <= (others =>'0');
				when "0001" => action(i) <= Nx;
				when "0010" => action(i) <= Nx;
				when "0011" => action(i) <= Nx(6 downto 0) & '0'; -- 2*Nx
				when "0100" => action(i) <= Nx(6 downto 0) & '0'; -- 2*Nx
				when "0101" => action(i) <= std_logic_vector(signed(Nx) + signed(Nx) + signed(Nx)); -- 3*Nx
				when "0110" => action(i) <= std_logic_vector(signed(Nx) + signed(Nx) + signed(Nx)); -- 3*Nx
				when "0111" => action(i) <= Nx(5 downto 0) & "00"; -- 4*Nx
				when "1000" => action(i) <= Nx_comp(5 downto 0) & "00"; -- 4*Nx_comp
				when "1001" => action(i) <= std_logic_vector(signed(Nx_comp) + signed(Nx_comp) + signed(Nx_comp)); -- 3*Nx_comp
				when "1010" => action(i) <= std_logic_vector(signed(Nx_comp) + signed(Nx_comp) + signed(Nx_comp)); -- 3*Nx_comp
				when "1011" => action(i) <= Nx_comp(6 downto 0) & '0'; -- 2*Nx_comp
				when "1100" => action(i) <= Nx_comp(6 downto 0) & '0'; -- 2*Nx_comp
				when "1101" => action(i) <= Nx_comp; -- Nx_comp
				when "1110" => action(i) <= Nx_comp; -- Nx_comp
				when "1111" => action(i) <= (others =>'0');
				when others => action(i) <=	(others =>'0');
			end case;
		end loop;
		Nx_comp <= std_logic_vector(unsigned(not(Nx)) + 1);
		if Ny(7) = '0' then
			control(2) <= '0' & Ny(7 downto 5); 
		else 
			control(2) <= '1' & Ny(7 downto 5);
		end if;
		control(1) <= Ny(5 downto 2);
		control(0) <= Ny(2 downto 0) & '0';
	end if;
end process;

-- arithmetic shifting
process(clk)
begin
	if reset = '1' then
		N_x <= (others=>'0');
		N_y <= (others=>'0');
		N_z <= (others=>'0');
	elsif rising_edge(clk) then
		if action(0)(7) = '0' then
			N_x <= "000000" & action(0);
		else
			N_x <= "111111" & action(0);
		end if;
		if action(1)(7) = '0' then
			N_y <= "000" & action(1);
		else
			N_y <= "111" & action(1);
		end if;
		N_z <= action(2);
	end if;
end process;

-- wallace tree
	pp1(5 downto 0) <= N_x(5 downto 0); 
	HA_0 : HA port map(N_x(6),N_y(3),pp1(6),pp2(4));
	FA_0 : FA port map(N_x(7),N_y(4),N_z(1),pp1(7),pp2(5));
	FA_1 : FA port map(N_x(8),N_y(5),N_z(2),pp1(8),pp2(6));
	FA_2 : FA port map(N_x(9),N_y(6),N_z(3),pp1(9),pp2(7));
	FA_3 : FA port map(N_x(10),N_y(7),N_z(4),pp1(10),pp2(8));
	FA_4 : FA port map(N_x(11),N_y(8),N_z(5),pp1(11),pp2(9));
	FA_5 : FA port map(N_x(12),N_y(9),N_z(6),pp1(12),pp2(10));
	FA_6 : FA port map(N_x(13),N_y(10),N_z(7),pp1(13)); 
	pp2(2 downto 0) <= N_y(2 downto 0); 
	pp2(3) 	<= N_z(0); 
	prod(2 downto 0) <= pp1(2 downto 0);
	HA_2 : HA port map(pp1(3),pp2(0),prod(3),c1);
	FA_7 : FA port map(pp1(4),pp2(1),c1,prod(4),c2);
	FA_8 : FA port map(pp1(5),pp2(2),c2,prod(5),c3);
	FA_9 : FA port map(pp1(6),pp2(3),c3,prod(6),c4);
	FA_10 : FA port map(pp1(7),pp2(4),c4,prod(7),c5);
	FA_11 : FA port map(pp1(8),pp2(5),c5,prod(8),c6);
	FA_12 : FA port map(pp1(9),pp2(6),c6,prod(9),c7);
	FA_13 : FA port map(pp1(10),pp2(7),c7,prod(10),c8);
	FA_14 : FA port map(pp1(11),pp2(8),c8,prod(11),c9);
	FA_15 : FA port map(pp1(12),pp2(9),c9,prod(12),c10);
	FA_16: FA port map(pp1(13),pp2(10),c10,prod(13),cout);	

end behavioral;