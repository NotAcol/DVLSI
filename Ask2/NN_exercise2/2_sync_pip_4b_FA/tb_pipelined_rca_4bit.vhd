------------------------------------------------------------------------
-- Q2: Testbench for 4-bit Pipelined Ripple Carry Adder
--
-- Strategy:
--   Feed inputs every cycle. After LATENCY cycles, start checking
--   results while continuing to feed. After all inputs are fed,
--   feed zeros to flush the pipeline and keep checking.
--
-- Timeline:
--   Cycle 0:         feed test 0
--   Cycle 1:         feed test 1
--   ...
--   Cycle LATENCY:   feed test LATENCY,   CHECK result of test 0
--   Cycle LATENCY+1: feed test LATENCY+1, CHECK result of test 1
--   ...
--   Cycle N-1:       feed test N-1,        CHECK result of test N-1-LATENCY
--   Cycle N:         feed zeros (flush),   CHECK result of test N-LATENCY
--   ...
--   Cycle N+LAT-1:   feed zeros (flush),   CHECK result of test N-1
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_pipelined_rca_4bit is
end tb_pipelined_rca_4bit;

architecture sim of tb_pipelined_rca_4bit is

    component pipelined_rca_4bit
        Port (
            clk  : in  STD_LOGIC;
            rst  : in  STD_LOGIC;
            a    : in  STD_LOGIC_VECTOR(3 downto 0);
            b    : in  STD_LOGIC_VECTOR(3 downto 0);
            cin  : in  STD_LOGIC;
            s    : out STD_LOGIC_VECTOR(3 downto 0);
            cout : out STD_LOGIC
        );
    end component;

    signal clk  : STD_LOGIC := '0';
    signal rst  : STD_LOGIC := '0';
    signal a    : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal b    : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal cin  : STD_LOGIC := '0';
    signal s    : STD_LOGIC_VECTOR(3 downto 0);
    signal cout : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;
    constant LATENCY    : integer := 4;

    -- Test vectors
    constant NUM_TESTS : integer := 10;

    type test_array_4bit is array (0 to NUM_TESTS-1) of STD_LOGIC_VECTOR(3 downto 0);
    type test_array_1bit is array (0 to NUM_TESTS-1) of STD_LOGIC;

    constant test_a : test_array_4bit := (
        "0000",  -- 0 +  0 + 0 =  0
        "0001",  -- 1 +  1 + 0 =  2
        "0101",  -- 5 +  3 + 0 =  8
        "1111",  -- 15 + 1 + 0 = 16
        "1010",  -- 10 + 5 + 1 = 16
        "0110",  -- 6 +  6 + 0 = 12
        "1111",  -- 15 +15 + 0 = 30
        "1000",  -- 8 +  7 + 1 = 16
        "0011",  -- 3 +  4 + 0 =  7
        "1100"   -- 12 + 3 + 1 = 16
    );
    constant test_b : test_array_4bit := (
        "0000", "0001", "0011", "0001",
        "0101", "0110", "1111", "0111",
        "0100", "0011"
    );
    constant test_cin : test_array_1bit := (
        '0', '0', '0', '0', '1', '0', '0', '1', '0', '1'
    );

begin

    clk <= not clk after CLK_PERIOD / 2;

    DUT: pipelined_rca_4bit port map (
        clk => clk, rst => rst,
        a => a, b => b, cin => cin,
        s => s, cout => cout
    );

    stim_proc: process
        variable total_cycles : integer;
        variable check_idx    : integer;
        variable expected_sum : unsigned(4 downto 0);
        variable expected_s   : STD_LOGIC_VECTOR(3 downto 0);
        variable expected_c   : STD_LOGIC;
    begin
        --------------------------------------------------------
        -- Phase 1: Reset for 3 cycles
        --------------------------------------------------------
        rst <= '1';
        wait for CLK_PERIOD * 3;
        wait until rising_edge(clk);
        rst <= '0';

        --------------------------------------------------------
        -- Phase 2: Unified feed + check loop
        -- Total cycles = NUM_TESTS + LATENCY
        -- Cycle 0..NUM_TESTS-1: feed inputs
        -- Cycle LATENCY..NUM_TESTS+LATENCY-1: check results
        --------------------------------------------------------
        total_cycles := NUM_TESTS + LATENCY;

        for cycle in 0 to total_cycles - 1 loop

            -- FEED: apply inputs (or zeros for flush cycles)
            if cycle < NUM_TESTS then
                a   <= test_a(cycle);
                b   <= test_b(cycle);
                cin <= test_cin(cycle);
            else
                a   <= (others => '0');
                b   <= (others => '0');
                cin <= '0';
            end if;

            -- Wait for clock edge: DUT samples inputs & produces outputs
            wait until rising_edge(clk);
            wait for 1 ns;  -- let signals settle

            -- CHECK: results appear LATENCY-1 cycles after input was fed
            -- (because the feed wait already consumes 1 edge)
            if cycle >= LATENCY - 1 and cycle < NUM_TESTS + LATENCY - 1 then
                check_idx := cycle - (LATENCY - 1);

                expected_sum := ("0" & unsigned(test_a(check_idx)))
                              + ("0" & unsigned(test_b(check_idx)))
                              + ("0000" & test_cin(check_idx));
                expected_s := STD_LOGIC_VECTOR(expected_sum(3 downto 0));
                expected_c := std_logic(expected_sum(4));

                assert (s = expected_s and cout = expected_c)
                    report "FAIL test " & integer'image(check_idx) &
                           ": " & integer'image(to_integer(unsigned(test_a(check_idx)))) &
                           " + " & integer'image(to_integer(unsigned(test_b(check_idx)))) &
                           " + " & std_logic'image(test_cin(check_idx)) &
                           " | expected: " & integer'image(to_integer(unsigned(expected_s))) &
                           " cout=" & std_logic'image(expected_c) &
                           " | got: " & integer'image(to_integer(unsigned(s))) &
                           " cout=" & std_logic'image(cout)
                    severity error;

                report "PASS test " & integer'image(check_idx) &
                       ": " & integer'image(to_integer(unsigned(test_a(check_idx)))) &
                       " + " & integer'image(to_integer(unsigned(test_b(check_idx)))) &
                       " + " & std_logic'image(test_cin(check_idx)) &
                       " = cout:" & std_logic'image(cout) &
                       " sum:" & integer'image(to_integer(unsigned(s)))
                    severity note;
            end if;

        end loop;

        report "=== All " & integer'image(NUM_TESTS) & " tests completed ===" severity note;
        wait;
    end process;

end sim;
