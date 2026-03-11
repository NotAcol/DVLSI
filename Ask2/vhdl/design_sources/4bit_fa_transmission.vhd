library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FA4Transmission is
  Port(
    Clk, Cin : in std_logic;
    A, B : in std_logic_vector(3 downto 0);
    Sum  : out std_logic_vector(3 downto 0);
    Cout : out std_logic
  );
end FA4Transmission;

architecture Structural of FA4Transmission is

  component FA 
    Port(
      Clk, A, B, Cin : in std_logic;
      Sum, Cout : out std_logic
    );
  end component;

  signal Stage1Regs : std_logic_vector(6 downto 0);
  signal Stage2Regs : std_logic_vector(5 downto 0);
  signal Stage3Regs : std_logic_vector(4 downto 0);

  signal C : std_logic_vector(3 downto 0);
  signal SumWires : std_logic_vector(3 downto 0);
begin

  FA0: FA port map (Clk, A(0), B(0), Cin, SumWires(0), C(0));
  FA1: FA port map (Clk, Stage1Regs(1), Stage1Regs(4), C(0), SumWires(1), C(1));
  FA2: FA port map (Clk, Stage2Regs(2), Stage2Regs(4), C(1), SumWires(2), C(2));
  FA3: FA port map (Clk, Stage3Regs(3), Stage3Regs(4), C(2), SumWires(3), C(3));

  process(Clk) begin
    if rising_edge(Clk) then
        
      Stage1Regs(3 downto 1) <= A(3 downto 1);
      Stage1Regs(6 downto 4) <= B(3 downto 1);
      Stage1Regs(0) <= SumWires(0);

      Stage2Regs(0) <= Stage1Regs(0);
      Stage2Regs(3 downto 2) <= Stage1Regs(3 downto 2);
      Stage2Regs(5 downto 4) <= Stage1Regs(6 downto 5);
      Stage2Regs(1) <= SumWires(1);

      Stage3Regs(1 downto 0) <= Stage2Regs(1 downto 0);
      Stage3Regs(3) <= Stage2Regs(3);
      Stage3Regs(4) <= Stage2Regs(5);
      Stage3Regs(2) <= SumWires(2);

      Sum(2 downto 0) <= Stage3Regs(2 downto 0);
      Sum(3) <= SumWires(3);
      Cout <= C(3);

    end if;
  end process;
end architecture;
