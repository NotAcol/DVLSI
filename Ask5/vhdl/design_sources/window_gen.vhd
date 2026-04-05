library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.all;

entity WindowGenerator is
  generic(
    ImageWidth : integer := 1024
  );
  port(
    Clk     : in  std_logic;
    RstN    : in  std_logic;
    Enable  : in  std_logic;
    PixelIn : in  std_logic_vector(7 downto 0);
    
    Out00, Out01, Out02 : out std_logic_vector(7 downto 0);
    Out10, Out11, Out12 : out std_logic_vector(7 downto 0);
    Out20, Out21, Out22 : out std_logic_vector(7 downto 0)
  );
end WindowGenerator;

architecture Structural of WindowGenerator is
  type window_grid_type is array (0 to 2, 0 to 2) of std_logic_vector(7 downto 0);

  signal WindowGrid : window_grid_type;
  signal Buffer1Out : std_logic_vector(7 downto 0);
  signal Buffer2Out : std_logic_vector(7 downto 0);
begin
  -- NOTE(acol): grid to output
  Out00 <= WindowGrid(0,0); Out01 <= WindowGrid(0,1); Out02 <= WindowGrid(0,2);
  Out10 <= WindowGrid(1,0); Out11 <= WindowGrid(1,1); Out12 <= WindowGrid(1,2);
  Out20 <= WindowGrid(2,0); Out21 <= WindowGrid(2,1); Out22 <= WindowGrid(2,2);

  -- NOTE(acol): Instantiations
  RingBuffer1: entity RingBuffer
    generic map(
      Depth => ImageWidth
    )
    port map(
      Clk     => Clk,
      RstN    => RstN,
      Enable  => Enable,
      -- NOTE(acol): Can make buffers 3 entries smaller this way
      DataIn  => WindowGrid(2, 0),
      DataOut => Buffer1Out
    );
    RingBuffer2: entity RingBuffer
    generic map(
      Depth => ImageWidth
    )
    port map(
      Clk     => Clk,
      RstN    => RstN,
      Enable  => Enable,
      DataIn  => WindowGrid(1, 0),
      DataOut => Buffer2Out
    );

  process(Clk) begin
    if rising_edge(Clk) then
      if RstN = '0' then
        -- NOTE(acol): zero out grid, will also feed 0s into fifos
        for RowIdx in 0 to 2 loop
          for ColIdx in 0 to 2 loop
            WindowGrid(RowIdx, ColIdx) <= (others => '0');
          end loop;
        end loop;

      elsif Enable = '1' then
        -- NOTE(acol): shift grid left
        for RowIdx in 0 to 2 loop
          for ColIdx in 0 to 1 loop
            WindowGrid(RowIdx, ColIdx) <= WindowGrid(RowIdx, ColIdx + 1);
          end loop;
        end loop;

        -- NOTE(acol): get data from axi and fifos in image pixel orde
        WindowGrid(2, 2) <= PixelIn;
        WindowGrid(1, 2) <= Buffer1Out;
        WindowGrid(0, 2) <= Buffer2Out;
      end if;
    end if;
  end process;
end Structural;
