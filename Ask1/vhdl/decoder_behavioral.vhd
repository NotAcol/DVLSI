library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Decoder3x8 is
 port (
   I : in  std_logic_vector(2 downto 0);
   O : out std_logic_vector(7 downto 0));
end entity;

architecture Behavioral of Decoder3x8 is 
begin
  process(I)
  begin
    case I is
      when "000"  => O <= "00000001";
      when "001"  => O <= "00000010";
      when "010"  => O <= "00000100";
      when "011"  => O <= "00001000";
      when "100"  => O <= "00010000";
      when "101"  => O <= "00100000";
      when "110"  => O <= "01000000";
      when "111"  => O <= "10000000";
      when others => O <= (others => '-');
    end case;
  end process;
end Behavioral;
