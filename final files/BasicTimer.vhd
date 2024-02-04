LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY BasicTimer IS
  PORT  (reset     		  :IN std_logic;	
		 clock			  :IN std_logic; 
		 MemWrite		  :IN STD_LOGIC;
		 MemRead		  :IN STD_LOGIC;
		 CS				  :IN STD_LOGIC_VECTOR (17 DOWNTO 0);
		 DataBus_in		  :IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		 DataBus_out	  :OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 DataBus_EN_timer :OUT STD_LOGIC;
		 Set_BTIFG		  :OUT STD_LOGIC;
		 Out_Signal		  :OUT STD_LOGIC);
END BasicTimer;

ARCHITECTURE behavi OF BasicTimer IS
	-- timer signals --
SIGNAL BTHOLD		:std_logic;
SIGNAL BTSSEL		:std_logic_vector(1 DOWNTO 0);
SIGNAL BTIPx		:std_logic_vector(2 DOWNTO 0);
SIGNAL MCLK			:STD_LOGIC_VECTOR(2 DOWNTO 0):=	"000";
SIGNAL BTCTL		:std_logic_vector (7 downto 0):= "00000000"; 
SIGNAL ChosenClk	:std_logic;
SIGNAL BTCNT		:std_logic_vector (31 downto 0);
SIGNAL BTCCR0		:std_logic_vector (31 downto 0);
SIGNAL BTCCR1		:std_logic_vector (31 downto 0);
SIGNAL BTCL0		:std_logic_vector (31 downto 0);
SIGNAL BTCL1		:std_logic_vector (31 downto 0);
SIGNAL BTOUTEN		:std_logic;
SIGNAL Out_Sig		:std_logic;

BEGIN

BTHOLD	<=	BTCTL(5);
BTOUTEN	<=	BTCTL(6);
BTSSEL	<=	BTCTL(4 downto 3);
BTIPx	<=	BTCTL(2 downto 0);
BTCL0 	<=  BTCCR0;
BTCL1 	<=  BTCCR1;

Out_Signal <= Out_Sig;

	-- select clock by BTSSEL
ChosenClk	<=	clock 	 when BTHOLD = '1'  else
				MCLK(2)  when BTSSEL = "11" else
				MCLK(1)  when BTSSEL = "10" else
				MCLK(0)  when BTSSEL = "01" else
				clock;
				
WITH BTIPx	select
	Set_BTIFG	<= 	BTCNT(25) when "111",
					BTCNT(23) when "110",
					BTCNT(19) when "101",
					BTCNT(15) when "100",
					BTCNT(11) when "011",
					BTCNT(7)  when "010",
					BTCNT(3)  when "001",
					BTCNT(0)  when others;	

	-- writing from basic timer registers to Data Bus (rw) --
process(CS,MemRead,reset)
BEGIN
	if (reset = '1') then 
		DataBus_out <= (others => '0');
		DataBus_EN_timer  <= '0';
	else
		if (MemRead = '1' and (cs(12) = '1' or cs(13) = '1' or cs(14) = '1' or cs(15) = '1')) then -- read (lw) 
			if (MemRead='1'  and cs(12) = '1') then    -- BTCTL
				DataBus_out <= X"000000" & BTCTL;
			elsif (MemRead='1'  and cs(13) = '1') then -- BTCNT
				DataBus_out <= BTCNT;
			elsif (MemRead='1'  and cs(14) = '1') then -- BTCCR0
				DataBus_out <= BTCCR0;
			elsif (MemRead='1'  and cs(15) = '1') then -- BTCCR1
				DataBus_out <= BTCCR1;
			end if;
			DataBus_EN_timer  <= '1';
		else 
			DataBus_out <= (others => '0');
			DataBus_EN_timer  <= '0';
		end if;
	end if;
end process;

	-- counting MCLK --
process (clock,reset)
begin
	if(reset = '1') then MCLK	<= "000";
	elsif (rising_edge(clock)) then MCLK <= MCLK + 1; 
	end if;
end process;

	-- writing from bus to BTCTL --
process (Clock,reset)
begin
	if (reset = '1') then BTCTL <= "00100000";
	elsif(rising_edge(clock)) then
		if (CS(12) = '1' and MemWrite = '1') then -- BTCTL
			BTCTL <= DataBus_in(7 downto 0);
		end if;
	end if;
end process;

	-- BTCNT --
process (ChosenClk, BTHOLD, reset, CS)
begin
	if (reset = '1') then 
		BTCNT <= (others => '0');
	elsif (rising_edge(ChosenClk)) then
		if BTHOLD = '0' then 
			if BTOUTEN = '0' or (BTOUTEN = '1' and NOT (BTCNT = BTCL0)) then 
				BTCNT <= BTCNT + 1;
			elsif BTOUTEN = '1' and BTCNT = BTCL0 then
				BTCNT <= (others => '0');
			end if;
		elsif (BTHOLD = '1' and (CS(13) = '1' and MemWrite = '1')) then -- BTCNT
			BTCNT <= DataBus_in;
		end if;
	end if;
end process;

	-- output signal (PWM) --
process (Reset, ChosenClk)
begin
	if (ChosenClk'EVENT ) and (ChosenClk = '1') then
		if Reset = '1' then
			BTCCR0 <= X"00000000";
			BTCCR1 <= X"00000000";
			Out_Sig  <= '0';
		elsif MemWrite = '1' and CS(14) = '1' then
			BTCCR0 <= DataBus_in;
		elsif MemWrite = '1' and CS(15) = '1' then
			BTCCR1 <= DataBus_in;
		end if;
	end if;
	if (ChosenClk'EVENT) and (ChosenClk = '1') and (BTCL0 = BTCNT or BTCL1 = BTCNT) and BTOUTEN = '1' then
		Out_Sig <= NOT Out_Sig;
	elsif BTOUTEN = '0' then
		Out_Sig <= '0';	
	end if;
end process;
	
END behavi;