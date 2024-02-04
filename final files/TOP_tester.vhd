LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY TOP_tester IS
   PORT( 		clock							:OUT 	STD_LOGIC; 
				PORT_LEDR						:IN 	STD_LOGIC_VECTOR(7 downto 0);
				PORT_HEX0						:IN 	STD_LOGIC_VECTOR(6 downto 0);
				PORT_HEX1						:IN 	STD_LOGIC_VECTOR(6 downto 0);
				PORT_HEX2						:IN 	STD_LOGIC_VECTOR(6 downto 0);
				PORT_HEX3						:IN 	STD_LOGIC_VECTOR(6 downto 0);
				PORT_HEX4						:IN 	STD_LOGIC_VECTOR(6 downto 0);
				PORT_HEX5						:IN 	STD_LOGIC_VECTOR(6 downto 0);
				PORT_SW							:OUT 	STD_LOGIC_VECTOR(9 downto 0);
				PORT_KEY						:OUT 	STD_LOGIC_VECTOR(3 downto 0));
END TOP_tester ;

ARCHITECTURE struct OF TOP_tester IS

   SIGNAL U_0_clk        	:std_logic;
   SIGNAL disable_U_0_clk :boolean := FALSE;
   SIGNAL U_1_trigger 		:std_logic :='1';
   SIGNAL KEYS		 		:STD_LOGIC_VECTOR(2 downto 0);
   SIGNAL reset 	  		:std_logic;
BEGIN

	u_0clk_proc: PROCESS
   BEGIN
      WHILE NOT disable_U_0_clk LOOP
         U_0_clk <= '0', '1' AFTER 50 ns;
         WAIT FOR 100 ns;
      END LOOP;
      WAIT;
	END PROCESS u_0clk_proc;
   disable_U_0_clk <= TRUE AFTER 10000000 ns;
   clock <= U_0_clk;

   u_1_initiate: PROCESS
   BEGIN
      U_1_trigger <= '1',
					 '0' AFTER 20 ns,
                     '1' AFTER 120 ns;
      WAIT;
    END PROCESS u_1_initiate;
	reset <= U_1_trigger;
   
   push_keys: process
   BEGIN
   KEYS <= "111",
   "110" AFTER 2000 ns, --key1
   "111" AFTER 4000 ns,
   "101" AFTER 5000 ns, --key2 
   "111" AFTER 7000 ns,
   "011" AFTER 8000 ns, --key3 
   "111" AFTER 10000 ns;
   wait;
   end process push_keys;
   
   PORT_KEY <= KEYS & reset;
   
   SW_proc: process
   BEGIN
   PORT_SW <= "1000000001";   
   wait;
   end process SW_proc;
   
END struct;
