LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY Top IS
	GENERIC (modelsim : BOOLEAN := FALSE;		--set as default quartos
			 address_width : INTEGER	:= 10);
			  
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
END 	Top;

ARCHITECTURE structure OF Top IS

	COMPONENT MIPS IS
		generic(modelsim			: boolean := FALSE;
				 address_width 		: integer := 10);
		PORT( 	clock							:IN 	STD_LOGIC; 
				reset							:IN 	STD_LOGIC; 
				ena								:IN 	STD_LOGIC; 
				DataIn_Bus					    :IN		STD_LOGIC_VECTOR(31 DOWNTO 0);
				INTR							:IN 	STD_LOGIC; 
				AddrBus							:OUT	STD_LOGIC_VECTOR(11 DOWNTO 0);
				MemWrite_Bus_Mips				:OUT	STD_LOGIC;
				MemRead_Bus_Mips				:OUT	STD_LOGIC;
				DataOut_Bus						:OUT    STD_LOGIC_VECTOR(31 DOWNTO 0);
				GIE 							:OUT	STD_LOGIC;
				INTA							:OUT	STD_LOGIC);
	END 	COMPONENT;

	COMPONENT GPIO IS
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
	END COMPONENT;	
	
	COMPONENT interrupt IS
	  PORT ( clock					:IN  STD_LOGIC;
			 reset					:IN  STD_LOGIC;	
			 INTA					:IN  STD_LOGIC;
			 MemWrite				:IN  STD_LOGIC;
			 MemRead				:IN  STD_LOGIC;
			 GIE					:IN  STD_LOGIC;
			 CS						:IN  STD_LOGIC_VECTOR(17 DOWNTO 0);
			 irq0					:IN  STD_LOGIC; -- RX (UART)
			 irq1					:IN  STD_LOGIC; -- TX (UART)
			 irq2					:IN  STD_LOGIC; -- BT
			 irq3					:IN  STD_LOGIC; -- KEY1
			 irq4					:IN  STD_LOGIC; -- KEY2
			 irq5					:IN  STD_LOGIC; -- KEY3	
			 Address_Bus			:IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
			 DataBus_in				:IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
			 DataBus_out			:OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			 DataBus_EN_interrupt	:OUT STD_LOGIC;
			 INTR					:OUT STD_LOGIC);
	END COMPONENT;
	
	COMPONENT BasicTimer IS
	  PORT(	 reset     		  :IN std_logic;	
			 clock			  :IN std_logic; 
			 MemWrite		  :IN STD_LOGIC;
			 MemRead		  :IN STD_LOGIC;
			 CS				  :IN STD_LOGIC_VECTOR (17 DOWNTO 0);
			 DataBus_in		  :IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			 DataBus_out	  :OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			 DataBus_EN_timer :OUT STD_LOGIC;
			 Set_BTIFG		  :OUT STD_LOGIC;
			 Out_Signal		  :OUT STD_LOGIC);
	END COMPONENT;
	
	component BidirPin is
		generic (width: integer:= 32);
		port(   Dout    :in 		std_logic_vector(width-1 downto 0);
				en      :in 		std_logic;
				Din     :out		std_logic_vector(width-1 downto 0);
				IOpin   :inout 	std_logic_vector(width-1 downto 0));		
	end component;

	COMPONENT Hex_LCD IS
	  PORT (bin4: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			hex: OUT STD_LOGIC_VECTOR (6 DOWNTO 0));
	END COMPONENT;

	-----------------------MIPS SIGNALS--------------------------
		SIGNAL reset			:STD_LOGIC;	
		SIGNAL AddrBus			:STD_LOGIC_VECTOR(11 DOWNTO 0); -- address bus
		SIGNAL MemWrite			:STD_LOGIC;						-- control bus
		SIGNAL MemRead			:STD_LOGIC;						-- control bus
		SIGNAL DataOut_Mips		:STD_LOGIC_VECTOR(31 DOWNTO 0);
		SIGNAL DataIn_Mips		:STD_LOGIC_VECTOR(31 DOWNTO 0);
	-----------------------GPIO SIGNALS--------------------------
		SIGNAL CS				:STD_LOGIC_VECTOR(17 downto 0);
		SIGNAL HEX0_GPIO		:STD_LOGIC_VECTOR(7 downto 0);
		SIGNAL HEX1_GPIO		:STD_LOGIC_VECTOR(7 downto 0);
		SIGNAL HEX2_GPIO		:STD_LOGIC_VECTOR(7 downto 0);
		SIGNAL HEX3_GPIO		:STD_LOGIC_VECTOR(7 downto 0);
		SIGNAL HEX4_GPIO		:STD_LOGIC_VECTOR(7 downto 0);
		SIGNAL HEX5_GPIO		:STD_LOGIC_VECTOR(7 downto 0);
		SIGNAL DataBus_in_GPIO	:STD_LOGIC_VECTOR(31 downto 0);
		SIGNAL DataBus_out_GPIO	:STD_LOGIC_VECTOR(31 downto 0);
		SIGNAL EN_BUS_GPIO		:STD_LOGIC;
	--------------------------DATA BUS---------------------------
		SIGNAL BUS_DATA			:STD_LOGIC_VECTOR(31 downto 0);	-- data bus
	-------------------------INTERRUPT_CONTROLLER---------------	
		SIGNAL DataBus_in_INT	:STD_LOGIC_VECTOR(31 downto 0);
		SIGNAL DataBus_out_INT	:STD_LOGIC_VECTOR(31 downto 0);
		SIGNAL EN_DataBus_INT	:STD_LOGIC;
		SIGNAL irq3				:STD_LOGIC;	
		SIGNAL irq4				:STD_LOGIC;	
		SIGNAL irq5				:STD_LOGIC;	
		SIGNAL INTR_TOP			:STD_LOGIC;
		SIGNAL INTA_TOP			:STD_LOGIC;
		SIGNAL GIE_TOP 			:STD_LOGIC;
	-----------------------TIMER SIGNALS---------------------------
		SIGNAL DataIN_TIMER		:STD_LOGIC_VECTOR(31 downto 0);
		SIGNAL DataOUT_TIMER	:STD_LOGIC_VECTOR(31 downto 0);
		SIGNAL EN_BUS_TIMER		:STD_LOGIC;
		SIGNAL PWM				:STD_LOGIC;
		SIGNAL BT_TOP			:STD_LOGIC;	
		
begin
		EN_BUS_GPIO <= MemRead and CS(7);
	 	reset       <= NOT KEYS(0);
		irq3		<= NOT KEYS(1);
		irq4		<= NOT KEYS(2);
		irq5		<= NOT KEYS(3);
		
Mips_Single: MIPS
	generic map(	modelsim			=>	modelsim,
					address_width		=> 	address_width)
	port map(		clock				=>	clock,
					reset				=>	reset,
					ena					=>  SW(9),
					DataIn_Bus		    =>	DataIn_Mips,
					INTR 				=>  INTR_TOP,
					AddrBus				=>	AddrBus,
					MemWrite_Bus_Mips   =>	MemWrite,
					MemRead_Bus_Mips	=>	MemRead,
					DataOut_Bus			=>	DataOut_Mips,
					GIE 				=>  GIE_TOP,
					INTA 				=>  INTA_TOP);
					
GP_IO:	GPIO
	port map(		clock				=>	clock,
					reset				=>	reset,
					DataIN				=>	DataBus_in_GPIO,
					Address				=>	AddrBus,
					MemRead_Bus_GPIO	=>	MemRead,
					MemWrite_Bus_GPIO	=>	MemWrite,
					SW					=>	SW(7 DOWNTO 0),
					CS_OUT				=>	CS,
					LR_dataOut			=>	LEDR,
					HX0_dataOut			=>	HEX0_GPIO,
					HX1_dataOut			=>	HEX1_GPIO,
					HX2_dataOut			=>	HEX2_GPIO,
					HX3_dataOut			=>	HEX3_GPIO,
					HX4_dataOut 		=>	HEX4_GPIO,
					HX5_dataOut 		=>	HEX5_GPIO,
					DataOut_Bus			=>	DataBus_out_GPIO);

INTERRUPT_CONTROLLER: interrupt
	port map(       clock				=>  clock,
					reset				=>	reset,
					INTA				=>  INTA_TOP,	
					MemWrite			=>  MemWrite,	
					MemRead				=>	MemRead,
					GIE					=>  GIE_TOP,
					CS					=>	CS,	
					irq0				=>  '0',
					irq1				=>  '0',	
					irq2				=>  BT_TOP,	
					irq3				=>	irq3,
					irq4				=>  irq4,
					irq5				=>	irq5,
					Address_Bus			=>	AddrBus,
					DataBus_in			=>	DataBus_in_INT,
					DataBus_out			=>  DataBus_out_INT,
					DataBus_EN_interrupt=>	EN_DataBus_INT,
					INTR				=>  INTR_TOP);		
						
Basic_Timer: BasicTimer
	port map(		reset 				=>	reset,
					clock				=>	clock,
					MemWrite			=>	MemWrite,
					MemRead				=>	MemRead,
					CS					=>	CS,
					DataBus_out			=>  DataOUT_TIMER,
					DataBus_in			=>	DataIN_TIMER,
					DataBus_EN_timer	=>	EN_BUS_TIMER,
					Set_BTIFG			=>	BT_TOP,
					Out_Signal			=>	PWM);
					
	-- converter from hex to hex on quartos LCD --
HX0_conv: Hex_LCD
	port map(HEX0_GPIO(3 downto 0), HEX0);
	
HX1_conv: Hex_LCD
	port map(HEX1_GPIO(3 downto 0), HEX1);
	
HX2_conv: Hex_LCD
	port map(HEX2_GPIO(3 downto 0), HEX2);
	
HX3_conv: Hex_LCD
	port map(HEX3_GPIO(3 downto 0), HEX3);
	
HX4_conv: Hex_LCD
	port map(HEX4_GPIO(3 downto 0), HEX4);
	
HX5_conv: Hex_LCD
	port map(HEX5_GPIO(3 downto 0), HEX5);

	-- tristate to Data Bus (mips/gpio/interrupt/timer) --
mips_data_bus 	: BidirPin
	generic map (32)
	port map	( Dout	=>	DataOut_Mips,
				  en	=>	MemWrite,
				  Din	=>	DataIn_Mips,
				  IOpin	=>	BUS_DATA);
				  
GPIO_bus : BidirPin 								
	generic map (32)
	port map	( Dout	=>	DataBus_out_GPIO,
				  en	=>	EN_BUS_GPIO,
				  Din	=>	DataBus_in_GPIO,
				  IOpin	=>	BUS_DATA);

INTERRUPT_bus : BidirPin
	generic map (32)
	port map	( Dout	=>	DataBus_out_INT,
				  en	=>	EN_DataBus_INT,
				  Din	=>	DataBus_in_INT,
				  IOpin	=>	BUS_DATA);
				  
TIMER_bus : BidirPin
	generic map (32)
	port map	( Dout	=>	DataOUT_TIMER,
				  en	=>	EN_BUS_TIMER,
				  Din	=>	DataIN_TIMER,
				  IOpin	=>	BUS_DATA);
end structure;