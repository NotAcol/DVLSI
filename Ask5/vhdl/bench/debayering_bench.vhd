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
    wait for 100 ns;

    -- NOTE(acol): -5 hours, drive on falling edge 
    wait until falling_edge(Clk);
    RstN <= '0';
    ValidIn <= '0';
    NewImage <= '0';
    wait for ClockPeriod * 5;
    RstN <= '1';
    wait for ClockPeriod * 2;

    -- NOTE(acol): test with garbage in before NewImage
    ValidIn <= '1';
    PixelIn <= x"FF";
    wait for ClockPeriod * 5; 
    ValidIn <= '0';
    wait for ClockPeriod * 2;

    -- NOTE(acol): real data
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

        wait until falling_edge(Clk);
      end if;
    end loop;

    assert PixelCount > 0 
      report "ERROR: 0 valid pixels read." severity failure;

    -- NOTE(acol): Flush
    PixelIn <= x"00";
    ValidIn <= '1'; 
    NewImage <= '0';
    
    while ImageFinished = '0' loop
      -- WAIT ON FALLING EDGE :)))
      wait until falling_edge(Clk);
      FlushTimeout := FlushTimeout + 1;
      
      assert FlushTimeout < 2000000 
        report "ERROR: Flush loop timed out! ImageFinished never asserted." 
        severity failure;
    end loop;


    ValidIn <= '0';
    wait for ClockPeriod * 5;
    
    assert false report "The good ending" severity failure;
  end process;

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

        -- NOTE(acol): check if output pixel is the expected
        assert (PixelR = ExpectedR and PixelG = ExpectedG and PixelB = ExpectedB)
          report "oh no" severity error;

        -- NOTE(acol): ImageFinished timings
        if endfile(OutputFile) then
          assert ImageFinished = '1' 
            report "ImageFinished not asserted at output end" severity error;
        else
          assert ImageFinished = '0' 
            report "ImageFinished asserted too early" severity error;
        end if;

      else
        -- maybe check if accepting validin before new image signaled
        assert false report "ValidOut asserted past expected eof" severity error;
      end if;
    end if;
  end process;
end architecture;
