library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_FA4Transmission is
end tb_FA4Transmission;

architecture behavior of tb_FA4Transmission is

  component FA4Transmission
    Port(
      Clk, Cin : in std_logic;
      A, B     : in std_logic_vector(3 downto 0);
      Sum      : out std_logic_vector(3 downto 0);
      Cout     : out std_logic
    );
  end component;

  signal Clk  : std_logic := '0';
  signal Cin  : std_logic := '0';
  signal A    : std_logic_vector(3 downto 0) := (others => '0');
  signal B    : std_logic_vector(3 downto 0) := (others => '0');
  signal Sum  : std_logic_vector(3 downto 0);
  signal Cout : std_logic;

  constant clk_period : time := 10 ns;

begin

  uut: FA4Transmission port map (
    Clk  => Clk,
    Cin  => Cin,
    A    => A,
    B    => B,
    Sum  => Sum,
    Cout => Cout
  );

  process begin
    Clk <= '0';
    wait for clk_period/2;
    Clk <= '1';
    wait for clk_period/2;
  end process;

  process begin
    wait for clk_period;

    -- Sum = 0101 Cout = 0
    A <= "0011"; B <= "0010"; Cin <= '0';
    wait for clk_period;

    -- Sum = 1110 Cout = 0
    A <= "0111"; B <= "0111"; Cin <= '0';
    wait for clk_period;

    -- Sum = 0000 Cout = 1
    A <= "1111"; B <= "0001"; Cin <= '0';
    wait for clk_period;

    -- Sum = 1111 Cout = 1
    A <= "1111"; B <= "1111"; Cin <= '1';
    wait for clk_period;

    -- flush pipeline
    A <= "0000"; B <= "0000"; Cin <= '0';
    
    wait for clk_period * 5;

    wait;
  end process;
end architecture;
