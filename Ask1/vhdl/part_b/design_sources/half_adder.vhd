library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity HalfAdder is
  Port(
    A, B: in std_logic;
    S, C: out std_logic
  );
end entity;

architecture Dataflow of HalfAdder is
begin
  C <= A and B;
  S <= A xor B;
end architecture;