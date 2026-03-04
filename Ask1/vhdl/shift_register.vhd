library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ShiftRegister is
  Port(
    Clk, Reset, Load, Enable, SerIn, SlideDir: in std_logic;
    I : in std_logic_vector(3 downto 0);
    O : out std_logic
  );
end entity;

architecture zzz of ShiftRegister is 
  signal DataReg: std_logic_vector(3 downto 0);
begin

  edge:process(Clk, Reset) begin
    if Reset = '1' then
      DataReg <= (others => '0');
    elsif rising_edge(Clk) then
      if Load = '1' then
        DataReg <= I;
      elsif Enable = '1' and SlideDir = '1' then
        DataReg <= SerIn & DataReg(3 downto 1);
      elsif Enable = '1' and SlideDir = '0' then
        DataReg <= DataReg(2 downto 0) & SerIn;
      end if;
    end if;
  end process;

  O <= DataReg(0) when SlideDir = '1' else DataReg(3);

end zzz;
