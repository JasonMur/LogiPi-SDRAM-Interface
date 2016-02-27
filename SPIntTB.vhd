--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:05:37 02/23/2016
-- Design Name:   
-- Module Name:   /home/jason/Workbook/FPGA/logipi/SPISDRAM/temp/SPIntTB.vhd
-- Project Name:  SPISDRAM
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SPInt
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
 
ENTITY SPIntTB IS
END SPIntTB;
 
ARCHITECTURE behavior OF SPIntTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SPInt
    PORT(
         SCK : IN  std_logic;
         MOSI : IN  std_logic;
         MISO : OUT  std_logic;
         CEON : IN  std_logic;
         dataIn : IN  std_logic_vector(31 downto 0);
         dataOut : OUT  std_logic_vector(31 downto 0);
         dataRdy : OUT  std_logic);
    END COMPONENT;
    

   --Inputs
   signal SCK : std_logic := '0';
   signal MOSI : std_logic := '0';
   signal CEON : std_logic := '0';
   signal dataIn : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal MISO : std_logic;
   signal dataOut : std_logic_vector(31 downto 0);
   signal dataRdy : std_logic;
	signal bitCount : integer range 0 to 31;
	signal dWordCount : integer range 0 to 1023;
	
	signal writeSequence : std_logic_vector(31 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SPInt PORT MAP (
          SCK => SCK,
          MOSI => MOSI,
          MISO => MISO,
          CEON => CEON,
          dataIn => dataIn,
          dataOut => dataOut,
          dataRdy => dataRdy
        );

   -- Clock process definitions
   
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 1000 ns;	

   
	writeLotsOfData: while dWordCount <= 1023 loop
	bitCount <= 0;
   wait for 1000 ns;
	dataIn <= "10010101110001110101010111001010";
	writeSequence <= "01110101110001100100010100011001";  --
	CEON <= '0';
	wait for 100ns;
	writeSingleReg: while bitCount <= 31 loop
		MOSI <= writeSequence(31-bitCount);
		bitCount <= bitCount + 1;
		
		wait for 100 ns;
		SCK <= '1';
		wait for 100 ns;
		SCK <= '0';
		if bitCount = 8 or bitCount = 16 or bitCount = 24 then
			wait for 50 ns;
			CEON <= '1';
			wait for 1000 ns;
			CEON <= '0';
			wait for 50 ns;
		end if;
		
	end loop writeSingleReg;
      -- insert stimulus here 
	wait for 50 ns;
	CEON <= '1';
	
	bitCount <= 0;
	wait for 1000 ns;
	writeSequence <= "10101010101010100101010101010101";  --
	CEON <= '0';
	wait for 50 ns;
	writeNextReg: while bitCount <= 31 loop
		MOSI <= writeSequence(31-bitCount);
		bitCount <= bitCount + 1;
		
		wait for 100 ns;
		SCK <= '1';
		wait for 100 ns;
		SCK <= '0';
		if bitCount = 8 or bitCount = 16 or bitCount = 24 then
			wait for 50 ns;
			CEON <= '1';
			wait for 1000 ns;
			CEON <= '0';
			wait for 50 ns;
		end if;
		
	end loop writeNextReg;
      -- insert stimulus here 
	dWordCount <= dWordCount + 1;
	wait for 50 ns;
	CEON <= '1';
	end loop writeLotsOfData;
      
      wait;
   end process;

END;
