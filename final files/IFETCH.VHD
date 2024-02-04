-- Ifetch module (provides the PC and instruction 
--memory for the MIPS computer)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

ENTITY Ifetch IS
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
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
	SIGNAL PC, PC_plus_4 	: STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL next_PC			: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL Mem_Addr        	: STD_LOGIC_VECTOR(address_width-1 DOWNTO 0 );
	
BEGIN 
					--ROM for Instruction Memory
inst_memory: altsyncram
	
	GENERIC MAP (
		operation_mode => "ROM",
		width_a => 32,
		widthad_a => address_width,
		lpm_type => "altsyncram",
		outdata_reg_a => "UNREGISTERED",
		init_file => "C:\Users\97255\Desktop\final_proj_peleg\program.hex",
		intended_device_family => "Cyclone"
	)
	PORT MAP (
		clock0     => clock,
		address_a  => Mem_Addr, 
		q_a 	   => Instruction );
		
					-- Instructions always start on word address - not byte
		PC(1 DOWNTO 0) <= "00";
		
					-- copy output signals - allows read inside module
		PC_out 			<= PC;
		PC_plus_4_out 	<= PC_plus_4;
		
					-- send address to inst. memory address register
		G0:	if (modelsim = TRUE) generate
			Mem_Addr <= Next_PC;			--next address when we simulate on modelsim
		end generate;
		
		G1:	if (modelsim = FALSE) generate
			Mem_Addr <= Next_PC & "00";		--next address when we simulate on quartos
		end generate;
		
					-- Adder to increment PC by 4        
      	PC_plus_4(9 DOWNTO 2)  <= PC(9 DOWNTO 2) + 1;
       	PC_plus_4(1 DOWNTO 0)  <= "00";
		
					-- Mux to select Branch Address or PC + 4        
		Next_PC  <= X"00" 					WHEN Reset = '1' 
			ELSE    read_data_mem 			WHEN intr_flag = '1' -- Interrupt (key or timer)
			ELSE    Add_result 				WHEN (((beq = '1') and (Zero = '1')) or ((bne = '1') and (Zero = '0'))) -- Branch instruction
			ELSE  	J_adress	   			WHEN J = '1' 	 	 -- Jump instruction
			ELSE 	read_data1(9 DOWNTO 2)  WHEN JR = '1'  		 -- JR instuction
			ELSE    PC_plus_4  (9 DOWNTO 2);
			
	PROCESS
		BEGIN
			WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
			IF reset = '1' THEN
				   PC(9 DOWNTO 2) <= "00000000" ; 
			ELSIF ena ='1' then
				   PC(9 DOWNTO 2) <= next_PC;
			END IF;
	END PROCESS;
END behavior;


