library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity HalfAdder_Tb is
end HalfAdder_Tb;

architecture Simulation of HalfAdder_Tb is
  component HalfAdder
    Port ( 
      A, B : in std_logic;
      S, C : out std_logic
    );
  end component;

  signal A, B : std_logic := '0';
  signal S, C : std_logic;

begin

  DUT: HalfAdder port map (
    A => A,
    B => B,
    S => S,
    C => C
  );

  process begin
    a <= '0'; b <= '0';
    wait for 10 ns;
    a <= '0'; b <= '1';
    wait for 10 ns;
    a <= '1'; b <= '0';
    wait for 10 ns;
    a <= '1'; b <= '1';
    wait;
  end process;
end architecture;
