library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BCD4_Tb is
end BCD4_Tb;

architecture Simulation of BCD4_Tb is
  component BCD4
    Port (
      A, B : in  std_logic_vector(15 downto 0);
      Cin  : in  std_logic;
      Sum  : out std_logic_vector(15 downto 0);
      Cout : out std_logic
    );
  end component;

  signal A, B : std_logic_vector(15 downto 0) := (others => '0');
  signal Cin  : std_logic := '0';
  signal Sum  : std_logic_vector(15 downto 0);
  signal Cout : std_logic;
begin

  DUT: BCD4 port map (A, B, Cin, Sum, Cout);

  process begin
    -- Sum = x"5555", Cout = '0'
    A <= x"1234"; B <= x"4321"; Cin <= '0';
    wait for 10 ns;
    -- Sum = x"0010", Cout = '0'
    A <= x"0009"; B <= x"0001"; Cin <= '0';
    wait for 10 ns;
    -- Sum = x"0000", Cout = '1'
    A <= x"9999"; B <= x"0001"; Cin <= '0';
    wait for 10 ns;
    -- Sum = x"7776", Cout = '1'
    A <= x"8888"; B <= x"8888"; Cin <= '0';
    wait for 10 ns;
    -- Sum = x"2346", Cout = '0'
    A <= x"1111"; B <= x"1234"; Cin <= '1';
    wait for 10 ns;
    wait;
  end process;
end Simulation;
