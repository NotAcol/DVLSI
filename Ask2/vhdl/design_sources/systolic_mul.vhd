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
end FAHelperLane;

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

  -- B(4) is dead code eliminated
  signal C, B : std_logic_vector(4 downto 0) := (others => '0');

begin
  B(0) <= Bin;
  C(0) <= Cin;

  LaneGen: for i in 0 to 3 generate
    Cell: FAHelper port map (
      Clk, Ain(i), B(i), Sin(i), C(i), Sout(i), C(i + 1), Aout(i), B(i + 1)
    );
  end generate LaneGen;
  
  -- stagger last output
  process(Clk) begin
    if rising_edge(Clk) then
      Cout <= C(4);
    end if;
  end process;
end architecture;


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
      Clk  : in  std_logic;
      Bin  : in  std_logic;
      Cin  : in  std_logic;
      Ain  : in  std_logic_vector(3 downto 0);
      Sin  : in  std_logic_vector(3 downto 0);
      Aout : out std_logic_vector(3 downto 0);
      Sout : out std_logic_vector(3 downto 0);
      Cout : out std_logic
    );
  end component;

  type VectorArray is array (0 to 4) of std_logic_vector(3 downto 0);
  type BitArray    is array (0 to 4) of std_logic;
  type Array4Bit   is array (0 to 6) of std_logic_vector(3 downto 0);
  type Array8Bit   is array (0 to 9) of std_logic_vector(7 downto 0);

  signal RowAin, RowAout, RowSin, RowSout : VectorArray := (others => (others => '0'));
  signal RowCout                          : BitArray    := (others => '0');

  signal ASkew   : Array4Bit := (others => "0000");
  signal BSkew   : Array4Bit := (others => "0000");
  signal PDeskew : Array8Bit := (others => "00000000");

begin
  process(Clk) begin
    -- Stagger grids
    if rising_edge(Clk) then
      -- A B skew grid inputs
      ASkew(0) <= A;
      BSkew(0) <= B;
      -- A B skew grid progression
      for i in 0 to 5 loop
        ASkew(i+1) <= ASkew(i);
        BSkew(i+1) <= BSkew(i);
      end loop;

      -- Product deskew grid inputs
      PDeskew(0)(0) <= RowSout(0)(0);
      PDeskew(0)(1) <= RowSout(1)(0);
      PDeskew(0)(2) <= RowSout(2)(0);
      PDeskew(0)(3) <= RowSout(3)(0);
      PDeskew(0)(4) <= RowSout(3)(1);
      PDeskew(0)(5) <= RowSout(3)(2);
      PDeskew(0)(6) <= RowSout(3)(3);
      -- Product deskew grid progression
      for i in 0 to 8 loop
        PDeskew(i+1) <= PDeskew(i);
      end loop;

    end if;
  end process;

  -- Row 1 inputs
  RowAin(0)  <= ASkew(3)(3) & ASkew(2)(2) & ASkew(1)(1) & ASkew(0)(0);
  RowSin(0)  <= "0000";

  -- Row gen and connections
  LaneGen: for i in 0 to 3 generate
    LaneInst: FAHelperLane port map (
      Clk, BSkew(i * 2)(i), '0', RowAin(i), RowSin(i), RowAout(i), RowSout(i), RowCout(i)
    );

    RowAin(i+1)             <= RowAout(i);
    RowSin(i+1)(2 downto 0) <= RowSout(i)(3 downto 1);
    RowSin(i+1)(3)          <= RowCout(i);
  end generate LaneGen;

  -- Outputs
  Product(0) <= PDeskew(9)(0);
  Product(1) <= PDeskew(7)(1);
  Product(2) <= PDeskew(5)(2);
  Product(3) <= PDeskew(3)(3);
  Product(4) <= PDeskew(2)(4);
  Product(5) <= PDeskew(1)(5);
  Product(6) <= PDeskew(0)(6);
  Product(7) <= RowCout(3);
end Structural;
