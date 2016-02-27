----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 		Jason Murphy
-- 
-- Create Date:    15:34:20 02/13/2016 
-- Design Name: 
-- Module Name:    SPISync - Behavioral 
-- Project Name: 
-- Target Devices: Spartan 6 on LogiPi
-- Tool versions: ISE 14.7
-- Description: SPI to SDRAM read write interface for testing 
-- Cycles through LogiPi SDRAM writing and reading data 
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SPISync is generic (
      address_width : natural := 24);
Port (
	clk : in std_logic;
	address : out  STD_LOGIC_VECTOR(address_width-2 downto 0); -- address to read/write
	wr : out  STD_LOGIC;                     -- Is this a write?
	cmdEnable : out  STD_LOGIC;  -- Set to '1' to issue new command (only acted on when cmd_read = '1')
	cmdRdy : in STD_LOGIC;  -- '1' when a new command will be acted on
	byteEnable : out  STD_LOGIC_VECTOR(3 downto 0);  -- byte masks for the write command
	writeDataOut, readDataOut : out  STD_LOGIC_VECTOR(31 downto 0); -- data for the write command
	readDataIn, writeDataIn : in STD_LOGIC_VECTOR(31 downto 0); -- word read from SDRAM
	dataInRdy : in STD_LOGIC);
end SPISync;

architecture Behavioral of SPISync is

type cmdSequence is (idle, readReq, readLSW, readMSW, writeLSW, writeMSW, pause);
signal currentState: cmdSequence := idle;  --current and next state declaration.
signal col : std_logic_vector(7 downto 0) := (others => '0');
signal row : std_logic_vector(12 downto 0) := (others => '0');
signal readBank, writeBank : std_logic_vector(1 downto 0) := (others => '0');

begin
	
	process(clk)
	begin
		
		if rising_edge(clk) then
			writeDataOut <= writeDataIn;
			cmdEnable <= '0';
			if dataInRdy = '0' then
				currentState <= idle;
			elsif cmdRdy = '1' then
				case currentState is
				when idle =>
					currentState <= readReq;
				when readReq =>
					wr <= '0';
					cmdEnable <= '1';
					address <= row&readBank&col;
					currentState <= readLSW;
				when readLSW =>
					if dataInRdy = '1' then
						readDataOut <= readDataIn;
						currentState <= readMSW;
					end if;
				when readMSW =>
					currentState <= writeLSW;
				when writeLSW =>
					cmdEnable <= '1';
					wr <= '1';
					address <= row&writeBank&col;
					col <= col + 1;
					if col = "11111111" then
						row <= row + 1;
						if row = "1111111111111" then
							writeBank <= writeBank + 1;
							--row <= "0000000000000";
						end if;
					end if;
					currentState <= writeMSW;
				when writeMSW =>
					currentState <= pause;
				when others =>
					currentState <= pause;
				end case;
			end if;
		end if ;
	end process;	
	readBank <= not(writeBank(1)) & writeBank(0);
	byteEnable <= "1111";
end Behavioral;