------------------------------------------------------------------------
-- Q3: Testbench for 4x4 Systolic Carry-Propagate Multiplier
--
-- Latency: 10 clock cycles
-- Throughput: 1 result per clock cycle after pipeline fills
-- Strategy: feed new inputs every cycle, check results after latency
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_systolic_mul_4x4 is
end tb_systolic_mul_4x4;

architecture sim of tb_systolic_mul_4x4 is

    component systolic_mul_4x4
        Port (
            clk  : in  STD_LOGIC;
            rst  : in  STD_LOGIC;
            a    : in  STD_LOGIC_VECTOR(3 downto 0);
            b    : in  STD_LOGIC_VECTOR(3 downto 0);
            p    : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    signal clk  : STD_LOGIC := '0';
    signal rst  : STD_LOGIC := '0';
    signal a    : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal b    : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal p    : STD_LOGIC_VECTOR(7 downto 0);

    constant CLK_PERIOD : time := 10 ns;
    constant LATENCY    : integer := 10;

    -- Test vectors
    constant NUM_TESTS : integer := 12;

    type test_array_4bit is array (0 to NUM_TESTS-1) of STD_LOGIC_VECTOR(3 downto 0);

    -- Carefully chosen test cases
    constant test_a : test_array_4bit := (
        "0000",  --  0 *  0 =   0
        "0001",  --  1 *  1 =   1
        "0010",  --  2 *  3 =   6
        "0011",  --  3 *  3 =   9
        "0100",  --  4 *  5 =  20
        "0111",  --  7 *  7 =  49
        "1000",  --  8 *  2 =  16
        "1010",  -- 10 *  5 =  50
        "1111",  -- 15 *  1 =  15
        "1111",  -- 15 * 15 = 225
        "0110",  --  6 *  9 =  54
        "1001"   --  9 *  6 =  54
    );
    constant test_b : test_array_4bit := (
        "0000",  --  0
        "0001",  --  1
        "0011",  --  3
        "0011",  --  3
        "0101",  --  5
        "0111",  --  7
        "0010",  --  2
        "0101",  --  5
        "0001",  --  1
        "1111",  -- 15
        "1001",  --  9
        "0110"   --  6
    );

begin

    clk <= not clk after CLK_PERIOD / 2;

    DUT: systolic_mul_4x4 port map (
        clk => clk, rst => rst,
        a => a, b => b, p => p
    );

    stim_proc: process
        variable total_cycles : integer;
        variable check_idx    : integer;
        variable expected_p   : unsigned(7 downto 0);
    begin
        --------------------------------------------------------
        -- Phase 1: Reset
        --------------------------------------------------------
        rst <= '1';
        wait for CLK_PERIOD * 3;
        wait until rising_edge(clk);
        rst <= '0';

        --------------------------------------------------------
        -- Phase 2: Feed + Check loop
        --------------------------------------------------------
        total_cycles := NUM_TESTS + LATENCY;

        for cycle in 0 to total_cycles - 1 loop

            -- FEED inputs (or zeros for flush)
            if cycle < NUM_TESTS then
                a <= test_a(cycle);
                b <= test_b(cycle);
            else
                a <= (others => '0');
                b <= (others => '0');
            end if;

            -- Wait for clock edge
            wait until rising_edge(clk);
            wait for 1 ns;

            -- CHECK results after latency
            if cycle >= LATENCY - 1 and cycle < NUM_TESTS + LATENCY - 1 then
                check_idx := cycle - (LATENCY - 1);

                expected_p := unsigned(test_a(check_idx)) *
                              unsigned(test_b(check_idx));

                assert (p = STD_LOGIC_VECTOR(expected_p))
                    report "FAIL test " & integer'image(check_idx) &
                           ": " & integer'image(to_integer(unsigned(test_a(check_idx)))) &
                           " * " & integer'image(to_integer(unsigned(test_b(check_idx)))) &
                           " | expected: " & integer'image(to_integer(expected_p)) &
                           " | got: " & integer'image(to_integer(unsigned(p)))
                    severity error;

                report "PASS test " & integer'image(check_idx) &
                       ": " & integer'image(to_integer(unsigned(test_a(check_idx)))) &
                       " * " & integer'image(to_integer(unsigned(test_b(check_idx)))) &
                       " = " & integer'image(to_integer(unsigned(p)))
                    severity note;
            end if;

        end loop;

        report "=== All " & integer'image(NUM_TESTS) & " tests completed ===" severity note;
        wait;
    end process;

end sim;
