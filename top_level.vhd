----------------------------------------------------------------------------------
-- Jason Murphy modified version of Mike Field <hamster@snap.net.nz>
-- 
-- Description: Top level module for the LogiPi SDRAM controller project 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity top_level is
    Port ( OSC_FPGA      : in    STD_LOGIC;
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
end top_level;

architecture Behavioral of top_level is
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
		very_low_speed : natural := 0
    );
    PORT(
		clk             : IN std_logic;
		reset           : IN std_logic;
      
      -- Interface to issue commands
		cmd_ready       : OUT std_logic;
		cmd_enable      : IN  std_logic;
		cmd_wr          : IN  std_logic;
      cmd_address     : in  STD_LOGIC_VECTOR(sdram_address_width-2 downto 0); -- address to read/write
		cmd_byte_enable : IN  std_logic_vector(3 downto 0);
		cmd_data_in     : IN  std_logic_vector(31 downto 0);    
      
      -- Data being read back from SDRAM
		data_out        : OUT std_logic_vector(31 downto 0);
		data_out_ready  : OUT std_logic;

      -- SDRAM signals
		SDRAM_CLK       : OUT   std_logic;
		SDRAM_CKE       : OUT   std_logic;
		SDRAM_CS        : OUT   std_logic;
		SDRAM_RAS       : OUT   std_logic;
		SDRAM_CAS       : OUT   std_logic;
		SDRAM_WE        : OUT   std_logic;
		SDRAM_DQM       : OUT   std_logic_vector(1 downto 0);
		SDRAM_ADDR      : OUT   std_logic_vector(12 downto 0);
		SDRAM_BA        : OUT   std_logic_vector(1 downto 0);
		SDRAM_DATA      : INOUT std_logic_vector(15 downto 0)     
		);
END COMPONENT;

COMPONENT SPITop
     Generic (address_width : natural);
      Port ( 		
			clk : in std_logic;
			address : out  STD_LOGIC_VECTOR(sdram_address_width-2 downto 0); -- address to read/write
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
	  
END COMPONENT;

   -- signals for clocking
   signal clk, clku, clkfb, clkb   : std_logic;
   
   -- signals to interface with the memory controller
   signal cmd_address     : std_logic_vector(sdram_address_width-2 downto 0) := (others => '0');
   signal cmd_wr          : std_logic := '1';
   signal cmd_enable      : std_logic;
   signal cmd_byte_enable : std_logic_vector(3 downto 0);
   signal cmd_data_in     : std_logic_vector(31 downto 0);
   signal cmd_ready       : std_logic;
   signal data_out        : std_logic_vector(31 downto 0);
   signal data_out_ready  : std_logic;
   
   -- misc signals
   signal error_refresh   : std_logic;
   signal error_testing   : std_logic;
   signal blink           : std_logic;
   signal debug           : std_logic_vector(15 downto 0);
   signal tester_debug    : std_logic_vector(15 downto 0);
   signal is_idle         : std_logic;
   signal iob_data        : std_logic_vector(15 downto 0);      
   signal error_blink     : std_logic;
	
   
begin

Inst_SPITop: SPITop 
GENERIC MAP(address_width => sdram_address_width) 
PORT MAP(
      clk => clk,
      address => cmd_address,
      wr => cmd_wr,
      cmdEnable => cmd_enable,
      cmdRdy => cmd_ready,
      byteEnable => cmd_byte_enable,
      dataOut => cmd_data_in,
      dataIn        => data_out,
      dataInRdy  => data_out_ready,
      
		SCK  => SCK,
		MOSI => MOSI,    
		MISO => MISO,
		CEON => CEON
   );
   
   

Inst_SDRAM_Controller: SDRAM_Controller GENERIC MAP (
      sdram_address_width => sdram_address_width,
      sdram_column_bits   => sdram_column_bits,
      sdram_startup_cycles=> sdram_startup_cycles,
      cycles_per_refresh  => cycles_per_refresh,
		very_low_speed => low_speed_test
   ) PORT MAP(
      clk             => clk,
      reset           => '0',

      cmd_address     => cmd_address,
      cmd_wr          => cmd_wr,
      cmd_enable      => cmd_enable,
      cmd_ready       => cmd_ready,
      cmd_byte_enable => cmd_byte_enable,
      cmd_data_in     => cmd_data_in,
      
      data_out        => data_out,
      data_out_ready  => data_out_ready,
   
      SDRAM_CLK       => SDRAM_CLK,
      SDRAM_CKE       => SDRAM_CKE,
      SDRAM_CS        => SDRAM_CS,
      SDRAM_RAS       => SDRAM_nRAS,
      SDRAM_CAS       => SDRAM_nCAS,
      SDRAM_WE        => SDRAM_nWE,
      SDRAM_DQM       => SDRAM_DQM,
      SDRAM_BA        => SDRAM_BA,
      SDRAM_ADDR      => SDRAM_ADDR,
      SDRAM_DATA      => SDRAM_DQ
   );

   
PLL_BASE_inst : PLL_BASE generic map (
      BANDWIDTH      => "OPTIMIZED",        -- "HIGH", "LOW" or "OPTIMIZED" 
      CLKFBOUT_MULT  => freq_multiplier ,                 -- Multiply value for all CLKOUT clock outputs (1-64)
      CLKFBOUT_PHASE => 0.0,                -- Phase offset in degrees of the clock feedback output (0.0-360.0).
      CLKIN_PERIOD   => 20.00,              -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for CLKOUT# clock output (1-128)
      CLKOUT0_DIVIDE => freq_divider,       CLKOUT1_DIVIDE => freq_divider,
      CLKOUT2_DIVIDE => 1,       CLKOUT3_DIVIDE => 1,
      CLKOUT4_DIVIDE => 1,       CLKOUT5_DIVIDE => 1,
      -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for CLKOUT# clock output (0.01-0.99).
      CLKOUT0_DUTY_CYCLE => 0.5, CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5, CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5, CLKOUT5_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT5_PHASE: Output phase relationship for CLKOUT# clock output (-360.0-360.0).
      CLKOUT0_PHASE => 0.0,      CLKOUT1_PHASE => 0.0, -- Capture clock
      CLKOUT2_PHASE => 0.0,      CLKOUT3_PHASE => 0.0,
      CLKOUT4_PHASE => 0.0,      CLKOUT5_PHASE => 0.0,
      
      CLK_FEEDBACK => "CLKFBOUT",           -- Clock source to drive CLKFBIN ("CLKFBOUT" or "CLKOUT0")
      COMPENSATION => "SYSTEM_SYNCHRONOUS", -- "SYSTEM_SYNCHRONOUS", "SOURCE_SYNCHRONOUS", "EXTERNAL" 
      DIVCLK_DIVIDE => 1,                   -- Division value for all output clocks (1-52)
      REF_JITTER => 0.1,                    -- Reference Clock Jitter in UI (0.000-0.999).
      RESET_ON_LOSS_OF_LOCK => FALSE        -- Must be set to FALSE
   ) port map (
      CLKFBOUT => CLKFB, -- 1-bit output: PLL_BASE feedback output
      -- CLKOUT0 - CLKOUT5: 1-bit (each) output: Clock outputs
      CLKOUT0 => CLKu,      CLKOUT1 => open,
      CLKOUT2 => open,      CLKOUT3 => open,
      CLKOUT4 => open,      CLKOUT5 => open,
      LOCKED  => open,  -- 1-bit output: PLL_BASE lock status output
      CLKFBIN => CLKFB, -- 1-bit input: Feedback clock input
      CLKIN   => clkb,  -- 1-bit input: Clock input
      RST     => '0'    -- 1-bit input: Reset input
   );

   -- Buffering of clocks
BUFG_1 : BUFG port map (O => clkb,    I => OSC_FPGA);
BUFG_3 : BUFG port map (O => clk,     I => clku);

end Behavioral;
