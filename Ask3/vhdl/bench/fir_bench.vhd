library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
    
    
    ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(208 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;
   
    wait for CLK_PERIOD * 5;
   
    ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(231 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;
    
    ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(32 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;
    
    ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(233 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;

    ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(161 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;

    ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(24 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;
    
        ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(71 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;

    ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(140 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;

    ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(245 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;

    ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(247 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;

    ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(40 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;
    
    ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(248 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;
    
    ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(245 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;
    
    ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(124 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;    
        
    ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(204 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;
        
    ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(36 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;
    
    ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(107 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;
    
        
    ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(234 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;
    
        
    ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(202 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;
    
        
    ValidIn <= '1';
    X<= std_logic_vector(to_unsigned(245 ,8));
    wait for CLK_PERIOD;
    X <= "00000000";
    ValidIn <= '0';
    wait for CLK_PERIOD * 7;
    
    -- flush
    for i in 0 to 9 loop
        ValidIn <= '1';
        X<= "00000000";
        wait for CLK_PERIOD;
        ValidIn <= '0';
        wait for CLK_PERIOD * 7; 
    end loop;
    
    
    
    
--------------------------------------------------------------------------- 
    
    
    
    Reset<= '0';
    -- Dirac
    for i in 0 to 9 loop
        ValidIn <= '1';
        if i = 0 then
            X <= "00000001"; 
        end if;
        wait for CLK_PERIOD;
        X <= "00000000";
        ValidIn <= '0';
        wait for CLK_PERIOD * 7; 
    end loop;
    -- flush
    
    Reset <= '1';
    wait for CLK_PERIOD * 2;
    Reset <= '0';
    -- Step
    for i in 0 to 9 loop
        ValidIn <= '1';
        X <= "00000001"; 
        wait for CLK_PERIOD;
        ValidIn <= '0';
        X       <= "00000000";
        wait for CLK_PERIOD * 7; 
    end loop;
    -- flush
    
    wait for CLK_PERIOD * 20;
    
    
  end process;
end architecture;
