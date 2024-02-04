
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY Port_Output_Interface IS
	PORT(	clock		:IN	 STD_LOGIC;
			reset		:IN	 STD_LOGIC;
			cs 			:IN  STD_LOGIC;
        	MemWrite 	:IN	 STD_LOGIC;
			Datain		:IN	 STD_LOGIC_VECTOR(7 downto 0);
			Dataout		:OUT STD_LOGIC_VECTOR(7 downto 0));
END Port_Output_Interface;

ARCHITECTURE behavior OF Port_Output_Interface IS
	SIGNAL Choose:	STD_LOGIC;
BEGIN
	Choose	<= '1' when (cs = '1' and MemWrite = '1') else '0';
	process 
	begin
		wait until(clock'EVENT ) and (clock = '1');
		if reset = '1' then Dataout  <= X"00";
		else
			if Choose = '1' then Dataout  <=  Datain;
			end if;
		end if;
	end process;
END behavior;

