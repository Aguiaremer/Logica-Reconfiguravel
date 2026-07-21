library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_bram_tb is
end top_bram_tb;

architecture tb of top_bram_tb is

    component top_avalon
    port(
        clock       : in  std_logic;
        resetn      : in  std_logic;
        chipselect  : in  std_logic;
        writedata   : in  std_logic_vector(31 downto 0);
        write_en    : in  std_logic;
        readdata    : out std_logic_vector(31 downto 0);
        add         : in  std_logic_vector(1 downto 0);
        read_en     : in  std_logic
    );
    end component;

    signal clock      : std_logic := '0';
    signal resetn     : std_logic := '0';
    signal chipselect : std_logic := '0';
    signal writedata  : std_logic_vector(31 downto 0) := (others => '0');
    signal write_en   : std_logic := '0';
    signal readdata   : std_logic_vector(31 downto 0);
    signal add        : std_logic_vector(1 downto 0) := (others => '0');
    signal read_en    : std_logic := '0';

begin

    -- DUT
    uut: top_avalon
    port map(
        clock => clock,
        resetn => resetn,
        chipselect => chipselect,
        writedata => writedata,
        write_en => write_en,
        readdata => readdata,
        add => add,
        read_en => read_en
    );

    -- clock
    clk_proc: process
    begin
        while now < 2000 ns loop
            clock <= '0';
            wait for 5 ns;
            clock <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process;

    stim_proc: process
    begin
        -- reset
        resetn <= '0';
        chipselect <= '0';
        write_en <= '0';
        read_en <= '0';
        wait for 20 ns;
        resetn <= '1';
        wait for 20 ns;

        -- write address 0
        chipselect <= '1';
        write_en <= '1';
        add <= "00";
        writedata <= x"00000000"; -- address 0
        wait until rising_edge(clock);

        -- write data 0x41 ('A')
        add <= "01";
        writedata <= x"00000041";
        wait until rising_edge(clock);

        -- issue WE (bit1 = 1)
        add <= "10";
        writedata <= x"00000002"; -- WE=1
        wait until rising_edge(clock);

        -- small pause
        chipselect <= '0';
        write_en <= '0';
        wait until rising_edge(clock);

        -- start read: set address then issue RD
        chipselect <= '1';
        write_en <= '1';
        add <= "00";
        writedata <= x"00000000"; -- address 0
        wait until rising_edge(clock);

        add <= "10";
        writedata <= x"00000001"; -- RD=1
        wait until rising_edge(clock);

        -- give BRAM one cycle, then sample via read_en
        write_en <= '0';
        add <= "01";
        read_en <= '1';
        wait until rising_edge(clock);

        -- check lower byte
        if readdata(7 downto 0) = std_logic_vector(to_unsigned(16#41#,8)) then
            report "READBACK OK: " & integer'image(to_integer(unsigned(readdata(7 downto 0))));
        else
            report "READBACK MISMATCH: got " & integer'image(to_integer(unsigned(readdata(7 downto 0)))) severity error;
        end if;

        wait for 40 ns;
        report "TEST FINISHED";
        wait;
    end process;

end tb;
