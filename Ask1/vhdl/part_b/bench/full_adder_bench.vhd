library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FullAdder_Tb is
end FullAdder_Tb;

architecture Simulation of FullAdder_Tb is
  component FullAdder
    Port ( 
      A, B, Cin  : in  std_logic;
      Sum, Cout  : out std_logic
    );
  end component;

  signal A, B, Cin : std_logic := '0';
  signal Sum, Cout : std_logic;
begin

  DUT: FullAdder port map (
    A => A,
    B => B,
    Cin => Cin,
    Sum => Sum,
    Cout => Cout
  );

  process
    variable TestVector : unsigned(2 downto 0);
  begin
    for i in 0 to 7 loop
      TestVector := to_unsigned(i, 3);
      A   <= TestVector(2);
      B   <= TestVector(1);
      Cin <= TestVector(0);
      wait for 10 ns;
    end loop;

    wait;

  end process;
end architecture;
