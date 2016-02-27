--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:26:05 02/14/2016
-- Design Name:   
-- Module Name:   /home/jason/Workbook/FPGA/logipi/SPISDRAM/SPISDRAM/SDRAMTest.vhd
-- Project Name:  SPISDRAM
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SDRAMInt
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY SDRAMTest IS
END SDRAMTest;
 
ARCHITECTURE behavior OF SDRAMTest IS 
 
	constant test_frequency : natural := 133_000_000 ;
	constant test_frequency_mhz : natural := test_frequency/1_000_000 ;
	constant freq_multiplier : natural := 16 ;
	constant freq_divider : natural := (freq_multiplier*50_000_000)/test_frequency ;
	
	constant low_speed_test : natural := 0 ; -- set only for sub 80Mhz test
	

	constant sdram_address_width : natural := 24;
   constant sdram_column_bits   : natural := 9;
   constant sdram_startup_cycles: natural := 10100; -- 100us, plus a little more
   constant cycles_per_refresh  : natural := (64000*test_frequency_mhz)/8192-1;
   constant test_width          : natural := sdram_address_width-1; -- each 32-bit word is two 16-bit SDRAM addresses 

	COMPONENT SDRAM_Controller
    generic (
      sdram_address_width : natural;
      sdram_column_bits   : natural;
      sdram_startup_cycles: natural;
      cycles_per_refresh  : natural;
		very_low_speed : natural);
   
    PORT(clk           : in  STD_LOGIC;
         reset         : in  STD_LOGIC;
           
           -- Interface to issue reads or write data
           cmd_ready         : out STD_LOGIC;                     -- '1' when a new command will be acted on
           cmd_enable        : in  STD_LOGIC;                     -- Set to '1' to issue new command (only acted on when cmd_read = '1')
           cmd_wr            : in  STD_LOGIC;                     -- Is this a write?
           cmd_address       : in  STD_LOGIC_VECTOR(sdram_address_width-2 downto 0); -- address to read/write
           cmd_byte_enable   : in  STD_LOGIC_VECTOR(3 downto 0);  -- byte masks for the write command
           cmd_data_in       : in  STD_LOGIC_VECTOR(31 downto 0); -- data for the write command
           
           data_out          : out STD_LOGIC_VECTOR(31 downto 0); -- word read from SDRAM
           data_out_ready    : out STD_LOGIC;                     -- is new data ready?
           
           -- SDRAM signals
           SDRAM_CLK     : out   STD_LOGIC;
           SDRAM_CKE     : out   STD_LOGIC;
           SDRAM_CS      : out   STD_LOGIC;
           SDRAM_RAS     : out   STD_LOGIC;
           SDRAM_CAS     : out   STD_LOGIC;
           SDRAM_WE      : out   STD_LOGIC;
           SDRAM_DQM     : out   STD_LOGIC_VECTOR( 1 downto 0);
           SDRAM_ADDR    : out   STD_LOGIC_VECTOR(12 downto 0);
           SDRAM_BA      : out   STD_LOGIC_VECTOR( 1 downto 0);
           SDRAM_DATA    : inout STD_LOGIC_VECTOR(15 downto 0));
    END COMPONENT;
 
constant FPGACLOCKPERIOD : time := 5 ns; -- 50Mhz 

signal clkSig  : STD_LOGIC;
signal resetSig : STD_LOGIC := '0';

signal cmd_readySig : STD_LOGIC;                     -- '1' when a new command will be acted on
signal cmd_enableSig : STD_LOGIC := '0';                     -- Set to '1' to issue new command (only acted on when cmd_read = '1')
signal cmd_wrSig : STD_LOGIC := '0';                     -- Is this a write?
signal cmd_addressSig : STD_LOGIC_VECTOR(sdram_address_width-2 downto 0); -- address to read/write
signal cmd_byte_enableSig : STD_LOGIC_VECTOR(3 downto 0) := "1111";  -- byte masks for the write command
signal cmd_data_inSig : STD_LOGIC_VECTOR(31 downto 0); -- data for the write command
   
signal data_outSig : STD_LOGIC_VECTOR(31 downto 0); -- word read from SDRAM
signal data_out_readySig : STD_LOGIC;                     -- is new data ready?
           
signal row : std_logic_vector(12 downto 0);
signal col : std_logic_vector(7 downto 0);   -- bit 8 is the data delimeter
signal bank : std_logic_vector(1 downto 0);
           -- SDRAM signals
signal SDRAM_CLKSig : STD_LOGIC;
signal SDRAM_CKESig  : STD_LOGIC;
signal SDRAM_CSSig : STD_LOGIC;
signal SDRAM_RASSig : STD_LOGIC;
signal SDRAM_CASSig : STD_LOGIC;
signal SDRAM_WESig : STD_LOGIC;
signal SDRAM_DQMSig : STD_LOGIC_VECTOR( 1 downto 0);
signal SDRAM_ADDRSig : STD_LOGIC_VECTOR(12 downto 0);
signal SDRAM_BASig : STD_LOGIC_VECTOR( 1 downto 0);
signal SDRAM_DATASig : STD_LOGIC_VECTOR(15 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SDRAM_Controller GENERIC MAP (
      sdram_address_width => sdram_address_width,
      sdram_column_bits   => sdram_column_bits,
      sdram_startup_cycles=> sdram_startup_cycles,
      cycles_per_refresh  => cycles_per_refresh,
		very_low_speed => low_speed_test
   ) PORT MAP (
			clk=> clkSig,
         reset=> resetSig,
          
           cmd_ready=>cmd_readySig,                    -- '1' when a new command will be acted on
           cmd_enable=> cmd_enableSig,                     -- Set to '1' to issue new command (only acted on when cmd_read = '1')
           cmd_wr=>cmd_wrSig,                     -- Is this a write?
           cmd_address=>cmd_addressSig, -- address to read/write
           cmd_byte_enable=>cmd_byte_enableSig,  -- byte masks for the write command
           cmd_data_in=>cmd_data_inSig, -- data for the write command
           
           data_out=> data_outSig, -- word read from SDRAM
           data_out_ready=>data_out_readySig,                     -- is new data ready?
           
           -- SDRAM signals
           SDRAM_CLK=>SDRAM_CLKSig,
           SDRAM_CKE=>SDRAM_CKESig,
           SDRAM_CS=>SDRAM_CSSig,
           SDRAM_RAS=>SDRAM_RASSig,
           SDRAM_CAS=>SDRAM_CASSig,
           SDRAM_WE=>SDRAM_WESig,
           SDRAM_DQM=>SDRAM_DQMSig,
           SDRAM_ADDR=>SDRAM_ADDRSig,
           SDRAM_BA =>SDRAM_BASig,
           SDRAM_DATA=>SDRAM_DATASig);

   -- Clock process definitions
  
clkProcess :process
begin
	clkSig <= '0';
   wait for FPGACLOCKPERIOD;
   clkSig <= '1';
   wait for FPGACLOCKPERIOD;
end process;

 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 us;	
		resetSig <= '1';
		wait for 100 ns;
		resetSig <= '0';
		wait for 100 us;
      		
		waitForSDRAM: while cmd_readySig = '0' loop
			wait for 20 ns;
		end loop waitForSDRAM;
      
		--Do a write
		--address is made up of the following
		--<Row Addr(13 bits)><Bank (2 bits)><Col Addr(8 bits - 9th bit is data delimeter)>
		row <= "0101000000001";
		col <= "00010001";
		bank <= "01";
		wait for 20ns;
		cmd_addressSig <= row & bank & col;  -- address to write
		cmd_byte_enableSig <= "0000";  -- byte masks for the write command
		cmd_data_inSig <= "10000111011001010100001100100001"; -- data for the write command
		cmd_wrSig <= '1';
		wait for 20 ns;
		cmd_enableSig <='1';
		wait for 20 ns;
		cmd_enableSig <='0';
		
		wait for FPGACLOCKPERIOD*100;
		
		--Do a long write
		row <= "1111111111111";
		col <= "11111111";
		bank <= "11";
		wait for 20ns;
		cmd_addressSig <= row & bank & col;  -- address to write
		cmd_byte_enableSig <= "0000";  -- byte masks for the write command
		cmd_data_inSig <= "00010010001101000101011001111000"; -- data for the write command
		cmd_wrSig <= '1';
		wait for 20 ns;
		cmd_enableSig <='1';
		wait for 100 ns;
		cmd_enableSig <='0';
		
		wait for FPGACLOCKPERIOD*100;
		--Do a read
		
		cmd_wrSig <= '0';
		wait for 20 ns;
		cmd_enableSig <='1';
		wait for 20 ns;
		cmd_enableSig <='0';
      
		wait;
   end process;

END;
