library ieee;
use ieee.std_logic_1164.all;

entity TbFirFilter is
end entity;

architecture Simulation of TbFirFilter is
  signal Clk      : std_logic := '0';
  signal Reset    : std_logic := '0';
  signal ValidIn  : std_logic := '0';
  signal X        : std_logic_vector(7 downto 0) := (others => '0');
  signal ValidOut : std_logic;
  signal Y        : std_logic_vector(18 downto 0);

  constant CLK_PERIOD : time := 10 ns;
begin
  UUT: entity work.FirFilter
    port map(
      Clk      => Clk,
      Reset    => Reset,
      ValidIn  => ValidIn,
      X        => X,
      ValidOut => ValidOut,
      Y        => Y
    );

  Clk <= not Clk after CLK_PERIOD / 2;

  process begin
    Reset <= '1';
    wait for CLK_PERIOD * 2;
    Reset <= '0';
    wait for CLK_PERIOD * 2;

    for i in 0 to 9 loop
      ValidIn <= '1';
      if i = 0 then
        X <= "00000001"; 
      else
        X <= "00000000"; 
      end if;
      
      wait for CLK_PERIOD;
      
      ValidIn <= '0';
      X       <= "00000000";
      
      wait for CLK_PERIOD * 7; 
    end loop;

    -- flush
    wait for CLK_PERIOD * 20;
    
    assert false report "Simulation Finished" severity failure;
  end process;
end architecture;
