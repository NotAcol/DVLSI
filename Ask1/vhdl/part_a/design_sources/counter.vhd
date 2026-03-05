library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Counter is
  Port (
    Clk,
    ResetN,
    Up,
    CountEn : in std_logic;
    Modulo : in std_logic_vector(2 downto 0);
    Sum : out std_logic_vector(2 downto 0);
    Cout : out std_logic
  );
end Counter;

architecture zzz of Counter is
signal Count : unsigned(2 downto 0);
begin

  process(Clk, ResetN) begin
    if ResetN = '0' then
      Count <= (others =>'0');
    elsif  (rising_edge(Clk)) then
      if CountEn = '1' then

        if Up = '1' then
          -- Up Count
          if Count >= unsigned(Modulo) - 1 then 
            Count <= (others => '0');
          else
            Count <= Count + 1;
          end if;

        else
          -- Down Count
          if Count = 0 then
            Count <= unsigned(Modulo) - 1;
          else
            Count <= Count - 1;
          end if;
        end if;

      end if;
    end if;
  end process;

  Sum <= std_logic_vector(Count);
  Cout <= '1' when (Count = unsigned(Modulo)-1 and CountEn='1' and Up='1') else 
          '1' when (Count = 0 and CountEn = '1' and Up = '0') else
          '0';

end architecture;
