library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

-- NOTE(acol): kind contribution from gemini

entity TbGbrgDebayer is
end entity TbGbrgDebayer;

architecture Behavioral of TbGbrgDebayer is

  constant ClockPeriod : time := 10 ns;

  signal Clk      : std_logic := '0';
  signal RstN     : std_logic := '0';
  signal Enable   : std_logic := '0';
  signal PixelIn  : std_logic_vector(7 downto 0) := (others => '0');
  
  signal ValidOut : std_logic;
  signal PixelR   : std_logic_vector(7 downto 0);
  signal PixelG   : std_logic_vector(7 downto 0);
  signal PixelB   : std_logic_vector(7 downto 0);

  file InputFile  : text open read_mode is "inputs.txt";
  file OutputFile : text open read_mode is "expected_outputs.txt";

begin

  -- Instantiate the Device Under Test (DUT)
  Dut: entity work.GbrgDebayer
--    generic map (
--      ImageWidth => 32
--    )
    port map (
      Clk      => Clk,
      RstN     => RstN,
      Enable   => Enable,
      PixelIn  => PixelIn,
      ValidOut => ValidOut,
      PixelR   => PixelR,
      PixelG   => PixelG,
      PixelB   => PixelB
    );

  Clk <= not Clk after ClockPeriod / 2;

  -- Process to drive inputs
  StimulusProcess: process
    variable InputLine : line;
    variable ReadByte  : std_logic_vector(7 downto 0);
    variable ReadGood  : boolean; -- Add this boolean variable
  begin
    RstN <= '0';
    wait for ClockPeriod * 2;
    RstN <= '1';
    Enable <= '1';

    while not endfile(InputFile) loop
      readline(InputFile, InputLine);
      
      -- Attempt to read safely. Does not crash if line is bad/empty.
      hread(InputLine, ReadByte, ReadGood); 
      
      -- Only apply stimulus and advance time if a valid hex was found
      if ReadGood then
        wait until rising_edge(Clk);
        PixelIn <= ReadByte;
      end if;
    end loop;

    -- Wait for pipeline to flush
    wait for ClockPeriod * 10;
    
    assert false report "End of Simulation (Input EOF reached)" severity failure;
  end process;

  -- Process to check outputs whenever ValidOut is high
  MonitorProcess: process
    variable OutputLine : line;
    variable ExpectedR  : std_logic_vector(7 downto 0);
    variable ExpectedG  : std_logic_vector(7 downto 0);
    variable ExpectedB  : std_logic_vector(7 downto 0);
  begin
    wait until rising_edge(Clk);
    
    if ValidOut = '1' then
      if not endfile(OutputFile) then
        readline(OutputFile, OutputLine);
        hread(OutputLine, ExpectedR);
        hread(OutputLine, ExpectedG);
        hread(OutputLine, ExpectedB);

      assert (PixelR = ExpectedR and PixelG = ExpectedG and PixelB = ExpectedB)
          report "Mismatch! The output pixels do not match the expected_outputs.txt file."
          severity error;
      else
        assert false report "ValidOut asserted but no more expected outputs in file!" severity error;
      end if;
    end if;
  end process;

end architecture;
