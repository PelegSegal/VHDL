--  Execute module (implements the data ALU and Branch Address Adder  
--  for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY  Execute IS
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
END Execute;

ARCHITECTURE behavior OF Execute IS
SIGNAL Ainput, Binput 				: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL ALU_output_mux				: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL Branch_Add 					: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ALU_ctl 						: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL shift_l,shift_r				: STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
	
	Ainput <= Read_data_1;
	
						-- ALU input mux
	Binput <= Read_data_2 WHEN (ALUSrc = '0') ELSE  Sign_extend(31 DOWNTO 0);
			  
						-- shift
	shift_l <= shl(Binput, shift_num);
	shift_r <= shr(Binput, shift_num);
	
	
	ALU_ctl <=	"0000" when (Function_opcode = "100100" and ALUOp = "000000") or (ALUOp = "001100")   else 		--and or andi
				"0001" when (Function_opcode = "100101" and ALUOp = "000000") or (ALUOp = "001101")   else 		--or or ori
				"0010" when ((Function_opcode = "100000" or Function_opcode = "100001") and ALUOp = "000000") or (ALUOp = "001000") or (ALUOp = "100011") or (ALUOp = "101011")   else -- add or addi or mov(addu)
				--"1010" when Function_opcode = "000000" and ALUOp = "000000" else								-- sll          יש מימוש שיפט  ימינה ושמאלה לא על בסיס ALU
				--"1000" when Function_opcode = "000010" and ALUOp = "000000" else								--srl
				"1100" when (Function_opcode = "100110" and ALUOp = "000000") or (ALUOp = "001110") else		-- xor or xori
				"0110" when (Function_opcode = "100010" and ALUOp = "000000") or (ALUOp = "000100") or (ALUOp = "000101") else	--sub or beq or bne
				"0011" when ALUOp = "011100" else																--mul
				"0100" when ALUOp = "001111" else																--lui
				"0111" when (Function_opcode = "101010" and ALUOp = "000000") or (ALUOp = "001010") else		--slt or slti
				"1111";

			   -- Generate Zero Flag
	Zero <= '1' WHEN (ALU_output_mux(31 DOWNTO 0) = X"00000000") ELSE '0';    
		
						-- Select ALU output        
	ALU_result <= shift_l 	   WHEN shl_sig='1' -- sll
				  ELSE shift_r WHEN shr_sig='1' -- srl
				  ELSE ALU_output_mux(31 DOWNTO 0);
		
						-- Adder to compute Branch Address
	Branch_Add	<= PC_plus_4(9 DOWNTO 2) +  Sign_extend(7 DOWNTO 0);
	Add_result 	<= Branch_Add(7 DOWNTO 0);

PROCESS ( ALU_ctl, Ainput, Binput)
	BEGIN	
 	CASE ALU_ctl IS
					-- ALU performs ALUresult = A_input AND B_input
		WHEN "0000" 	=>	ALU_output_mux 	<= Ainput AND Binput; 
					-- ALU performs ALUresult = A_input OR B_input
     	WHEN "0001" 	=>	ALU_output_mux 	<= Ainput OR Binput;
					-- ALU performs ALUresult = A_input + B_input
	 	WHEN "0010" 	=>	ALU_output_mux 	<= Ainput + Binput;
					-- ALU performs ALUresult = A_input * B_input mul
		when "0011"		=> ALU_output_mux 	<= Ainput(15 downto 0) * Binput(15 DOWNTO 0);
		--			-- ALU performs sll
 	 	--WHEN "1010" 	=>	ALU_output_mux <= shift_result;
		--			-- ALU performs srl
 	 	--WHEN "1000" 	=>	ALU_output_mux 	<= shift_result;
						-- ALU performs xor
 	 	WHEN "1100" 	=>	ALU_output_mux 	<= Ainput XOR Binput;
						-- ALU performs ALUresult = A_input -B_input
 	 	WHEN "0110" 	=>	ALU_output_mux 	<= Ainput - Binput;
						-- ALU performs SLT or slti
  	 	WHEN "0111" 	=>	
			if (Ainput<Binput) then
				ALU_output_mux 	<= X"00000001";
			ELSE
				ALU_output_mux 	<= X"00000000";
			end if;
						-- ALU performs lui -> Binput, 16*b0
  	 	WHEN "0100" 	=>	ALU_output_mux 	<= Binput (15 downto 0) & X"0000";
 	 	WHEN OTHERS		=>	ALU_output_mux 	<= X"00000000";
  	END CASE;
  END PROCESS;
END behavior;
