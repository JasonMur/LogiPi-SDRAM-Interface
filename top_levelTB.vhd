--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:55:38 02/15/2016
-- Design Name:   
-- Module Name:   /home/jason/Workbook/FPGA/logipi/SPISDRAM/SPISDRAM/top_levelTB.vhd
-- Project Name:  SPISDRAM
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: top_level
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
 
ENTITY top_levelTB IS
END top_levelTB;
 
ARCHITECTURE behavior OF top_levelTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top_level
    PORT(
			OSC_FPGA      : in    STD_LOGIC;
         SDRAM_CLK   : out   STD_LOGIC;
         SDRAM_CKE   : out   STD_LOGIC;
         SDRAM_CS    : out   STD_LOGIC;
         SDRAM_nRAS  : out   STD_LOGIC;
         SDRAM_nCAS  : out   STD_LOGIC;
         SDRAM_nWE   : out   STD_LOGIC;
         SDRAM_DQM   : out   STD_LOGIC_VECTOR( 1 downto 0);
         SDRAM_ADDR  : out   STD_LOGIC_VECTOR (12 downto 0);
         SDRAM_BA    : out   STD_LOGIC_VECTOR( 1 downto 0);
         SDRAM_DQ    : inout STD_LOGIC_VECTOR (15 downto 0);
			  
			SCK : in std_logic;
			MOSI : in std_logic;
			MISO : out std_logic;
			CEON : in std_logic);
    END COMPONENT;
    

   --Inputs
   signal reset : std_logic := '0';
   signal OSC_FPGA : std_logic := '0';
   signal SCK : std_logic := '0';
   signal MOSI : std_logic := '0';
   signal CS : std_logic := '0';

	--BiDirs
   signal SDRAM_DQ : std_logic_vector(15 downto 0);

 	--Outputs
   signal MISO : std_logic;
   signal SDRAM_CLK : std_logic;
   signal SDRAM_CKE : std_logic;
   signal SDRAM_CS : std_logic;
   signal SDRAM_nRAS : std_logic;
   signal SDRAM_nCAS : std_logic;
   signal SDRAM_nWE : std_logic;
   signal SDRAM_DQM : std_logic_vector(1 downto 0);
   signal SDRAM_ADDR : std_logic_vector(12 downto 0);
   signal SDRAM_BA : std_logic_vector(1 downto 0);

   -- Clock period definitions
   constant FPGAClk_period : time := 20 ns;
	constant sck_period : time := 100 ns;
	signal bitCount : integer range 0 to 32 := 0;
	signal dWordCount : integer range 0 to 262144 := 0;
	signal writeSequence : std_logic_vector(31 downto 0);
	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top_level PORT MAP (
          OSC_FPGA => OSC_FPGA,
          SCK => SCK,
          MOSI => MOSI,
          MISO => MISO,
          CEON => CS,
          SDRAM_CLK => SDRAM_CLK,
          SDRAM_CKE => SDRAM_CKE,
          SDRAM_CS => SDRAM_CS,
          SDRAM_nRAS => SDRAM_nRAS,
          SDRAM_nCAS => SDRAM_nCAS,
          SDRAM_nWE => SDRAM_nWE,
          SDRAM_DQM => SDRAM_DQM,
          SDRAM_ADDR => SDRAM_ADDR,
          SDRAM_BA => SDRAM_BA,
          SDRAM_DQ => SDRAM_DQ
        );

   -- Clock process definitions
   SDRAM_CLK_process :process
   begin
		OSC_FPGA <= '0';
		wait for FPGAClk_period/2;
		OSC_FPGA <= '1';
		wait for FPGAClk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 1000 us;	

      wait for FPGAClk_period*10;

      -- insert stimulus here 
	writeLotsOfData: while dWordCount <= 1023 loop
	bitCount <= 0;
   wait for sck_period*10;
	
	writeSequence <= "01110101110001100100010100011001";  --
	CS <= '0';
	wait for sck_period/2;
	writeSingleReg: while bitCount <= 31 loop
		MOSI <= writeSequence(31-bitCount);
		bitCount <= bitCount + 1;
		
		wait for sck_period;
		SCK <= '1';
		wait for sck_period;
		SCK <= '0';
		if bitCount = 8 or bitCount = 16 or bitCount = 24 then
			wait for sck_period/2;
			CS <= '1';
			wait for sck_period*10;
			CS <= '0';
			wait for sck_period/2;
		end if;
		
	end loop writeSingleReg;
      -- insert stimulus here 
	wait for sck_period/2;
	CS <= '1';
	
	bitCount <= 0;
	wait for sck_period*10;
	
	writeSequence <= "10101010101010100101010101010101";  --
	CS <= '0';
	wait for sck_period/2;
	writeNextReg: while bitCount <= 31 loop
		MOSI <= writeSequence(31-bitCount);
		bitCount <= bitCount + 1;
		
		wait for sck_period;
		SCK <= '1';
		wait for sck_period;
		SCK <= '0';
		if bitCount = 8 or bitCount = 16 or bitCount = 24 then
			wait for sck_period/2;
			CS <= '1';
			wait for sck_period*10;
			CS <= '0';
			wait for sck_period/2;
		end if;
		
	end loop writeNextReg;
      -- insert stimulus here 
	dWordCount <= dWordCount + 1;
	wait for sck_period/2;
	CS <= '1';
	end loop writeLotsOfData;
   wait;
   end process;

END;
