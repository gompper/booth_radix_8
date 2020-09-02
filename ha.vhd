LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY HA IS
	PORT ( 
		x , y : IN STD_LOGIC;
		s , c : OUT STD_LOGIC 
	);
end HA;

ARCHITECTURE Behavioral OF HA IS

BEGIN

s <= x xor y;
c <= x and y;

end Behavioral ;