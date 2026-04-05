library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity GbrgDebayer is
  generic(
    ImageWidth  : integer := 32
  );
  port(
    Clk      : in std_logic;
    RstN     : in std_logic;
    ValidIn  : in std_logic;
    NewImage : in std_logic;
    PixelIn  : in std_logic_vector(7 downto 0);

    ValidOut      : out std_logic;
    ImageFinished : out std_logic;
    PixelR        : out std_logic_vector(7 downto 0);
    PixelG        : out std_logic_vector(7 downto 0);
    PixelB        : out std_logic_vector(7 downto 0)
  );
end entity GbrgDebayer;

architecture Behavioral of GbrgDebayer is
  constant ImageHeight : integer := ImageWidth;
  type pixel_grid_type is array (0 to 2, 0 to 2) of unsigned(7 downto 0);
  
  signal Out00, Out01, Out02 : std_logic_vector(7 downto 0);
  signal Out10, Out11, Out12 : std_logic_vector(7 downto 0);
  signal Out20, Out21, Out22 : std_logic_vector(7 downto 0);
  
  signal PaddedGrid : pixel_grid_type;
  
  signal InCol     : natural range 0 to ImageWidth - 1;
  signal InRow     : natural range 0 to ImageHeight - 1;
  signal CenterCol : natural range 0 to ImageWidth - 1;
  signal CenterRow : natural range 0 to ImageHeight - 1;
  
  -- NOTE(acol): internal state
  signal PipelineFilled : std_logic;
  signal IsProcessing   : std_logic;

  -- NOTE(acol): helper variable
  signal Enable : std_logic;

  -- NOTE(acol): edge case flags
  signal TopEdge, BottomEdge, LeftEdge, RightEdge : boolean;

  -- NOTE(acol): will always calc them and just stuff the correct 
  --             thing to output after shifts
  signal SumCross : unsigned(9 downto 0);
  signal SumDiag  : unsigned(9 downto 0);
  signal SumVert  : unsigned(8 downto 0);
  signal SumHorz  : unsigned(8 downto 0);
begin

  WindowGenInst: entity WindowGenerator
    generic map(
      ImageWidth => ImageWidth
    )
    port map(
      Clk     => Clk,
      RstN    => RstN,
      Enable  => Enable,
      PixelIn => PixelIn,
      Out00   => Out00, Out01 => Out01, Out02 => Out02,
      Out10   => Out10, Out11 => Out11, Out12 => Out12,
      Out20   => Out20, Out21 => Out21, Out22 => Out22
    );

  -- NOTE(acol): determine enable conditions
  Enable <= ValidIn and (NewImage or IsProcessing);

  -- NOTE(acol): Edge cases from output position
  TopEdge    <= (CenterRow = 0);
  BottomEdge <= (CenterRow = ImageHeight - 1);
  LeftEdge   <= (CenterCol = 0);
  RightEdge  <= (CenterCol = ImageWidth - 1);

  -- NOTE(acol): mux logic to decouple edge cases from compute
  -- we got A?B:C at home :)
  PaddedGrid(0,0) <= (others => '0') when (TopEdge or LeftEdge) else unsigned(Out00);
  PaddedGrid(0,1) <= (others => '0') when TopEdge else unsigned(Out01);
  PaddedGrid(0,2) <= (others => '0') when (TopEdge or RightEdge) else unsigned(Out02);

  PaddedGrid(1,0) <= (others => '0') when LeftEdge else unsigned(Out10);
  PaddedGrid(1,1) <= unsigned(Out11);
  PaddedGrid(1,2) <= (others => '0') when RightEdge else unsigned(Out12);
  
  PaddedGrid(2,0) <= (others => '0') when (BottomEdge or LeftEdge) else unsigned(Out20);
  PaddedGrid(2,1) <= (others => '0') when BottomEdge else unsigned(Out21);
  PaddedGrid(2,2) <= (others => '0') when (BottomEdge or RightEdge) else unsigned(Out22);

  -- NOTE(acol): compute common
  SumCross <= ("00" & PaddedGrid(0,1)) + ("00" & PaddedGrid(1,0)) + ("00" & PaddedGrid(1,2)) + ("00" & PaddedGrid(2,1));
  SumDiag  <= ("00" & PaddedGrid(0,0)) + ("00" & PaddedGrid(0,2)) + ("00" & PaddedGrid(2,0)) + ("00" & PaddedGrid(2,2));
  SumVert  <= ('0' & PaddedGrid(0,1)) + ('0' & PaddedGrid(2,1));
  SumHorz  <= ('0' & PaddedGrid(1,0)) + ('0' & PaddedGrid(1,2));

  process(Clk, RstN) begin
    if RstN = '0' then
      InCol          <= 0;
      InRow          <= 0;
      CenterCol      <= 0;
      CenterRow      <= 0;
      PipelineFilled <= '0';
      IsProcessing   <= '0';
      ValidOut       <= '0';
      ImageFinished  <= '0';
      PixelR         <= (others => '0');
      PixelG         <= (others => '0');
      PixelB         <= (others => '0');

    elsif rising_edge(Clk) then
      if Enable = '1' then

        if NewImage = '1' then
          -- NOTE(acol): idle -> processing + reset state
          IsProcessing <= '1';
          InCol <= 1; 
          InRow <= 0;
          CenterCol <= 0;
          CenterRow <= 0;
          PipelineFilled <= '0';
          ValidOut <= '0';
          ImageFinished <= '0';
        else 

          ----------------------------------------------------------------
          --                NOTE(acol): fifo handling 
          ----------------------------------------------------------------

          -- NOTE(acol): keep track of input pixel position
          if InCol /= ImageWidth - 1 then
            -- if not in last col go next
            InCol <= InCol + 1;
          else
            -- else wrap back
            InCol <= 0;
            if InRow /= ImageHeight - 1 then
              -- if not last row go next
              InRow <= InRow + 1;
            else
              -- else wrap back
              InRow <= 0;
            end if;
          end if;

          if PipelineFilled = '0' then
            -- NOTE(acol): wait for enough inputs
            if InRow = 1 and InCol = 1 then
              PipelineFilled <= '1';
              CenterRow <= 0;
              CenterCol <= 0;
            end if;
          else
            -- NOTE(acol): same logic as above but for the output pixel
            if CenterCol /= ImageWidth - 1 then
              CenterCol <= CenterCol + 1;
            else
              CenterCol <= 0;
              if CenterRow /= ImageHeight - 1 then
                CenterRow <= CenterRow + 1;
              else
                CenterRow <= 0;
                -- Stop when out of bounds
                PipelineFilled <= '0';
              end if;
            end if;
          end if;

          -- NOTE(acol): enable isnt needed here but keeping it for my own sanity 👍
          ValidOut <= PipelineFilled and Enable;

          -- NOTE(acol): success conditions
          if PipelineFilled = '1' and CenterCol = ImageWidth -1 
                                  and CenterRow = ImageHeight - 1 then
            ImageFinished <= '1';
            IsProcessing  <= '0';
          else
            ImageFinished <= '0'; 
          end if;

          ----------------------------------------------------------------
          --                NOTE(acol): Computations
          ----------------------------------------------------------------

          if PipelineFilled = '1' then
            if (CenterRow mod 2 = 0) and (CenterCol mod 2 = 0) then
              -- NOTE(acol): GB
              PixelG <= std_logic_vector(PaddedGrid(1,1));
              -- << 1
              PixelB <= std_logic_vector(SumHorz(8 downto 1));
              PixelR <= std_logic_vector(SumVert(8 downto 1));
              
            elsif (CenterRow mod 2 = 0) and (CenterCol mod 2 /= 0) then
              -- NOTE(acol): B
              PixelB <= std_logic_vector(PaddedGrid(1,1));
              -- << 2
              PixelG <= std_logic_vector(SumCross(9 downto 2));
              PixelR <= std_logic_vector(SumDiag(9 downto 2));
              
            elsif (CenterRow mod 2 /= 0) and (CenterCol mod 2 = 0) then
              -- NOTE(acol): R
              PixelR <= std_logic_vector(PaddedGrid(1,1));
              -- << 2
              PixelG <= std_logic_vector(SumCross(9 downto 2));
              PixelB <= std_logic_vector(SumDiag(9 downto 2));
              
            else
              -- NOTE(acol): GR
              PixelG <= std_logic_vector(PaddedGrid(1,1));
              -- << 1
              PixelR <= std_logic_vector(SumHorz(8 downto 1));
              PixelB <= std_logic_vector(SumVert(8 downto 1));
            end if;
          end if;
        end if;

      else
        -- NOTE(acol): If not enable just wait
        ValidOut <= '0';
        ImageFinished <= '0';
      end if;
    end if;
  end process;
end architecture;
