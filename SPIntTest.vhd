--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:05:37 02/14/2016
-- Design Name:   
-- Module Name:   /home/jason/Workbook/FPGA/logipi/SPISDRAM/SPISDRAM/SPIntTest.vhd
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
 
ENTITY SPIntTest IS
END SPIntTest;
 
ARCHITECTURE behavior OF SPIntTest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SPInt
    PORT(
         reset : IN  std_logic;
         FPGAClk : IN  std_logic;
         SCK : IN  std_logic;
         MOSI : IN  std_logic;
         MISO : OUT  std_logic;
         CS : IN  std_logic;
         cmdRdy : IN  std_logic;
         cmdEnable : OUT  std_logic;
         wr : OUT  std_logic;
         address : OUT  std_logic_vector(22 downto 0);
         mask : OUT  std_logic_vector(3 downto 0);
         dataOut : OUT  std_logic_vector(31 downto 0);
         dataIn : IN  std_logic_vector(31 downto 0);
         dataInRdy : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal reset : std_logic := '0';
   signal FPGAClk : std_logic := '0';
   signal SCK : std_logic := '0';
   signal MOSI : std_logic := '0';
   signal CS : std_logic := '0';
   signal cmdRdy : std_logic := '0';
   signal dataIn : std_logic_vector(31 downto 0) := (others => '0');
   signal dataInRdy : std_logic := '0';

 	--Outputs
   signal MISO : std_logic;
   signal cmdEnable : std_logic;
   signal wr : std_logic;
   signal address : std_logic_vector(22 downto 0);
   signal mask : std_logic_vector(3 downto 0);
   signal dataOut : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant FPGAClk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SPInt PORT MAP (
          reset => reset,
          FPGAClk => FPGAClk,
          SCK => SCK,
          MOSI => MOSI,
          MISO => MISO,
          CS => CS,
          cmdRdy => cmdRdy,
          cmdEnable => cmdEnable,
          wr => wr,
          address => address,
          mask => mask,
          dataOut => dataOut,
          dataIn => dataIn,
          dataInRdy => dataInRdy
        );

   -- Clock process definitions
   FPGAClk_process :process
   begin
		FPGAClk <= '0';
		wait for FPGAClk_period/2;
		FPGAClk <= '1';
		wait for FPGAClk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for FPGAClk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
