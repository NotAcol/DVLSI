------------------------------------------------------------------------
-- Q1: Testbench for Synchronous Full Adder
-- Exhaustively tests all 8 input combinations (a, b, cin).
-- Checks outputs one cycle later (since outputs are registered).
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_sync_fa is
end tb_sync_fa;

architecture sim of tb_sync_fa is

    -- Component declaration
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

    -- Signals
    signal clk  : STD_LOGIC := '0';
    signal rst  : STD_LOGIC := '0';
    signal a    : STD_LOGIC := '0';
    signal b    : STD_LOGIC := '0';
    signal cin  : STD_LOGIC := '0';
    signal s    : STD_LOGIC;
    signal cout : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns;

    -- Helper: expected sum and carry for given inputs
    -- sum  = a XOR b XOR cin
    -- cout = majority(a, b, cin)
    signal exp_s    : STD_LOGIC := '0';
    signal exp_cout : STD_LOGIC := '0';

begin

    -- Clock generation
    clk <= not clk after CLK_PERIOD / 2;

    -- DUT instantiation
    DUT: sync_fa port map (
        clk  => clk,
        rst  => rst,
        a    => a,
        b    => b,
        cin  => cin,
        s    => s,
        cout => cout
    );

    -- Stimulus process
    stim_proc: process
        variable vec : unsigned(2 downto 0);  -- {a, b, cin}
        variable sum_val : integer;
    begin
        -- 1. Assert reset for 2 cycles
        rst <= '1';
        wait for CLK_PERIOD * 2;
        wait until rising_edge(clk);
        rst <= '0';

        -- 2. Wait one cycle for reset to take effect on outputs
        wait until rising_edge(clk);
        assert (s = '0' and cout = '0')
            report "Reset failed: outputs not zero"
            severity error;

        -- 3. Exhaustive test: apply all 8 input combinations
        for i in 0 to 7 loop
            vec := to_unsigned(i, 3);
            a   <= vec(2);
            b   <= vec(1);
            cin <= vec(0);

            -- Wait one clock cycle for inputs to be registered
            wait until rising_edge(clk);

            -- After one more rising edge the output reflects the
            -- inputs we applied. But since we set inputs before the
            -- edge, the DUT samples them on THIS edge, and outputs
            -- appear after THIS edge. So we check on the NEXT edge.
            wait until rising_edge(clk);

            -- Compute expected values
            sum_val := to_integer(unsigned'("" & vec(2)))
                     + to_integer(unsigned'("" & vec(1)))
                     + to_integer(unsigned'("" & vec(0)));

            exp_s    <= std_logic(to_unsigned(sum_val, 2)(0));
            exp_cout <= std_logic(to_unsigned(sum_val, 2)(1));

            -- Small delta delay for exp signals to update
            wait for 1 ns;

            assert (s = exp_s and cout = exp_cout)
                report "FAIL at a=" & std_logic'image(vec(2)) &
                       " b=" & std_logic'image(vec(1)) &
                       " cin=" & std_logic'image(vec(0)) &
                       " | got s=" & std_logic'image(s) &
                       " cout=" & std_logic'image(cout) &
                       " | exp s=" & std_logic'image(exp_s) &
                       " cout=" & std_logic'image(exp_cout)
                severity error;

            report "PASS: a=" & std_logic'image(vec(2)) &
                   " b=" & std_logic'image(vec(1)) &
                   " cin=" & std_logic'image(vec(0)) &
                   " -> s=" & std_logic'image(s) &
                   " cout=" & std_logic'image(cout)
                severity note;
        end loop;

        report "=== All tests completed ===" severity note;
        wait;  -- Stop simulation
    end process;

end sim;
