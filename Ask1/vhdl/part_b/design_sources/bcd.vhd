library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BCD is
  Port (
    A, B : in  std_logic_vector(3 downto 0);
    Cin  : in  std_logic;
    Sum  : out std_logic_vector(3 downto 0);
    Cout : out std_logic
  );
end BCD;

architecture Structural of BCD is
  component FullAdder4 is
    Port (
      A, B : in  std_logic_vector(3 downto 0);
      Cin  : in  std_logic; 
      Sum  : out std_logic_vector(3 downto 0);
      Cout : out std_logic
    );
  end component;

  signal C, Cint : std_logic;
  signal A2, B2  : std_logic_vector(3 downto 0);

begin
  Adder1 : FullAdder4 port map (A, B, Cin, A2, C);

  Cint <= C or (A2(3) and A2(2)) or (A2(3) and A2(1));
  Cout <= Cint;

  B2(0) <= '0';
  B2(1) <= Cint;
  B2(2) <= Cint;
  B2(3) <= '0';

  Adder2 : FullAdder4 port map (A2, B2, '0', Sum, open);
end architecture;
