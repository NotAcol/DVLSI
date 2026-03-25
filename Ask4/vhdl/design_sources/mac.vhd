library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Mac is 
  Port(
    Clk, Enable, Reset, Init : in std_logic;
    IRCoeff, Sig : in std_logic_vector(7 downto 0);
    YOut  : out std_logic_vector(18 downto 0)
  );
end entity;

architecture Behavioral of Mac is 
  signal Acc : std_logic_vector(18 downto 0);
begin

  process(Clk, Reset) begin
    if Reset = '1' then
      Acc <= (others => '0');

    elsif rising_edge(Clk) then 
      if Init = '1' then
        -- NOTE(acol): NOT 0 casue you miss a tap... :(
        Acc <= "000" & (IRCoeff * Sig);
      elsif Enable = '1' then
        Acc <= Acc + ("000" &(IRCoeff * Sig));
      end if;
    end if;
  end process;

  YOut <=  Acc;
end architecture;
