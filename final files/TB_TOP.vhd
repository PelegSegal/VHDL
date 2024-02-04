ENTITY TB_TOP IS
END TB_TOP;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
LIBRARY work;

ARCHITECTURE struct OF TB_TOP IS
   SIGNAL reset  	 :STD_LOGIC;
   SIGNAL clock  	 :STD_LOGIC;
   SIGNAL PORT_LEDR  :STD_LOGIC_VECTOR( 7 DOWNTO 0 );
   SIGNAL PORT_HEX0  :STD_LOGIC_VECTOR( 6 DOWNTO 0 );
   SIGNAL PORT_HEX1  :STD_LOGIC_VECTOR( 6 DOWNTO 0 );
   SIGNAL PORT_HEX2  :STD_LOGIC_VECTOR( 6 DOWNTO 0 );
   SIGNAL PORT_HEX3  :STD_LOGIC_VECTOR( 6 DOWNTO 0 );
   SIGNAL PORT_HEX4  :STD_LOGIC_VECTOR( 6 DOWNTO 0 );
   SIGNAL PORT_HEX5  :STD_LOGIC_VECTOR( 6 DOWNTO 0 );
   SIGNAL PORT_SW 	 :STD_LOGIC_VECTOR( 9 DOWNTO 0 );
   SIGNAL PORT_KEY   :STD_LOGIC_VECTOR( 3 DOWNTO 0 );
  
   COMPONENT TOP
   generic( modelsim:	boolean := TRUE;
			address_width: integer := 8);		
	PORT( clock							:IN  STD_LOGIC; 
		  KEYS							:IN	 STD_LOGIC_VECTOR(3 downto 0);
		  LEDR							:OUT STD_LOGIC_VECTOR(7 downto 0);
		  HEX0							:OUT STD_LOGIC_VECTOR(6 downto 0);
		  HEX1							:OUT STD_LOGIC_VECTOR(6 downto 0);
		  HEX2							:OUT STD_LOGIC_VECTOR(6 downto 0);
		  HEX3							:OUT STD_LOGIC_VECTOR(6 downto 0);
		  HEX4							:OUT STD_LOGIC_VECTOR(6 downto 0);
		  HEX5							:OUT STD_LOGIC_VECTOR(6 downto 0);
		  SW							:IN  STD_LOGIC_VECTOR(9 downto 0)); 
   END COMPONENT;
   
   COMPONENT TOP_tester
   PORT( 		clock					:OUT 	STD_LOGIC; 
				PORT_LEDR				:IN 	STD_LOGIC_VECTOR(7 downto 0);
				PORT_HEX0				:IN 	STD_LOGIC_VECTOR(6 downto 0);
				PORT_HEX1				:IN 	STD_LOGIC_VECTOR(6 downto 0);
				PORT_HEX2				:IN 	STD_LOGIC_VECTOR(6 downto 0);
				PORT_HEX3				:IN 	STD_LOGIC_VECTOR(6 downto 0);
				PORT_HEX4				:IN 	STD_LOGIC_VECTOR(6 downto 0);
				PORT_HEX5				:IN 	STD_LOGIC_VECTOR(6 downto 0);
				PORT_SW					:OUT 	STD_LOGIC_VECTOR(9 downto 0);
				PORT_KEY				:OUT 	STD_LOGIC_VECTOR(3 downto 0));
   END COMPONENT;

   -- Optional embedded configurations
   -- pragma synthesis_off
   FOR ALL : Top USE ENTITY work.Top;
   FOR ALL : TOP_tester USE ENTITY work.TOP_tester;
   -- pragma synthesis_on
   
BEGIN
   U_0 : Top
	generic map(modelsim		=>	TRUE,
				address_width	=> 	8)
      PORT MAP (
		 clock      	=> clock,
		 LEDR  			=> PORT_LEDR,
         HEX0  			=> PORT_HEX0,
         HEX1  			=> PORT_HEX1,
         HEX2  			=> PORT_HEX2,
         HEX3  			=> PORT_HEX3,
		 HEX4  			=> PORT_HEX4,
         HEX5  			=> PORT_HEX5,
         SW    			=> PORT_SW,
		 KEYS			=> PORT_KEY);
	  
   U_1 : TOP_tester
      PORT MAP (
		 clock      	=> clock,
		 PORT_LEDR  	=> PORT_LEDR,
         PORT_HEX0  	=> PORT_HEX0,
         PORT_HEX1  	=> PORT_HEX1,
         PORT_HEX2  	=> PORT_HEX2,
         PORT_HEX3  	=> PORT_HEX3,
		 PORT_HEX4  	=> PORT_HEX4,
         PORT_HEX5  	=> PORT_HEX5,
         PORT_SW    	=> PORT_SW,
		 PORT_KEY		=> PORT_KEY);

END struct;
