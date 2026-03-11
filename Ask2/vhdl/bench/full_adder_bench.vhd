library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_FA is
end tb_FA;

architecture Behavioral of tb_FA is

    component FA
    Port (
        A, B, Cin, Clk : in  std_logic;
        Sum   : out std_logic;
        Cout  : out std_logic
    );
    end component;

    signal Clk   : std_logic := '0';
    signal A     : std_logic := '0';
    signal B     : std_logic := '0';
    signal Cin   : std_logic := '0';
    signal Sum   : std_logic;
    signal Cout  : std_logic;

    constant clk_period : time := 20 ns;

begin
  uut: FA PORT MAP (Clk, A, B, Cin, Sum, Cout);

  -- Clock inf loop
  process begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  process begin
    A <= '0'; B <= '0'; Cin <= '0';
    wait for clk_period;
    A <= '0'; B <= '0'; Cin <= '1';
    wait for clk_period;
    A <= '0'; B <= '1'; Cin <= '0';
    wait for clk_period;
    A <= '0'; B <= '1'; Cin <= '1';
    wait for clk_period;
    A <= '1'; B <= '0'; Cin <= '0';
    wait for clk_period;
    A <= '1'; B <= '0'; Cin <= '1';
    wait for clk_period;
    A <= '1'; B <= '1'; Cin <= '0';
    wait for clk_period;
    A <= '1'; B <= '1'; Cin <= '1';
    wait for clk_period;
    wait;
  end process;
end architecture;
