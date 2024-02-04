LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY GPIO IS
	PORT(	clock					:IN  STD_LOGIC;
			reset					:IN  STD_LOGIC;
			DataIN					:IN  STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			Address					:IN  STD_LOGIC_VECTOR( 11 DOWNTO 0 ); 
        	MemRead_Bus_GPIO		:IN  STD_LOGIC;
			MemWrite_Bus_GPIO		:IN	 STD_LOGIC;
			SW						:IN  STD_LOGIC_VECTOR(7 downto 0);
			CS_OUT					:OUT STD_LOGIC_VECTOR(17 downto 0);
			LR_dataOut 				:OUT STD_LOGIC_VECTOR(7 downto 0);
			HX0_dataOut 			:OUT STD_LOGIC_VECTOR(7 downto 0);
			HX1_dataOut 			:OUT STD_LOGIC_VECTOR(7 downto 0);
			HX2_dataOut 			:OUT STD_LOGIC_VECTOR(7 downto 0);
			HX3_dataOut 			:OUT STD_LOGIC_VECTOR(7 downto 0);
			HX4_dataOut 			:OUT STD_LOGIC_VECTOR(7 downto 0);
			HX5_dataOut 			:OUT STD_LOGIC_VECTOR(7 downto 0);
			DataOut_Bus 			:OUT STD_LOGIC_VECTOR(31 downto 0));
END GPIO;

ARCHITECTURE behavior OF GPIO IS

COMPONENT Port_Output_Interface IS
	PORT(	clock		:IN	 STD_LOGIC;
			reset		:IN	 STD_LOGIC;
			cs 			:IN  STD_LOGIC;
        	MemWrite 	:IN	 STD_LOGIC;
			Datain		:IN	 STD_LOGIC_VECTOR(7 downto 0);
			Dataout		:OUT STD_LOGIC_VECTOR(7 downto 0));
END COMPONENT;

COMPONENT Decoder_CS IS
	PORT   (Address 			:IN  STD_LOGIC_VECTOR (3 DOWNTO 0); -- A5,A4,A3,A2
			eight_hundred		:IN  STD_LOGIC; 					-- A11
			CS					:OUT STD_LOGIC_VECTOR (17 downto 0));
END COMPONENT;

	-----------------------GPIO SIGNALS--------------------------
	SIGNAL 	CS					:STD_LOGIC_VECTOR(17 downto 0);
	SIGNAL  SW_Out				:STD_LOGIC_VECTOR(7 downto 0);
	SIGNAL cs_hex0				:STD_LOGIC;
	SIGNAL cs_hex1				:STD_LOGIC;
	SIGNAL cs_hex2				:STD_LOGIC;
	SIGNAL cs_hex3				:STD_LOGIC;
	SIGNAL cs_hex4				:STD_LOGIC;
	SIGNAL cs_hex5				:STD_LOGIC;

BEGIN

cs_hex0 <= cs(1) and (not(Address(0)));
cs_hex1 <= cs(1) and Address(0);
cs_hex2 <= cs(3) and (not(Address(0)));
cs_hex3 <= cs(3) and Address(0);
cs_hex4 <= cs(5) and (not(Address(0)));
cs_hex5 <= cs(5) and Address(0);

CS_Decoder: Decoder_CS
	PORT MAP   (Address 			=> Address(5 downto 2),
				eight_hundred		=> Address(11),
				CS		 			=> CS);

LED_R:		Port_Output_Interface
	PORT MAP   (clock 	 => clock,
				reset	 => reset,
				cs		 => cs(0),
				MemWrite => MemWrite_Bus_GPIO,
				Datain   => DataIN(7 DOWNTO 0),
				Dataout	 => LR_dataOut);

HEX_0:		Port_Output_Interface
	PORT MAP   (clock 	 => clock,
				reset	 => reset,
				cs		 => cs_hex0,
				MemWrite => MemWrite_Bus_GPIO,
				Datain   => DataIN(7 DOWNTO 0),
				Dataout	 => HX0_dataOut);

HEX_1:		Port_Output_Interface
	PORT MAP   (clock 	 => clock,
				reset	 => reset,
				cs		 => cs_hex1,
				MemWrite => MemWrite_Bus_GPIO,
				Datain   => DataIN(7 DOWNTO 0),
				Dataout	 => HX1_dataOut);

HEX_2:		Port_Output_Interface
	PORT MAP   (clock 	 => clock,
				reset	 => reset,
				cs		 => cs_hex2,
				MemWrite => MemWrite_Bus_GPIO,
				Datain   => DataIN(7 DOWNTO 0),
				Dataout	 => HX2_dataOut);

HEX_3:		Port_Output_Interface
	PORT MAP   (clock 	 => clock,
				reset	 => reset,
				cs		 => cs_hex3,
				MemWrite => MemWrite_Bus_GPIO,
				Datain   => DataIN(7 DOWNTO 0),
				Dataout	 => HX3_dataOut);
				
HEX_4:		Port_Output_Interface
	PORT MAP   (clock 	 => clock,
				reset	 => reset,
				cs		 => cs_hex4,
				MemWrite => MemWrite_Bus_GPIO,
				Datain   => DataIN(7 DOWNTO 0),
				Dataout	 => HX4_dataOut);

HEX_5:		Port_Output_Interface
	PORT MAP   (clock 	 => clock,
				reset	 => reset,
				cs		 => cs_hex5,
				MemWrite => MemWrite_Bus_GPIO,
				Datain   => DataIN(7 DOWNTO 0),
				Dataout	 => HX5_dataOut);

SW_Out <= SW WHEN (cs(7) AND MemRead_Bus_GPIO) ='1' ELSE X"00";
DataOut_Bus <= X"000000" & SW_Out;
CS_OUT <= CS;

END behavior;

