----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 			Jason Murphy
-- 
-- Create Date:    20:48:21 02/25/2016 
-- Design Name: 
-- Module Name:    SPITop - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPITop is
     Generic (address_width : natural);
      Port ( 		
			clk : in std_logic;
			address : out  STD_LOGIC_VECTOR(address_width-2 downto 0); -- address to read/write
			wr : out  STD_LOGIC;                     -- Is this a write?
			cmdEnable : out  STD_LOGIC;  -- Set to '1' to issue new command (only acted on when cmd_read = '1')
			cmdRdy : in STD_LOGIC;  -- '1' when a new command will be acted on
			byteEnable : out  STD_LOGIC_VECTOR(3 downto 0);  -- byte masks for the write command
			dataOut : out  STD_LOGIC_VECTOR(31 downto 0); -- data for the write command
			dataIn : in STD_LOGIC_VECTOR(31 downto 0); -- word read from SDRAM
			dataInRdy : in STD_LOGIC;
			
			SCK  : in  std_logic;    -- SPI input clock
			MOSI : in  std_logic;    -- SPI serial data input
			MISO : out std_logic;
			CEON   : in  std_logic    -- chip select input (active low)
			);      
end SPITop;

architecture Behavioral of SPITop is

component SPInt is generic (
      address_width : natural := 24);
Port (
		SCK  : in  std_logic;    -- SPI input clock
		MOSI : in  std_logic;    -- SPI serial data input
		MISO : out std_logic;
		CEON   : in  std_logic;   -- is new data ready?dataOut : out  STD_LOGIC_VECTOR(31 downto 0); -- data for the write command
		dataIn : in std_logic_vector(31 downto 0); -- word read from SDRAM
		dataOut : out std_logic_vector(31 downto 0);
		dataRdy : out std_logic);	
end component;

component SPISync is generic (
      address_width : natural);
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
end component;

signal sigDataOut, sigDataIn : std_logic_vector(31 downto 0);
signal sigDataRdy : std_logic;
begin    

Inst_SPInt: SPInt
  generic map (address_width => address_width)
Port map (
		SCK => SCK,
		MOSI => MOSI,
		MISO => MISO,
		CEON => CEON,
		dataIn => sigDataIn,
		dataOut => sigDataOut,
		dataRdy => sigDataRdy);
		
Inst_SPISync: SPISync
generic map (address_width => address_width)
Port map(
	clk => clk,
	address => address,
	wr => wr,
	cmdEnable => cmdEnable,
	cmdRdy => cmdRdy,
	byteEnable => byteEnable,
	writeDataOut => dataOut,
	readDataOut => sigDataIn,
	readDataIn => dataIn,
	writeDataIn => sigDataOut,
	dataInRdy => sigDataRdy);

end Behavioral;

