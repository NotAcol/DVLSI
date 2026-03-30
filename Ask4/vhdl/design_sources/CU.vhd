library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity CU is 
  Port(
    Clk, Reset, ValidIn            : in std_logic;
    ValidOut, RomEnable, RamEnable : out std_logic;
    RamWEnable, MacEnable, MacInit : out std_logic;
    RamAddress, RomAddress         : out std_logic_vector(2 downto 0)
  );
end entity;

architecture Behavioral of CU is 
  signal Counter : std_logic_vector(2 downto 0) := (others => '0');
  -- NOTE(acol): Added busy flag
  signal Busy : std_logic := '0';
begin
  process(Clk, Reset) begin
    if Reset = '1' then
      Counter     <= (others => '0');
      ValidOut    <= '0';
      RamEnable   <= '0';
      RamWEnable  <= '0';
      MacEnable   <= '0';
      MacInit     <= '0';

    elsif rising_edge(Clk) then
      RomEnable  <= '1';
      RamEnable  <= '1';
      MacEnable  <= '1';
      MacInit    <= '0';
      ValidOut   <= '0';
      RamWEnable <= '0';

      -- NOTE(acol): Only send ValidOut if last 8 cycles where after a new input
      if Counter = "111" and Busy = '1' then
        ValidOut <= '1';
        Busy     <= '0';
      end if;

      -- NOTE(acol): Busy = 1 after useful input
      if ValidIn = '1' then
        RamWEnable <= '1';
        MacInit    <= '1';
        Counter    <= "000";
        Busy       <= '1';

      -- NOTE(acol): Dont count if not calculating something, 
      --             not needed but maybe less energy use?
      elsif Busy = '1' then
        Counter <= Counter + 1;
      end if;
    end if;
  end process;
  RamAddress <= Counter;
  RomAddress <= Counter;

end architecture;
