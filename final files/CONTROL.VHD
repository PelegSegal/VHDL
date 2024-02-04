		-- control module (implements MIPS control unit)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY control IS
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
END control;

ARCHITECTURE behavior OF control IS

	SIGNAL  R_format	: STD_LOGIC;
	SIGNAL  Lw			: STD_LOGIC;
	SIGNAL  Sw			: STD_LOGIC;
	SIGNAL  I_format	: STD_LOGIC;
	SIGNAL  mul			: STD_LOGIC;
	SIGNAL  JAL_sig		: STD_LOGIC;

BEGIN           
				-- Code to generate control signals using opcode bits
	R_format 	<=  '1'  WHEN  Opcode = "000000"  							ELSE '0';
	Lw          <=  '1'  WHEN  Opcode = "100011"  							ELSE '0';
	I_format 	<=	'1'  WHEN  Opcode(5 downto 3) = "001"  					ELSE '0';
 	Sw          <=  '1'  WHEN  Opcode = "101011"  							ELSE '0';
   	Beq      	<=  '1'  WHEN  Opcode = "000100"  							ELSE '0';
	Bne			<=  '1'  WHEN  Opcode = "000101"  							ELSE '0';
	J			<= 	'1'  WHEN  Opcode(5 downto 1) = "00001"  				ELSE '0';
	JAL_sig 	<=	'1'  WHEN  Opcode = "000011"  							ELSE '0';
	JR   		<=  '1'  WHEN  (R_format = '1' AND Instruction = "001000") 	ELSE '0';
	mul 		<=  '1'  WHEN  (opcode="011100") 							ELSE '0';
	shl_sig		<=  '1'  WHEN  (R_format = '1' and instruction = "000000") 	ELSE '0';
	shr_sig		<=  '1'  WHEN  (R_format = '1' and instruction = "000010") 	ELSE '0';
	
  	RegDst	    <=  R_format or mul;
 	ALUSrc  	<=  Lw OR Sw OR I_format;
	MemtoReg 	<=  Lw;
  	RegWrite 	<=  R_format OR Lw OR I_format OR JAL_sig OR mul OR intr_flag;
  	MemRead 	<=  Lw;
   	MemWrite 	<=  Sw; 
	ALUop 		<=  Opcode;
	JAL			<= JAL_sig;
   END behavior;


