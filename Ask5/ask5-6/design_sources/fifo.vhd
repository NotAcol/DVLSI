library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package buffer_pkg is
  type ring_buffer_type is array (natural range <>) of std_logic_vector(7 downto 0);
end package buffer_pkg;
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.buffer_pkg.all;

entity RingBuffer is
  generic(
      Depth : integer := 1024
  );
  port(
      Clk, RstN, Enable : in  std_logic;
      DataIn            : in  std_logic_vector(7 downto 0);
      DataOut           : out std_logic_vector(7 downto 0)
  );
end entity RingBuffer;

architecture Behavioral of RingBuffer is
  signal RamBuffer   : ring_buffer_type(0 to Depth - 2);
  signal Pointer     : natural range 0 to Depth - 2;
  -- NOTE(acol): magic to force BRam
  attribute ram_style : string;
  attribute ram_style of RamBuffer : signal is "block";
begin
  process(Clk, RstN) begin
    if RstN = '0' then
      Pointer <= 0;
      DataOut <= (others => '0');

    elsif rising_edge(Clk) then
      if Enable = '1' then
        DataOut            <= RamBuffer(Pointer);
        RamBuffer(Pointer) <= DataIn;

        if Pointer = Depth - 2 then
          Pointer <= 0;
        else
          Pointer <= Pointer + 1;
        end if;
      end if;
    end if;
  end process;
end architecture;
