				-- Top Level Structural Model for MIPS Processor Core
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY MIPS IS
	generic( modelsim			: boolean := FALSE;
			 address_width 		: integer := 10);
	PORT( 	clock							: IN 	STD_LOGIC; 
			reset							: IN 	STD_LOGIC; 
			ena								: IN 	STD_LOGIC; 
			DataIn_Bus					    : IN	STD_LOGIC_VECTOR(31 DOWNTO 0);
			INTR							: IN 	STD_LOGIC; 
			AddrBus							: OUT	STD_LOGIC_VECTOR(11 DOWNTO 0);
			MemWrite_Bus_Mips				: OUT	STD_LOGIC;
			MemRead_Bus_Mips				: OUT	STD_LOGIC;
		    DataOut_Bus						: OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
			GIE 							: OUT	STD_LOGIC;
			INTA							: OUT	STD_LOGIC);
END 	MIPS;
	
ARCHITECTURE structure OF MIPS IS

	COMPONENT Ifetch IS
		generic(modelsim : boolean;
				address_width : integer);
		PORT(	SIGNAL Instruction 		: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
				SIGNAL PC_plus_4_out 	: OUT	STD_LOGIC_VECTOR(9 DOWNTO 0);
				SIGNAL reset 			: IN 	STD_LOGIC;
				SIGNAL clock			: IN 	STD_LOGIC;
				SIGNAL ena			 	: IN 	STD_LOGIC;
				SIGNAL Add_result 		: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
				SIGNAL read_data_mem 	: IN 	STD_LOGIC_VECTOR(7 DOWNTO 0);
				SIGNAL read_data1 		: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
				SIGNAL intr_flag 		: IN 	STD_LOGIC;
				SIGNAL beq	 			: IN 	STD_LOGIC;
				SIGNAL bne 				: IN 	STD_LOGIC;
				SIGNAL Zero 			: IN 	STD_LOGIC;
				SIGNAL J_adress			: IN 	STD_LOGIC_VECTOR(7 downto 0);
				SIGNAL J			 	: IN 	STD_LOGIC;
				SIGNAL JR			 	: IN 	STD_LOGIC;
				SIGNAL PC_out 			: OUT	STD_LOGIC_VECTOR(9 DOWNTO 0));
	END COMPONENT;

	COMPONENT Idecode IS
		  PORT(	read_data_1		: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
				read_data_2		: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
				reset			: IN 	STD_LOGIC;
				clock			: IN 	STD_LOGIC;
				Instruction 	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
				read_data 		: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
				ALU_result		: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
				RegWrite 		: IN 	STD_LOGIC;
				MemtoReg 		: IN 	STD_LOGIC;
				RegDst 			: IN 	STD_LOGIC;
				PC_plus_4_out 	: IN	STD_LOGIC_VECTOR(9 DOWNTO 0);
				PC 				: IN	STD_LOGIC_VECTOR(9 DOWNTO 0);
				intr_flag       : IN  	STD_LOGIC;
				JAL       		: IN  	STD_LOGIC;
				Sign_extend 	: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
				GIE 			: OUT	STD_LOGIC);
				
	END COMPONENT;

	COMPONENT control IS
	   PORT( 	
		Opcode 			: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
		clock			: IN 	STD_LOGIC;
		reset			: IN 	STD_LOGIC; 
		Instruction		: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0); 
		intr_flag		: IN	STD_LOGIC;					   
		RegDst 			: OUT 	STD_LOGIC;
		ALUSrc 			: OUT 	STD_LOGIC;
		MemtoReg 		: OUT 	STD_LOGIC;
		RegWrite 		: OUT 	STD_LOGIC;
		MemRead 		: OUT 	STD_LOGIC;
		MemWrite 		: OUT 	STD_LOGIC;
		Beq 			: OUT 	STD_LOGIC;
		Bne				: OUT 	STD_LOGIC;
		ALUop 			: OUT 	STD_LOGIC_VECTOR(5 DOWNTO 0);
		J				: OUT   STD_LOGIC;
		JAL 			: OUT 	STD_LOGIC;
		JR   			: OUT 	STD_LOGIC;
		shl_sig			: OUT 	STD_LOGIC;
		shr_sig			: OUT 	STD_LOGIC);
	END COMPONENT;

	COMPONENT  Execute IS
		PORT(	Read_data_1 	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
				Read_data_2 	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
				Sign_extend 	: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
				Function_opcode : IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
				ALUOp 			: IN 	STD_LOGIC_VECTOR(5 DOWNTO 0);
				ALUSrc 			: IN 	STD_LOGIC;
				Zero 			: OUT	STD_LOGIC;
				ALU_Result 		: OUT	STD_LOGIC_VECTOR(31 DOWNTO 0);
				Add_Result 		: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
				PC_plus_4 		: IN 	STD_LOGIC_VECTOR(9 DOWNTO 0);
				clock			: IN 	STD_LOGIC;
				reset			: IN 	STD_LOGIC;
				shift_num 		: IN 	STD_LOGIC_VECTOR(4 DOWNTO 0);
				shl_sig			: IN	STD_LOGIC;
				shr_sig			: IN	STD_LOGIC);
	END COMPONENT;

	COMPONENT dmemory
		 generic(address_width:integer);
	     PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR(31 DOWNTO 0);
        		address 			: IN 	STD_LOGIC_VECTOR(address_width-1 DOWNTO 0);
        		write_data 			: IN 	STD_LOGIC_VECTOR(31 DOWNTO 0);
        		MemRead, Memwrite 	: IN 	STD_LOGIC;
        		Clock,reset			: IN 	STD_LOGIC);
	END COMPONENT;

					-- declare signals used to connect VHDL components
	SIGNAL PC_plus_4 		: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL read_data_1 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL read_data_2 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Sign_Extend 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL Add_result 		: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL ALU_result 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL read_data 		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL read_data_mem 	: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL ALUSrc 			: STD_LOGIC;
	SIGNAL RegDst 			: STD_LOGIC;
	SIGNAL Regwrite 		: STD_LOGIC;
	SIGNAL Zero 			: STD_LOGIC;
	SIGNAL MemWrite 		: STD_LOGIC;
	SIGNAL MemtoReg 		: STD_LOGIC;
	SIGNAL MemRead 			: STD_LOGIC;
	SIGNAL beq	 			: STD_LOGIC;
	SIGNAL bne	 			: STD_LOGIC;
	SIGNAL J	 			: STD_LOGIC;	
	SIGNAL JR	 			: STD_LOGIC;
	SIGNAL JAL	 			: STD_LOGIC;	
	SIGNAL shl_sig 			: STD_LOGIC;
	SIGNAL shr_sig 			: STD_LOGIC;
	SIGNAL MemWrite_Dmemory	: STD_LOGIC;
	SIGNAL MemRead_Dmemory	: STD_LOGIC;
	SIGNAL ALUop 			: STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL Instruction		: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL mem_addr			: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL EOI				: STD_LOGIC;
	SIGNAL intr_flag		: STD_LOGIC := '0';
	SIGNAL PC_sig			: STD_LOGIC_VECTOR(9 downto 0);	
    SIGNAL mem_addr_Q	    : STD_LOGIC_VECTOR(9 DOWNTO 0);
	
BEGIN
   -- write enable to bus/memory (ALU_Result(11) => ~800 address)
   MemWrite_Dmemory		<= MemWrite and (not ALU_Result(11));
   MemWrite_Bus_Mips	<= MemWrite and ALU_Result(11); 
   
    -- read enable to bus/memory (ALU_Result(11) => ~800 address)
   MemRead_Dmemory		<= MemRead and (not ALU_Result(11));
   MemRead_Bus_Mips		<= MemRead and ALU_Result(11);
   
   -- data out: from MIPS to the Data Bus 
   DataOut_Bus			<= read_data_2; 

   -- data out: from MIPS to the Address Bus
   AddrBus 				<= ALU_Result(11 downto 0);
 
   -- Chose data in from the bus or CPU
   read_data       		<=   DataIn_Bus WHEN (MemRead and ALU_Result(11)) = '1' ELSE read_data_mem;	-- select data to Register File (decode) 
   mem_addr				<=   ALU_Result (9 DOWNTO 2) WHEN intr_flag = '0' ELSE DataIn_Bus (9 downto 2); -- select memory address (changes in case of interrupt)
   mem_addr_Q        	<=   mem_addr & "00" ;  -- memory address to quartos
   
   -- interrupt
   EOI                  <= '1' WHEN (instruction(25 DOWNTO 21) = "11011" and (JAL) = '1') ELSE '0'; -- EOI (when we JAL back from interrupt - $27
   INTA                 <= intr_flag;
   PROCESS(clock)
	BEGIN
		IF RISING_EDGE(clock) THEN
			if (intr_flag = '1') then intr_flag <= '0'; -- getting ready to the next interrupt 
			elsif (INTR = '1') then intr_flag <= '1';   -- to make INTA=1, initalize IFG after interrupt
			elsif (EOI = '1') then intr_flag <= '0';	-- INTA=0 at end of interrupt			
			end if;
		END IF;
	END PROCESS;

					-- connect the 5 MIPS components   
  IFE : Ifetch
	generic map (modelsim 		=> modelsim,
				address_width 	=> address_width)
	PORT MAP (	Instruction 	=> Instruction,
    	    	PC_plus_4_out 	=> PC_plus_4,
				reset 			=> reset,
				clock 			=> clock,
				ena				=> ena,
				Add_result 		=> Add_result,
				read_data_mem   => read_data_mem (9 DOWNTO 2),
				read_data1		=> read_data_1,
				intr_flag		=> intr_flag,
				beq 			=> beq,
				bne				=> bne,
				Zero 			=> Zero,
				J_adress		=> Instruction(7 downto 0),
				J				=> j,
				JR				=> jr,
				PC_out 			=> PC_sig );

   ID : Idecode
   	PORT MAP (	read_data_1 	=> read_data_1,
        		read_data_2 	=> read_data_2,
				reset 			=> reset,
				clock 			=> clock,
        		Instruction 	=> Instruction,
        		read_data 		=> read_data,
				ALU_result 		=> ALU_result,
				RegWrite 		=> RegWrite,
				MemtoReg 		=> MemtoReg,
				RegDst 			=> RegDst,
				PC_plus_4_out	=> PC_plus_4,
				PC				=> PC_sig,
				intr_flag       => intr_flag,
				JAL				=> JAL,
				Sign_extend 	=> Sign_extend,  
				GIE             => GIE);

   CTL:   control
	PORT MAP ( 	Opcode 			=> Instruction(31 DOWNTO 26),
				clock 			=> clock,
				reset 			=> reset,
				Instruction		=> Instruction(5 DOWNTO 0),
				intr_flag		=> intr_flag,			
				RegDst 			=> RegDst,
				ALUSrc 			=> ALUSrc,
				MemtoReg 		=> MemtoReg,
				RegWrite 		=> RegWrite,
				MemRead 		=> MemRead,
				MemWrite 		=> MemWrite,
				Beq 			=> beq,
				Bne				=> bne,
				ALUop 			=> ALUop,
				J				=> J,
				JAL				=> JAL,
				JR				=> JR,
				shl_sig			=> shl_sig,
				shr_sig			=> shr_sig);

   EXE:  Execute
   	PORT MAP (	Read_data_1 	=> read_data_1,
             	Read_data_2 	=> read_data_2,
				Sign_extend 	=> Sign_extend,
                Function_opcode	=> Instruction(5 DOWNTO 0),
				ALUOp 			=> ALUop,
				ALUSrc 			=> ALUSrc,
				Zero 			=> Zero,
                ALU_Result		=> ALU_Result,
				Add_Result 		=> Add_Result,
				PC_plus_4		=> PC_plus_4,
                Clock			=> clock,
				Reset			=> reset,
				shift_num		=> Instruction(10 DOWNTO 6),
				shl_sig			=> shl_sig,
				shr_sig			=> shr_sig);
				
   G0: if (modelsim = TRUE) generate
	MEM:  dmemory
		generic map (address_width => address_width)
	PORT MAP (	read_data 		=> read_data_mem,
				address 		=> mem_addr,
				write_data 		=> read_data_2,
				MemRead 		=> MemRead_Dmemory, 
				Memwrite 		=> MemWrite_Dmemory, 
                clock 			=> clock,  
				reset 			=> reset);
	end generate;
	
	G1: if (modelsim = FALSE) generate
	MEM:  dmemory
		generic map (address_width => address_width)
	PORT MAP (	read_data 		=> read_data_mem,
				address 		=> mem_addr_Q,
				write_data 		=> read_data_2,
				MemRead 		=> MemRead_Dmemory, 
				Memwrite 		=> MemWrite_Dmemory, 
                clock 			=> clock,  
				reset 			=> reset);
	end generate;
END structure;

