------------------------------------------------------------------------
-- Q3: 4x4 Systolic Carry-Propagate Multiplier
--
-- Architecture: 4x4 array of sync_mul_cells with:
--   - Input staggering: a(j) delayed by j cycles, b(i) delayed by 2i cycles
--   - Inter-row alignment: ai delayed by 1 cycle between rows,
--     MSB of si (carry from last cell of previous row) delayed by 1 cycle
--   - Output alignment: product bits delayed to arrive simultaneously
--
-- Timing: cell(i,j) processes at clock edge (2i + j + 1)
-- Latency: 10 clock cycles for 4x4
-- Throughput: 1 multiplication per clock cycle (after pipeline fills)
--
-- Product bits: p(7:0) = a(3:0) * b(3:0)
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity systolic_mul_4x4 is
    Port (
        clk  : in  STD_LOGIC;
        rst  : in  STD_LOGIC;
        a    : in  STD_LOGIC_VECTOR(3 downto 0);
        b    : in  STD_LOGIC_VECTOR(3 downto 0);
        p    : out STD_LOGIC_VECTOR(7 downto 0)
    );
end systolic_mul_4x4;

architecture structural of systolic_mul_4x4 is

    component sync_mul_cell
        Port (
            clk, rst  : in  STD_LOGIC;
            ai, bi    : in  STD_LOGIC;
            si, ci    : in  STD_LOGIC;
            ao, bo    : out STD_LOGIC;
            so, co    : out STD_LOGIC
        );
    end component;

    ----------------------------------------------------------------
    -- Cell I/O signals: (row, column) indexing
    -- row = 0..3 (b-bit index), col = 0..3 (a-bit index)
    ----------------------------------------------------------------
    type cell_array is array (0 to 3, 0 to 3) of STD_LOGIC;
    signal c_ai, c_ao : cell_array;  -- multiplicand pass-through
    signal c_bi, c_bo : cell_array;  -- multiplier pass-through
    signal c_si, c_so : cell_array;  -- sum in/out
    signal c_ci, c_co : cell_array;  -- carry in/out

    ----------------------------------------------------------------
    -- INPUT DELAY CHAINS
    -- a(j) needs j delays before entering row 0
    -- b(i) needs 2*i delays before entering column 0 of row i
    ----------------------------------------------------------------
    -- a delays: a(1)->1, a(2)->2, a(3)->3
    signal a1_d1                          : STD_LOGIC;
    signal a2_d1, a2_d2                   : STD_LOGIC;
    signal a3_d1, a3_d2, a3_d3           : STD_LOGIC;

    -- b delays: b(1)->2, b(2)->4, b(3)->6
    signal b1_d1, b1_d2                                     : STD_LOGIC;
    signal b2_d1, b2_d2, b2_d3, b2_d4                       : STD_LOGIC;
    signal b3_d1, b3_d2, b3_d3, b3_d4, b3_d5, b3_d6         : STD_LOGIC;

    ----------------------------------------------------------------
    -- INTER-ROW DELAY CHAINS
    -- ai between rows: 1 extra delay per row transition
    -- co MSB between rows: 1 extra delay for si MSB
    ----------------------------------------------------------------
    -- Row 0 → Row 1: ai delay (4 columns)
    signal ai_r1_d : STD_LOGIC_VECTOR(3 downto 0);
    -- Row 1 → Row 2: ai delay
    signal ai_r2_d : STD_LOGIC_VECTOR(3 downto 0);
    -- Row 2 → Row 3: ai delay
    signal ai_r3_d : STD_LOGIC_VECTOR(3 downto 0);

    -- co MSB delay between rows (1 delay each)
    signal co_msb_r0_d1 : STD_LOGIC;  -- co(0,3) → delayed → si(1,3)
    signal co_msb_r1_d1 : STD_LOGIC;  -- co(1,3) → delayed → si(2,3)
    signal co_msb_r2_d1 : STD_LOGIC;  -- co(2,3) → delayed → si(3,3)

    ----------------------------------------------------------------
    -- OUTPUT ALIGNMENT DELAYS
    -- All product bits must be aligned to the same clock cycle.
    -- Latest output: co(3,3) and so(3,3) at edge 10.
    -- p(0)=so(0,0) @ edge 1 → 9 delays
    -- p(1)=so(1,0) @ edge 3 → 7 delays
    -- p(2)=so(2,0) @ edge 5 → 5 delays
    -- p(3)=so(3,0) @ edge 7 → 3 delays
    -- p(4)=so(3,1) @ edge 8 → 2 delays
    -- p(5)=so(3,2) @ edge 9 → 1 delay
    -- p(6)=so(3,3) @ edge 10 → 0 delays
    -- p(7)=co(3,3) @ edge 10 → 0 delays
    ----------------------------------------------------------------
    signal p0_d : STD_LOGIC_VECTOR(8 downto 0);  -- 9 stages
    signal p1_d : STD_LOGIC_VECTOR(6 downto 0);  -- 7 stages
    signal p2_d : STD_LOGIC_VECTOR(4 downto 0);  -- 5 stages
    signal p3_d : STD_LOGIC_VECTOR(2 downto 0);  -- 3 stages
    signal p4_d : STD_LOGIC_VECTOR(1 downto 0);  -- 2 stages
    signal p5_d : STD_LOGIC_VECTOR(0 downto 0);  -- 1 stage

begin

    ----------------------------------------------------------------
    -- CELL INSTANTIATION (4 rows × 4 columns)
    ----------------------------------------------------------------
    gen_row: for i in 0 to 3 generate
        gen_col: for j in 0 to 3 generate
            cell: sync_mul_cell port map (
                clk => clk, rst => rst,
                ai  => c_ai(i,j), bi  => c_bi(i,j),
                si  => c_si(i,j), ci  => c_ci(i,j),
                ao  => c_ao(i,j), bo  => c_bo(i,j),
                so  => c_so(i,j), co  => c_co(i,j)
            );
        end generate;
    end generate;

    ----------------------------------------------------------------
    -- INTRA-ROW WIRING (within each row)
    -- Carry: ci(i,j) = co(i,j-1) for j>0; ci(i,0) = '0'
    -- Bi pass: bi(i,j) = bo(i,j-1) for j>0
    ----------------------------------------------------------------
    gen_intra_row: for i in 0 to 3 generate
        c_ci(i, 0) <= '0';  -- no carry-in at leftmost column
        gen_intra_col: for j in 1 to 3 generate
            c_ci(i, j) <= c_co(i, j-1);
            c_bi(i, j) <= c_bo(i, j-1);
        end generate;
    end generate;

    ----------------------------------------------------------------
    -- ROW 0 INPUT CONNECTIONS
    -- ai(0,j) = a(j) delayed by j cycles
    -- bi(0,0) = b(0) (no delay)
    -- si(0,j) = '0' (no sum from above)
    ----------------------------------------------------------------
    c_ai(0, 0) <= a(0);         -- no delay
    c_ai(0, 1) <= a1_d1;        -- 1 delay
    c_ai(0, 2) <= a2_d2;        -- 2 delays
    c_ai(0, 3) <= a3_d3;        -- 3 delays

    c_bi(0, 0) <= b(0);         -- no delay

    gen_si_row0: for j in 0 to 3 generate
        c_si(0, j) <= '0';      -- no sum input at top row
    end generate;

    ----------------------------------------------------------------
    -- ROW 1 INPUT CONNECTIONS
    -- ai(1,j) = ao(0,j) → 1 delay
    -- bi(1,0) = b(1) → 2 delays
    -- si(1,j) for j<3 = so(0,j+1) (naturally aligned)
    -- si(1,3) = co(0,3) → 1 delay
    ----------------------------------------------------------------
    gen_ai_row1: for j in 0 to 3 generate
        c_ai(1, j) <= ai_r1_d(j);
    end generate;
    c_bi(1, 0) <= b1_d2;

    c_si(1, 0) <= c_so(0, 1);
    c_si(1, 1) <= c_so(0, 2);
    c_si(1, 2) <= c_so(0, 3);
    c_si(1, 3) <= co_msb_r0_d1;

    ----------------------------------------------------------------
    -- ROW 2 INPUT CONNECTIONS
    ----------------------------------------------------------------
    gen_ai_row2: for j in 0 to 3 generate
        c_ai(2, j) <= ai_r2_d(j);
    end generate;
    c_bi(2, 0) <= b2_d4;

    c_si(2, 0) <= c_so(1, 1);
    c_si(2, 1) <= c_so(1, 2);
    c_si(2, 2) <= c_so(1, 3);
    c_si(2, 3) <= co_msb_r1_d1;

    ----------------------------------------------------------------
    -- ROW 3 INPUT CONNECTIONS
    ----------------------------------------------------------------
    gen_ai_row3: for j in 0 to 3 generate
        c_ai(3, j) <= ai_r3_d(j);
    end generate;
    c_bi(3, 0) <= b3_d6;

    c_si(3, 0) <= c_so(2, 1);
    c_si(3, 1) <= c_so(2, 2);
    c_si(3, 2) <= c_so(2, 3);
    c_si(3, 3) <= co_msb_r2_d1;

    ----------------------------------------------------------------
    -- DELAY CHAINS (all in one clocked process)
    ----------------------------------------------------------------
    delay_proc: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Input a delays
                a1_d1 <= '0';
                a2_d1 <= '0'; a2_d2 <= '0';
                a3_d1 <= '0'; a3_d2 <= '0'; a3_d3 <= '0';

                -- Input b delays
                b1_d1 <= '0'; b1_d2 <= '0';
                b2_d1 <= '0'; b2_d2 <= '0'; b2_d3 <= '0'; b2_d4 <= '0';
                b3_d1 <= '0'; b3_d2 <= '0'; b3_d3 <= '0';
                b3_d4 <= '0'; b3_d5 <= '0'; b3_d6 <= '0';

                -- Inter-row ai delays
                ai_r1_d <= (others => '0');
                ai_r2_d <= (others => '0');
                ai_r3_d <= (others => '0');

                -- Inter-row co MSB delays
                co_msb_r0_d1 <= '0';
                co_msb_r1_d1 <= '0';
                co_msb_r2_d1 <= '0';

                -- Output alignment delays
                p0_d <= (others => '0');
                p1_d <= (others => '0');
                p2_d <= (others => '0');
                p3_d <= (others => '0');
                p4_d <= (others => '0');
                p5_d <= (others => '0');
            else
                ------------------------------------------------
                -- Input a delay chains
                ------------------------------------------------
                a1_d1 <= a(1);

                a2_d1 <= a(2);
                a2_d2 <= a2_d1;

                a3_d1 <= a(3);
                a3_d2 <= a3_d1;
                a3_d3 <= a3_d2;

                ------------------------------------------------
                -- Input b delay chains
                ------------------------------------------------
                b1_d1 <= b(1);
                b1_d2 <= b1_d1;

                b2_d1 <= b(2);
                b2_d2 <= b2_d1;
                b2_d3 <= b2_d2;
                b2_d4 <= b2_d3;

                b3_d1 <= b(3);
                b3_d2 <= b3_d1;
                b3_d3 <= b3_d2;
                b3_d4 <= b3_d3;
                b3_d5 <= b3_d4;
                b3_d6 <= b3_d5;

                ------------------------------------------------
                -- Inter-row ai delays (1 cycle each)
                ------------------------------------------------
                for j in 0 to 3 loop
                    ai_r1_d(j) <= c_ao(0, j);
                    ai_r2_d(j) <= c_ao(1, j);
                    ai_r3_d(j) <= c_ao(2, j);
                end loop;

                ------------------------------------------------
                -- Inter-row co MSB delays (1 cycle each)
                ------------------------------------------------
                co_msb_r0_d1 <= c_co(0, 3);
                co_msb_r1_d1 <= c_co(1, 3);
                co_msb_r2_d1 <= c_co(2, 3);

                ------------------------------------------------
                -- Output alignment shift registers
                ------------------------------------------------
                -- p(0) = so(0,0): 9 delays
                p0_d(0) <= c_so(0, 0);
                for k in 1 to 8 loop
                    p0_d(k) <= p0_d(k-1);
                end loop;

                -- p(1) = so(1,0): 7 delays
                p1_d(0) <= c_so(1, 0);
                for k in 1 to 6 loop
                    p1_d(k) <= p1_d(k-1);
                end loop;

                -- p(2) = so(2,0): 5 delays
                p2_d(0) <= c_so(2, 0);
                for k in 1 to 4 loop
                    p2_d(k) <= p2_d(k-1);
                end loop;

                -- p(3) = so(3,0): 3 delays
                p3_d(0) <= c_so(3, 0);
                for k in 1 to 2 loop
                    p3_d(k) <= p3_d(k-1);
                end loop;

                -- p(4) = so(3,1): 2 delays
                p4_d(0) <= c_so(3, 1);
                p4_d(1) <= p4_d(0);

                -- p(5) = so(3,2): 1 delay
                p5_d(0) <= c_so(3, 2);
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- OUTPUT CONNECTIONS
    -- All product bits aligned to same clock cycle
    ----------------------------------------------------------------
    p(0) <= p0_d(8);       -- so(0,0) after 9 delays
    p(1) <= p1_d(6);       -- so(1,0) after 7 delays
    p(2) <= p2_d(4);       -- so(2,0) after 5 delays
    p(3) <= p3_d(2);       -- so(3,0) after 3 delays
    p(4) <= p4_d(1);       -- so(3,1) after 2 delays
    p(5) <= p5_d(0);       -- so(3,2) after 1 delay
    p(6) <= c_so(3, 3);    -- so(3,3) no delay needed
    p(7) <= c_co(3, 3);    -- co(3,3) no delay needed

end structural;
