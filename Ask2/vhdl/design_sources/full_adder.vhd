library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FA is
  Port (
    Clk, A, B, Cin : in std_logic;
    Sum  : out std_logic;
    Cout : out std_logic
  );
end FA;

architecture Behavioral of FA is
begin

  process(Clk)
    if rising_edge(Clk) then
      Sum <= A xor B xor Cin;
      Cout <= (A and B) or (Cin and A) or (Cin and B);
    end if;
  end process;
end architecture;
