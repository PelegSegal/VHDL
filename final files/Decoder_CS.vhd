LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;

ENTITY Decoder_CS IS
	PORT   (Address 			:IN  STD_LOGIC_VECTOR (3 DOWNTO 0); -- A5,A4,A3,A2
			eight_hundred		:IN  STD_LOGIC; 					-- A11
			CS					:OUT STD_LOGIC_VECTOR (17 downto 0));
END 		Decoder_CS;

ARCHITECTURE behavior OF Decoder_CS IS
BEGIN
	process (Address, eight_hundred)
	begin
		CS <= "000000000000000000";       
		if (eight_hundred = '1') then
			case Address  is
				when "0000" => CS(0)  <= '1'; -- LEDR
				when "0001" => CS(1)  <= '1'; -- HEX0 / HEX1
				--when "0001" => CS(2)  <= '1'; -- HEX1
				when "0010" => CS(3)  <= '1'; -- HEX2 / HEX3
				--when "0010" => CS(4)  <= '1'; -- HEX3
				when "0011" => CS(5)  <= '1'; -- HEX4 / HEX5
				--when "0011" => CS(6)  <= '1'; -- HEX5
				when "0100" => CS(7)  <= '1'; -- SW
				when "0101" => CS(8)  <= '1'; -- KEYs 
				when "0110" => CS(9)  <= '1'; -- UCTL (UART) / TXBF (UART) / RXBF (UART)
				--when "0110" => CS(10) <= '1'; -- RXBF (UART)
				--when "0110" => CS(11) <= '1'; -- TXBF (UART)
				when "0111" => CS(12) <= '1'; -- BTCTL
				when "1000" => CS(13) <= '1'; -- BTCNT
				when "1001" => CS(14) <= '1'; -- BTCCR0
				when "1010" => CS(15) <= '1'; -- BTCCR1
				when "1011" => CS(16) <= '1'; -- IE / IFG / TYPEx
				when others => CS <= "000000000000000000";
			end case;
		end if;
	end process;
END behavior;