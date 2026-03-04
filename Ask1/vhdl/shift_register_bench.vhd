library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Tb is
end entity;

architecture zzz of Tb is

  component ShiftRegister
   Port(
     Clk, Reset, Load, Enable, SerIn, SlideDir: in std_logic;
     I: in std_logic_vector(3 downto 0);
     O: out std_logic 
    );
  end component;

  signal Clk:       std_logic := '0';
  signal Load:      std_logic;
  signal Reset:     std_logic;
  signal Enable:    std_logic;
  signal SlideDir:  std_logic;
  signal SerIn:     std_logic;
  signal I:         std_logic_vector(3 downto 0);
  signal O:         std_logic;

  constant CLOCK_PERIOD : time := 10 ns;

  begin
    Dut: main port map (
      Clk       => Clk,
      Load      => Load,
      Reset     => Reset,
      Enable    => Enable,
      SlideDir  => SlideDir,
      SerIn     => SerIn,
      I         => I,
      O         => O
    );

    Clk <= not Clk after CLOCK_PERIOD / 2;

    Test: process begin
      Load <= '1';
      Reset <= '0';
      Enable <= '1';
      SlideDir <= '0';
      SerIn <= '0';
      I <= "1010";

    wait until falling_edge(Clk);
    Load <= '0';

    wait until falling_edge(Clk);
    wait until falling_edge(Clk);
    SerIn <= '1';
    SlideDir <='1';

    wait until falling_edge(Clk);
    wait until falling_edge(Clk);
    Reset<='1';

    wait;
  end process;

end architecture;
