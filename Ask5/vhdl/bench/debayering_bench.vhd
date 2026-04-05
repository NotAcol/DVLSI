library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity TbGbrgDebayer is
end entity TbGbrgDebayer;

architecture Behavioral of TbGbrgDebayer is

  constant ClockPeriod : time := 10 ns;

  signal Clk           : std_logic := '0';
  signal RstN          : std_logic := '0';
  signal ValidIn       : std_logic := '0';
  signal NewImage      : std_logic := '0';
  signal PixelIn       : std_logic_vector(7 downto 0) := (others => '0');
  
  signal ValidOut      : std_logic;
  signal ImageFinished : std_logic;
  signal PixelR        : std_logic_vector(7 downto 0);
  signal PixelG        : std_logic_vector(7 downto 0);
  signal PixelB        : std_logic_vector(7 downto 0);

  file InputFile  : text open read_mode is "inputs.txt";
  file OutputFile : text open read_mode is "expected_outputs.txt";

begin

  Dut: entity work.GbrgDebayer
    port map (
      Clk           => Clk,
      RstN          => RstN,
      ValidIn       => ValidIn,
      NewImage      => NewImage,
      PixelIn       => PixelIn,
      ValidOut      => ValidOut,
      ImageFinished => ImageFinished,
      PixelR        => PixelR,
      PixelG        => PixelG,
      PixelB        => PixelB
    );

  Clk <= not Clk after ClockPeriod / 2;

StimulusProcess: process
    variable InputLine    : line;
    variable ReadByte     : std_logic_vector(7 downto 0);
    variable ReadGood     : boolean;
    variable IsFirstPixel : boolean := true;
    variable PixelCount   : integer := 0; 
    variable FlushTimeout : integer := 0; 
  begin
    wait for 1000 ns; -- GSR wait

    -- Synchronize to the FALLING edge to provide massive setup/hold margin
    wait until falling_edge(Clk);
    RstN <= '0';
    ValidIn <= '0';
    NewImage <= '0';
    wait for ClockPeriod * 5;
    RstN <= '1';
    wait for ClockPeriod * 2;

    -- 1. Test Robustness
    ValidIn <= '1';
    PixelIn <= x"FF";
    wait for ClockPeriod * 5; 
    ValidIn <= '0';
    wait for ClockPeriod * 2;

    -- 2. Stream real data
    ValidIn <= '1';
    while not endfile(InputFile) loop
      readline(InputFile, InputLine);
      hread(InputLine, ReadByte, ReadGood);
      
      if ReadGood then
        PixelCount := PixelCount + 1;
        PixelIn <= ReadByte;
        
        if IsFirstPixel then
          NewImage <= '1';
          IsFirstPixel := false;
        else
          NewImage <= '0';
        end if;
        
        -- DRIVE ON FALLING EDGE
        wait until falling_edge(Clk);
      end if;
    end loop;

    assert PixelCount > 0 
      report "CRITICAL ERROR: 0 valid pixels read." severity failure;

    -- 3. Flush the pipeline
    PixelIn <= x"00";
    ValidIn <= '1'; 
    NewImage <= '0';
    
    while ImageFinished = '0' loop
      -- WAIT ON FALLING EDGE
      wait until falling_edge(Clk);
      FlushTimeout := FlushTimeout + 1;
      
      assert FlushTimeout < 2000000 
        report "CRITICAL ERROR: Flush loop timed out! ImageFinished never asserted." 
        severity failure;
    end loop;

    -- 4. Clean up
    ValidIn <= '0';
    wait for ClockPeriod * 5;
    
    assert false report "End of Simulation (ImageFinished successfully triggered)" severity failure;
  end process;

  MonitorProcess: process
    variable OutputLine : line;
    variable ExpectedR  : std_logic_vector(7 downto 0);
    variable ExpectedG  : std_logic_vector(7 downto 0);
    variable ExpectedB  : std_logic_vector(7 downto 0);
  begin
    wait until falling_edge(Clk);
    
    if ValidOut = '1' then
      if not endfile(OutputFile) then
        readline(OutputFile, OutputLine);
        hread(OutputLine, ExpectedR);
        hread(OutputLine, ExpectedG);
        hread(OutputLine, ExpectedB);

        assert (PixelR = ExpectedR and PixelG = ExpectedG and PixelB = ExpectedB)
          report "Mismatch! The output pixels do not match the expected_outputs.txt file."
          severity error;

        -- Verify ImageFinished timing
        if endfile(OutputFile) then
          assert ImageFinished = '1' 
            report "ImageFinished should be '1' concurrently with the last ValidOut!" 
            severity error;
        else
          assert ImageFinished = '0' 
            report "ImageFinished asserted too early!" 
            severity error;
        end if;

      else
        assert false report "ValidOut asserted but no more expected outputs in file! (Did the module ingest dummy data?)"
          severity error;
      end if;
    end if;
  end process;

end architecture;
