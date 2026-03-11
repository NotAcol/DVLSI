library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- NOTE(acol): Helpers for generate loop
-------------------------------------------------------------------------------
entity FAHelper is
  Port(
    Clk  : in  std_logic;
    A    : in  std_logic;
    B    : in  std_logic;
    Sin  : in  std_logic;
    Cin  : in  std_logic;
    Sout : out std_logic;
    Cout : out std_logic
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
begin
  LocalProduct <= A and B;
  FA0: FA port map(Clk, LocalProduct, Sin, Cin, Sout, Cout);
end Structural;

-- lane of helpers
entity FAHelperLane is
  Port(
    Clk   : in  std_logic;
    A     : in  std_logic_vector(3 downto 0); 
    B_bit : in  std_logic;                    
    Sin   : in  std_logic_vector(3 downto 0); 
    Cin   : in  std_logic;                    
    Sout  : out std_logic_vector(3 downto 0); 
    Cout  : out std_logic                     
  );
end FAHelperLane;

architecture Structural of FAHelperLane is
  component FAHelper
    Port(
      Clk  : in  std_logic;
      A    : in  std_logic;
      B    : in  std_logic;
      Sin  : in  std_logic;
      Cin  : in  std_logic;
      Sout : out std_logic;
      Cout : out std_logic
    );
  end component;

  -- internal ripple carry
  signal C : std_logic_vector(4 downto 0) := (others => '0');

begin
  LaneGen: for i in 0 to 3 generate
    Cell: FAHelper port map (Clk, A(i), B_bit, Sin(i), C(i), Sout(i), C(i+1));
  end generate LaneGen;

  C(0) <= Cin;
  Cout <= C(4);
end Structural;
------------------------------------------------------------------------------

-- NOTE(acol): Multiplier implementation
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
      Clk   : in  std_logic;
      A     : in  std_logic_vector(3 downto 0);
      B_bit : in  std_logic;
      Sin   : in  std_logic_vector(3 downto 0);
      Cin   : in  std_logic;
      Sout  : out std_logic_vector(3 downto 0);
      Cout  : out std_logic
    );
  end component;

  signal Row0Sout : std_logic_vector(3 downto 0);
  signal Row0Cout : std_logic;

  signal Reg1Sin  : std_logic_vector(3 downto 0) := (others => '0');
  signal Row1Sout : std_logic_vector(3 downto 0);
  signal Row1Cout : std_logic;

  signal Reg2Sin  : std_logic_vector(3 downto 0) := (others => '0');
  signal Row2Sout : std_logic_vector(3 downto 0);
  signal Row2Cout : std_logic;

  signal Reg3Sin  : std_logic_vector(3 downto 0) := (others => '0');
  signal Row3Sout : std_logic_vector(3 downto 0);
  signal Row3Cout : std_logic;

  signal PReg : std_logic_vector(7 downto 0) := (others => '0');

begin
  -- Add
  Lane0: FAHelperLane port map (Clk, A, B(0), "0000",  '0', Row0Sout, Row0Cout);
  Lane1: FAHelperLane port map (Clk, A, B(1), Reg1Sin, '0', Row1Sout, Row1Cout);
  Lane2: FAHelperLane port map (Clk, A, B(2), Reg2Sin, '0', Row2Sout, Row2Cout);
  Lane3: FAHelperLane port map (Clk, A, B(3), Reg3Sin, '0', Row3Sout, Row3Cout);

  process(Clk) begin
    if rising_edge(Clk) then
      -- And shift
      Reg1Sin(2 downto 0) <= Row0Sout(3 downto 1);
      Reg1Sin(3)          <= Row0Cout;

      Reg2Sin(2 downto 0) <= Row1Sout(3 downto 1);
      Reg2Sin(3)          <= Row1Cout;

      Reg3Sin(2 downto 0) <= Row2Sout(3 downto 1);
      Reg3Sin(3)          <= Row2Cout;

      PReg(0) <= Row0Sout(0);
      PReg(1) <= Row1Sout(0);
      PReg(2) <= Row2Sout(0);
      PReg(3) <= Row3Sout(0);
      PReg(4) <= Row3Sout(1);
      PReg(5) <= Row3Sout(2);
      PReg(6) <= Row3Sout(3);
      PReg(7) <= Row3Cout;
    end if;
  end process;

  Product <= PReg;
end Structural;
