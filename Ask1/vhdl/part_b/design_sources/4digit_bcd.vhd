library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BCD4 is
  Port (
    A, B : in  std_logic_vector(15 downto 0);
    Cin  : in  std_logic;
    Sum  : out std_logic_vector(15 downto 0);
    Cout : out std_logic
  );
end BCD4;

architecture Structural of BCD4 is
  component BCD is
    Port (
      A    : in  std_logic_vector(3 downto 0);
      B    : in  std_logic_vector(3 downto 0);
      Cin  : in  std_logic;
      Sum    : out std_logic_vector(3 downto 0);
      Cout : out std_logic 
    );
  end component;

  signal C : std_logic_vector(4 downto 0);
begin
  C(0) <= Cin;
  Cout <= C(4);

  Gen_BCD: for i in 0 to 3 generate
    BCDInstance: BCD port map (
      A    => A(i * 4 + 3 downto i * 4),
      B    => B(i * 4 + 3 downto i * 4), 
      Cin  => C(i),
      Sum  => S(i * 4 + 3 downto i * 4),
      Cout => C(i + 1)
    );
  end generate Gen_BCD;
end Structural;
