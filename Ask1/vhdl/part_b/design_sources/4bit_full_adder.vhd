library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FullAdder4 is
  Port ( 
    A, B : in  std_logic_vector(3 downto 0);
    Cin  : in  std_logic;
    Sum  : out std_logic_vector(3 downto 0);
    Cout : out std_logic
  );
end FullAdder4;

architecture Structural of FullAdder4 is
  component FullAdder
    Port ( 
      A, B, Cin : in  std_logic;
      Sum, Cout : out std_logic
    );
  end component;

  signal C : std_logic_vector(4 downto 0);

begin
  C(0) <= Cin;
  Cout <= C(4);

  Gen_FA: for i in 0 to 3 generate
    FAInstance: FullAdder port map (
      A    => A(i),
      B    => B(i),
      Cin  => C(i), 
      Sum  => Sum(i),
      Cout => C(i+1)
    );
  end generate;
end architecture;
