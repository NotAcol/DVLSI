library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Bench is
end entity;

architecture Dataflow of Bench is
  component Decoder3x8 is
  port (
    I   : in  std_logic_vector(2 downto 0);
    O   : out std_logic_vector(7 downto 0)
  );
  end component;
signal I: std_logic_vector(2 downto 0);
signal O: std_logic_vector(7 downto 0);

begin
  uut: Decoder3x8 port map (I => I, O => O);

  process begin

    for j in 0 to 7 loop
      I <= std_logic_vector(to_unsigned(j, 3));
      wait for 10 ns;
      end loop;
    wait;

  end process;
end architecture;
