LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY FA IS
	PORT( 
		x , y , ci : IN STD_LOGIC;
		s , co : OUT STD_LOGIC 
		);
	end FA;

ARCHITECTURE Behavioral OF FA IS

BEGIN

	s <= (( x xor y) xor ci);
	co <= (x and y) xor (ci and (x xor y));
	
end Behavioral ;