library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FullAdder is
  Port ( 
    A, B, Cin  : in  std_logic;
    Sum, Cout  : out std_logic
  );
end FullAdder;

architecture Structural of FullAdder is
  component HalfAdder
    Port ( 
      A, B : in  std_logic;
      S, C : out std_logic
    );
  end component;

  signal S1, C1, C2 : std_logic; 
begin

  HA1: HalfAdder port map (A => A, B => B, S => S1, C => C1);
  HA2: HalfAdder port map (A => S1, B => Cin, S => Sum, C => C2);
  Cout <= C1 or C2;

end architecture;
