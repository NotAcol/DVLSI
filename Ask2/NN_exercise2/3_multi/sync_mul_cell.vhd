------------------------------------------------------------------------
-- Q3: Synchronous Multiplier Cell (Behavioral)
-- 
-- Each cell computes: ab = ai AND bi (partial product)
-- Then adds: (co, so) = ab + si + ci  (full adder logic)
-- Pass-through: ao = ai, bo = bi
--
-- ALL outputs (so, co, ao, bo) are registered on rising clock edge.
-- This makes each cell a single pipeline stage for systolic operation.
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sync_mul_cell is
    Port (
        clk  : in  STD_LOGIC;
        rst  : in  STD_LOGIC;
        ai   : in  STD_LOGIC;   -- multiplicand bit input
        bi   : in  STD_LOGIC;   -- multiplier bit input
        si   : in  STD_LOGIC;   -- sum input (from row above)
        ci   : in  STD_LOGIC;   -- carry input (from cell to the left)
        ao   : out STD_LOGIC;   -- multiplicand bit output (registered)
        bo   : out STD_LOGIC;   -- multiplier bit output (registered)
        so   : out STD_LOGIC;   -- sum output (registered)
        co   : out STD_LOGIC    -- carry output (registered)
    );
end sync_mul_cell;

architecture behavioral of sync_mul_cell is
    signal ab : STD_LOGIC;  -- partial product (combinational)
begin

    -- Partial product: AND gate (combinational)
    ab <= ai and bi;

    -- Full adder logic + pass-through, all registered
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                so <= '0';
                co <= '0';
                ao <= '0';
                bo <= '0';
            else
                -- FA sum and carry (registered)
                so <= ab xor si xor ci;
                co <= (ab and si) or (ab and ci) or (si and ci);
                -- Pass-through (registered)
                ao <= ai;
                bo <= bi;
            end if;
        end if;
    end process;

end behavioral;
