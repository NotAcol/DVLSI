library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TbSystolicMultiplier4Bit is
end TbSystolicMultiplier4Bit;

architecture Behavior of TbSystolicMultiplier4Bit is
  component SystolicMultiplier4Bit
    Port(
        Clk     : in  std_logic;
        A       : in  std_logic_vector(3 downto 0);
        B       : in  std_logic_vector(3 downto 0);
        Product : out std_logic_vector(7 downto 0)
    );
  end component;

  signal Clk     : std_logic := '0';
  signal A       : std_logic_vector(3 downto 0) := (others => '0');
  signal B       : std_logic_vector(3 downto 0) := (others => '0');
  signal Product : std_logic_vector(7 downto 0);

  constant ClkPeriod : time := 10 ns;
begin
  UUT: SystolicMultiplier4Bit port map (
         Clk     => Clk,
         A       => A,
         B       => B,
         Product => Product
       );

  process begin
    Clk <= '0';
    wait for ClkPeriod / 2;
    Clk <= '1';
    wait for ClkPeriod / 2;
  end process;

  process begin
    wait for ClkPeriod * 2;
    -- 2 x 3 = 6
    A <= "0010"; B <= "0011"; 
    wait for ClkPeriod;
    -- 4 x 4 = 16
    A <= "0100"; B <= "0100"; 
    wait for ClkPeriod;
    -- 15 x 1 = 15
    A <= "1111"; B <= "0001"; 
    wait for ClkPeriod;
    -- 10 x 2 = 20
    A <= "1010"; B <= "0010"; 
    wait for ClkPeriod;
    -- 15 x 15 = 225
    A <= "1111"; B <= "1111"; 
    wait for ClkPeriod;
    -- 1 x 1 = 1
    A <= "0001"; B <= "0001"; 
    wait for ClkPeriod;
    -- flush
    A <= "0000"; B <= "0000";
    wait for ClkPeriod * 10;

    wait;
  end process;
end Behavior;
