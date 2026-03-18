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
begin

  process(Clk, Reset) begin
    if Reset = '1' then
      Counter <= (others => '0');
      ValidOut <= '0';
      --RomEnable <= '0';
      RamEnable <= '0';
      RamWEnable <= '0';
      MacEnable <= '0';
      MacInit <= '0';

    elsif rising_edge(Clk) then

      RomEnable <= '1';
      RamEnable <= '1';
      MacEnable <= '1';
      MacInit   <= '0';
      ValidOut  <= '0';
      RamWEnable <= '0';

      if Counter = "111" then
        ValidOut <= '1';
      end if;

      if ValidIn = '1' then
        RamWEnable <= '1';
        MacInit    <= '1';
        Counter    <= "000";
      else 
        Counter <= Counter + 1;
      end if;

    end if;
  end process;

  RamAddress <= Counter;
  RomAddress <= not Counter;
end architecture;
