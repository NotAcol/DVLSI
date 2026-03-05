library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BCD_Tb is
end BCD_Tb;

architecture Simulation of BCD_Tb is
  component BCD
    Port (
      A, B : in  std_logic_vector(3 downto 0);
      Cin  : in  std_logic;
      Sum  : out std_logic_vector(3 downto 0);
      Cout : out std_logic
    );
  end component;

  signal A, B : std_logic_vector(3 downto 0) := (others => '0');
  signal Cin  : std_logic := '0';
  signal Cout : std_logic;
  signal Sum  : std_logic_vector(3 downto 0);
begin

  DUT: BCD port map (
    A    => A,
    B    => B,
    Cin  => Cin,
    Sum  => Sum,
    Cout => Cout
  );

  process begin
    for i in 0 to 9 loop
      for j in 0 to 9 loop
        for k in 0 to 1 loop
          
          A   <= std_logic_vector(to_unsigned(i, 4));
          B   <= std_logic_vector(to_unsigned(j, 4));
          -- NOTE(acol): Cin <= k; doesnt work...........
          if k = 1 then
            Cin <= '1';
          else 
            Cin <= '0';
          end if;
          wait for 10 ns;
          
        end loop;
      end loop;
    end loop;
    wait;
  end process;
end Simulation;