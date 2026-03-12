-- NOTE(acol): Helpers
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FAHelper is
  Port(
    Clk, Ain, Bin : in std_logic;
    Sin           : in  std_logic;
    Cin           : in  std_logic;
    Sout          : out std_logic;
    Cout          : out std_logic;
    Aout, Bout    : out std_logic
  );
end FAHelper;

architecture Structural of FAHelper is
  component FA 
    Port(
      Clk  : in  std_logic;
      A    : in  std_logic;
      B    : in  std_logic;
      Cin  : in  std_logic;
      Sum  : out std_logic;
      Cout : out std_logic
    );
  end component;

  signal LocalProduct : std_logic;
  signal ADelay : std_logic_vector(1 downto 0);
  signal BDelay : std_logic;
begin
  LocalProduct <= Ain and Bin;
  FA0: FA port map(Clk, LocalProduct, Sin, Cin, Sout, Cout);

  process(Clk) begin
    if rising_edge(Clk) then
      ADelay(0) <= Ain;
      ADelay(1) <= ADelay(0);
      
      BDelay <= Bin;
    end if;
  end process;

  Aout <= ADelay(1);
  Bout <= BDelay;

end Structural;

-- Helper lane
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FAHelperLane is
  Port(
    Clk, Bin, Cin : in std_logic;
    Ain, Sin      : in std_logic_vector(3 downto 0);
    Aout, Sout    : out std_logic_vector(3 downto 0);
    Cout          : out std_logic
  );
end FAHelperLange;

architecture Structural of FAHelperLane is
  component FAHelper
    Port(
      Clk, Ain, Bin : in std_logic;
      Sin           : in  std_logic;
      Cin           : in  std_logic;
      Sout          : out std_logic;
      Cout          : out std_logic;
      Aout, Bout    : out std_logic
    );
  end component;

  -- B(4) isn't read  
  signal C, B : std_logic_vector(4 downto 0) := (others => '0');

begin

  B(0) <= Bin;
  C(0) <= Cin;
  Cout <= C(4);

  LaneGen: for i in 0 to 3 generate
    Cell: FAHelper port map (
      Clk, Ain(i), B(i), Sin(i), C(i), Sout(i), C(i + 1), Aout(i), B(i + 1)
    );
  end generate LaneGen;
end architecture




------------------------------------------------------------------------------

-- NOTE(acol): Multiplier implementation
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SystolicMultiplier4Bit is
  Port(
    Clk     : in  std_logic;
    A       : in  std_logic_vector(3 downto 0);
    B       : in  std_logic_vector(3 downto 0);
    Product : out std_logic_vector(7 downto 0)
  );
end SystolicMultiplier4Bit;

architecture Structural of SystolicMultiplier4Bit is

  component FAHelperLane
    Port(
      Clk, Bin, Cin : in  std_logic;
      Ain, Sin      : in  std_logic_vector(3 downto 0);
      Aout, Sout    : out std_logic_vector(3 downto 0);
      Cout          : out std_logic
    );
  end component;
  
  -- maybe generate ?
  signal Row0Aout : std_logic_vector(3 downto 0);
  signal Row0Sout : std_logic_vector(3 downto 0);
  signal Row0Cout : std_logic;

  signal Row1Sin  : std_logic_vector(3 downto 0);
  signal Row1Aout : std_logic_vector(3 downto 0);
  signal Row1Sout : std_logic_vector(3 downto 0);
  signal Row1Cout : std_logic;

  signal Row2Sin  : std_logic_vector(3 downto 0);
  signal Row2Aout : std_logic_vector(3 downto 0);
  signal Row2Sout : std_logic_vector(3 downto 0);
  signal Row2Cout : std_logic;

  signal Row3Sin  : std_logic_vector(3 downto 0);
  signal Row3Aout : std_logic_vector(3 downto 0);
  signal Row3Sout : std_logic_vector(3 downto 0);
  signal Row3Cout : std_logic;

  signal P0Delay1, P0Delay2, P0Delay3 : std_logic := '0';
  signal P1Delay1, P1Delay2           : std_logic := '0';
  signal P2Delay1                     : std_logic := '0';

begin
  Lane0: FAHelperLane port map (
    Clk, B(0), '0', A, "0000", Row0Aout, Row0Sout, Row0Cout
  );

  Row1Sin(2 downto 0) <= Row0Sout(3 downto 1);
  Row1Sin(3)          <= Row0Cout;

  Lane1: FAHelperLane port map ( 
    Clk, B(1), '0', Row0Aout, Row1Sin, Row1Aout, Row1Sout, Row1Cout
  );

  Row2Sin(2 downto 0) <= Row1Sout(3 downto 1);
  Row2Sin(3)          <= Row1Cout;

  Lane2: FAHelperLane port map ( 
    Clk, B(2), '0', Row1Aout, Row2Sin, Row2Aout, Row2Sout, Row2Cout
  );

  Row3Sin(2 downto 0) <= Row2Sout(3 downto 1);
  Row3Sin(3)          <= Row2Cout;

  Lane3: FAHelperLane port map ( 
    Clk, B(3), '0', Row2Aout, Row3Sin, Row3Aout, Row3Sout, Row3Cout
  );

  -- Delays
  process(Clk) begin
    if rising_edge(Clk) then
      P0Delay1 <= Row0Sout(0);
      P0Delay2 <= P0Delay1;
      P0Delay3 <= P0Delay2;

      P1Delay1 <= Row1Sout(0);
      P1Delay2 <= P1Delay1;

      P2Delay1 <= Row2Sout(0);
    end if;
  end process;

  Product(0) <= P0Delay3;
  Product(1) <= P1Delay2;
  Product(2) <= P2Delay1;
  Product(3) <= Row3Sout(0);
  Product(4) <= Row3Sout(1);
  Product(5) <= Row3Sout(2);
  Product(6) <= Row3Sout(3);
  Product(7) <= Row3Cout;

end architecture;
