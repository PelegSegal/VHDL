LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY interrupt IS
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
END interrupt;

ARCHITECTURE intru OF interrupt IS
	-- interrupt signals --
signal IE 		:std_logic_vector (7 downto 0) := "00000000"; 
signal IFG 		:std_logic_vector (7 downto 0) := "00000000"; 
signal TYPEx  	:std_logic_vector (7 downto 0) := "00000000";
signal IFG_FLAG :std_logic_vector (7 downto 0) := "00000000";

BEGIN
	IFG_FLAG(1 downto 0) <= "00";
	IFG_FLAG(7 downto 6) <= "00";
	
	-- writing from Data Bus to interrupt registers (lw) --
	process(reset,cs,MemWrite, Address_Bus,clock)
	begin
		if ( reset = '1') then IE	<= (others => '0');
		elsif (rising_edge(clock)) THEN	
				if (CS(16) = '1' and MemWrite = '1' and Address_Bus = X"82C" ) then 
						IE <= DataBus_in(7 downto 0);
				elsif (CS(16) = '1' and MemWrite = '1' and Address_Bus = X"82D") then 
						IFG <= DataBus_in(7 downto 0);
				else
						IFG <= IFG_FLAG;
				end if;
		end if;							
	end process;

	--writing from interrupt registers to Data Bus (rw) --
	process(INTA,CS,MemRead,reset)
	begin
		if (reset = '1') then 
			DataBus_out <= (others => '0');
			DataBus_EN_interrupt  <= '0';
		else
			if (INTA = '1') then 							--interrupt
				DataBus_out <= X"000000" & TYPEx;
				DataBus_EN_interrupt  <= '1';
			elsif (MemRead = '1' AND cs(16) = '1') then		 -- read (lw) 
				if (Address_Bus = X"82C") then 				 -- IE
					DataBus_out <= X"000000" & IE;
				elsif (Address_Bus = X"82D") then 			 -- IFG 
					DataBus_out <= X"000000" & IFG;
				elsif (Address_Bus = X"82E") then 			 -- TYPEx
					DataBus_out <= X"000000" & TYPEx;
				end if;
				DataBus_EN_interrupt  <= '1';
			else 
				DataBus_out <= (others => '0');
				DataBus_EN_interrupt  <= '0';
			end if;
		end if;
	end process;
	
	-- trigger to interrupt --
	process (INTA,reset,irq2,IE)
	begin
		if (INTA = '1' or reset = '1') then 
			IFG_FLAG(2)   <= '0';
		else
			if(rising_edge(irq2) and IE(2) = '1') then 	-- BT interrupt
				IFG_FLAG(2) <= '1';
			end if;
		end if;
	end process;
	
	process (INTA,reset,irq3,IE) 
	begin
		if (INTA = '1' or reset = '1') then 
			IFG_FLAG(3)   <= '0';
		else
			if(rising_edge(irq3) and IE(3) = '1') then 	-- Key1
				IFG_FLAG(3) <= '1';
			end if;
		end if;
	end process;
	
	process (INTA,reset,irq4,IE) 
	begin
		if (INTA = '1' or reset = '1') then 
			IFG_FLAG(4)   <= '0';
		else
			if(rising_edge(irq4) and IE(4) = '1') then 	-- Key2
				IFG_FLAG(4) <= '1';
			end if;
		end if;
	end process;
	
	process (INTA,reset,irq5,IE) 
	begin
		if (INTA = '1' or reset = '1') then 
			IFG_FLAG(5)   <= '0';
		else
			if(rising_edge(irq5) and IE(5) = '1') then 	-- Key3
				IFG_FLAG(5) <= '1';
			end if;
		end if;
	end process;
	
	-- set interrupts destanation address --
	process (reset,TYPEx,IFG,GIE)
	begin	
		if (reset = '1') then
			TYPEx      <= (others => '0');
			INTR       <= '0';
		else
			INTR <= (IFG(2) or IFG(3) or IFG(4) or IFG(5)) and GIE; 
			if 	   (IFG(2)='1') then TYPEx <= "00010000"; -- BT address
			elsif  (IFG(3)='1') then TYPEx <= "00010100"; -- Key1 address
			elsif  (IFG(4)='1') then TYPEx <= "00011000"; -- Key2 address
			elsif  (IFG(5)='1') then TYPEx <= "00011100"; -- Key3 address
			end if;
		end if;
	end process;
END intru;
