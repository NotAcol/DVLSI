------------------------------------------------------------------------
-- Q1: Synchronous Full Adder (Behavioral)
-- Inputs are sampled on rising clock edge, outputs are registered.
-- Reset is synchronous and active-high.
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sync_fa is
    Port (
        clk  : in  STD_LOGIC;
        rst  : in  STD_LOGIC;
        a    : in  STD_LOGIC;
        b    : in  STD_LOGIC;
        cin  : in  STD_LOGIC;
        s    : out STD_LOGIC;
        cout : out STD_LOGIC
    );
end sync_fa;

architecture behavioral of sync_fa is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                s    <= '0';
                cout <= '0';
            else
                s    <= a xor b xor cin;
                cout <= (a and b) or (a and cin) or (b and cin);
            end if;
        end if;
    end process;
end behavioral;
