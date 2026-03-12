------------------------------------------------------------------------
-- Q2: 4-bit Pipelined Ripple Carry Adder
-- Uses sync_fa (Q1) as building block.
-- Accepts new inputs every clock cycle.
-- Latency: 4 clock cycles.
-- Throughput: 1 result per clock cycle (after pipeline fills).
--
-- Architecture:
--   - 4 sync_fa stages chained by carry
--   - Input alignment registers: a(k),b(k) delayed by k cycles
--   - Sum alignment registers: s(k) delayed by (3-k) cycles
--   - cin also delayed alongside a(0),b(0) — no extra delay needed
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pipelined_rca_4bit is
    Port (
        clk  : in  STD_LOGIC;
        rst  : in  STD_LOGIC;
        a    : in  STD_LOGIC_VECTOR(3 downto 0);
        b    : in  STD_LOGIC_VECTOR(3 downto 0);
        cin  : in  STD_LOGIC;
        s    : out STD_LOGIC_VECTOR(3 downto 0);
        cout : out STD_LOGIC
    );
end pipelined_rca_4bit;

architecture structural of pipelined_rca_4bit is

    -- The synchronous FA from Q1
    component sync_fa
        Port (
            clk  : in  STD_LOGIC;
            rst  : in  STD_LOGIC;
            a    : in  STD_LOGIC;
            b    : in  STD_LOGIC;
            cin  : in  STD_LOGIC;
            s    : out STD_LOGIC;
            cout : out STD_LOGIC
        );
    end component;

    -- Carry signals between stages
    signal c : STD_LOGIC_VECTOR(3 downto 0);  -- c(i) = carry out of FA_i

    -- Input alignment registers
    -- a(1),b(1) need 1 delay; a(2),b(2) need 2; a(3),b(3) need 3
    signal a1_d1                         : STD_LOGIC;
    signal b1_d1                         : STD_LOGIC;
    signal a2_d1, a2_d2                  : STD_LOGIC;
    signal b2_d1, b2_d2                  : STD_LOGIC;
    signal a3_d1, a3_d2, a3_d3          : STD_LOGIC;
    signal b3_d1, b3_d2, b3_d3          : STD_LOGIC;

    -- Sum alignment registers
    -- s(0) needs 3 delays; s(1) needs 2; s(2) needs 1; s(3) needs 0
    signal s0_raw                        : STD_LOGIC;
    signal s0_d1, s0_d2, s0_d3          : STD_LOGIC;
    signal s1_raw                        : STD_LOGIC;
    signal s1_d1, s1_d2                  : STD_LOGIC;
    signal s2_raw                        : STD_LOGIC;
    signal s2_d1                         : STD_LOGIC;
    signal s3_raw                        : STD_LOGIC;

begin

    ----------------------------------------------------------------
    -- STAGE 0: FA0 processes a(0), b(0), cin
    -- No input delay needed
    ----------------------------------------------------------------
    FA0: sync_fa port map (
        clk  => clk,
        rst  => rst,
        a    => a(0),
        b    => b(0),
        cin  => cin,
        s    => s0_raw,
        cout => c(0)
    );

    ----------------------------------------------------------------
    -- STAGE 1: FA1 processes a(1), b(1), carry from FA0
    -- a(1) and b(1) need 1 cycle delay
    ----------------------------------------------------------------
    FA1: sync_fa port map (
        clk  => clk,
        rst  => rst,
        a    => a1_d1,
        b    => b1_d1,
        cin  => c(0),
        s    => s1_raw,
        cout => c(1)
    );

    ----------------------------------------------------------------
    -- STAGE 2: FA2 processes a(2), b(2), carry from FA1
    -- a(2) and b(2) need 2 cycles delay
    ----------------------------------------------------------------
    FA2: sync_fa port map (
        clk  => clk,
        rst  => rst,
        a    => a2_d2,
        b    => b2_d2,
        cin  => c(1),
        s    => s2_raw,
        cout => c(2)
    );

    ----------------------------------------------------------------
    -- STAGE 3: FA3 processes a(3), b(3), carry from FA2
    -- a(3) and b(3) need 3 cycles delay
    ----------------------------------------------------------------
    FA3: sync_fa port map (
        clk  => clk,
        rst  => rst,
        a    => a3_d3,
        b    => b3_d3,
        cin  => c(2),
        s    => s3_raw,
        cout => c(3)
    );

    ----------------------------------------------------------------
    -- INPUT ALIGNMENT REGISTERS
    -- Delay a(k) and b(k) by k clock cycles so they arrive
    -- at the same time as the carry from the previous stage.
    ----------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                a1_d1 <= '0';
                b1_d1 <= '0';
                a2_d1 <= '0'; a2_d2 <= '0';
                b2_d1 <= '0'; b2_d2 <= '0';
                a3_d1 <= '0'; a3_d2 <= '0'; a3_d3 <= '0';
                b3_d1 <= '0'; b3_d2 <= '0'; b3_d3 <= '0';
            else
                -- 1 stage delay for bit 1
                a1_d1 <= a(1);
                b1_d1 <= b(1);

                -- 2 stage delay for bit 2
                a2_d1 <= a(2);
                a2_d2 <= a2_d1;
                b2_d1 <= b(2);
                b2_d2 <= b2_d1;

                -- 3 stage delay for bit 3
                a3_d1 <= a(3);
                a3_d2 <= a3_d1;
                a3_d3 <= a3_d2;
                b3_d1 <= b(3);
                b3_d2 <= b3_d1;
                b3_d3 <= b3_d2;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- SUM ALIGNMENT REGISTERS
    -- Delay s(k) by (3-k) clock cycles so all sum bits and
    -- cout arrive at the output at the same time.
    ----------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                s0_d1 <= '0'; s0_d2 <= '0'; s0_d3 <= '0';
                s1_d1 <= '0'; s1_d2 <= '0';
                s2_d1 <= '0';
            else
                -- 3 stage delay for s(0)
                s0_d1 <= s0_raw;
                s0_d2 <= s0_d1;
                s0_d3 <= s0_d2;

                -- 2 stage delay for s(1)
                s1_d1 <= s1_raw;
                s1_d2 <= s1_d1;

                -- 1 stage delay for s(2)
                s2_d1 <= s2_raw;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- OUTPUT CONNECTIONS
    -- All sum bits and cout are now aligned at the same cycle
    ----------------------------------------------------------------
    s(0) <= s0_d3;
    s(1) <= s1_d2;
    s(2) <= s2_d1;
    s(3) <= s3_raw;
    cout <= c(3);

end structural;
