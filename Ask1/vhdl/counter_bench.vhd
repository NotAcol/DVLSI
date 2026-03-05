library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Counter_Tb is
end Counter_Tb;

architecture Simulation of Counter_Tb is
  component Counter
    Port (
      Clk     : in std_logic;
      ResetN  : in std_logic;
      Up      : in std_logic;
      CountEn : in std_logic;
      Modulo  : in std_logic_vector(2 downto 0);
      Sum     : out std_logic_vector(2 downto 0);
      Cout    : out std_logic
    );
  end component;

  signal Clk     : std_logic := '0';
  signal ResetN  : std_logic := '0';
  signal Up      : std_logic := '1';
  signal CountEn : std_logic := '0';
  signal Modulo  : std_logic_vector(2 downto 0) := "101";
  signal Sum     : std_logic_vector(2 downto 0);
  signal Cout    : std_logic;

  constant CLK_PERIOD : time := 10 ns;

begin
  DUT: Counter port map (
    Clk     => Clk,
    ResetN  => ResetN,
    Up      => Up,
    CountEn => CountEn,
    Modulo  => Modulo,
    Sum     => Sum,
    Cout    => Cout
  );

  Clk <= not Clk after CLK_PERIOD / 2;

  process begin
    ResetN <= '0';
    wait for CLK_PERIOD * 2;
    ResetN <= '1';
    
    -- NOTE(acol): Up count with wrap
    CountEn <= '1';
    Up <= '1';
    Modulo <= "101"; 
    wait for CLK_PERIOD * 7; 

    -- NOTE(acol): Down count with wrap
    Up <= '0';
    wait for CLK_PERIOD * 6;

    -- NOTE(acol): Modulo dynamic change
    Modulo <= "011"; 
    Up <= '1';
    wait for CLK_PERIOD * 5;

    -- NOTE(acol): Disable
    CountEn <= '0';
    wait for CLK_PERIOD * 3;

    wait;
  end process;

end Simulation;
