library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FullAdder4_Tb is
end FullAdder4_Tb;

architecture Simulation of FullAdder4_Tb is

  component FullAdder4
    Port ( 
      A, B : in  std_logic_vector(3 downto 0);
      Cin  : in  std_logic;
      Sum  : out std_logic_vector(3 downto 0);
      Cout : out std_logic
    );
  end component;

  signal A, B : std_logic_vector(3 downto 0) := (others => '0');
  signal Cin  : std_logic := '1';
  signal Sum  : std_logic_vector(3 downto 0);
  signal Cout : std_logic;
begin

  DUT: FullAdder4 port map (
    A    => A,
    B    => B,
    Cin  => Cin,
    Sum  => Sum,
    Cout => Cout
  );

  process begin
    for i in 0 to 15 loop
      for j in 0 to 15 loop
          
          A <= std_logic_vector(to_unsigned(i, 4));
          B <= std_logic_vector(to_unsigned(j, 4));
          wait for 10 ns;

        end loop;
      end loop;
    end loop;
    wait;
  end process;
end Simulation;
