library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BRAM_tb is
end BRAM_tb;

architecture behavior of BRAM_tb is

    signal clock     : std_logic := '0';
    signal data      : std_logic_vector(7 downto 0) := (others => '0');
    signal rdaddress : std_logic_vector(10 downto 0) := (others => '0');
    signal rden      : std_logic := '0';
    signal wraddress : std_logic_vector(10 downto 0) := (others => '0');
    signal wren      : std_logic := '0';
    signal q         : std_logic_vector(7 downto 0);

    constant clk_period : time := 20 ns;

begin
    uut: entity work.BRAM
        port map (
            clock     => clock,
            data      => data,
            rdaddress => rdaddress,
            rden      => rden,
            wraddress => wraddress,
            wren      => wren,
            q         => q
        );

    clk_process : process
    begin
        clock <= '0';
        wait for clk_period/2;
        clock <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin		
        wren <= '0';
        rden <= '0';
        wait for clk_period * 2;

        -- 1. ESCRITA: Escrevendo o valor 0xAA no endereço 10 e 0x55 no endereço 20
        wait until falling_edge(clock);
        wren <= '1';
        wraddress <= std_logic_vector(to_unsigned(10, 11));
        data <= x"AA";
        
        wait for clk_period;
        wraddress <= std_logic_vector(to_unsigned(20, 11));
        data <= x"55";
        
        wait for clk_period;
        wren <= '0'; -- Desabilita escrita

        wait for clk_period * 2;

        -- 2. LEITURA: Lendo o endereço 10
        -- Como a saída é registrada, o dado AA aparecerá 2 ciclos depois
        wait until falling_edge(clock);
        rden <= '1';
        rdaddress <= std_logic_vector(to_unsigned(10, 11));
        
        wait for clk_period;
        rdaddress <= std_logic_vector(to_unsigned(20, 11));
        
        wait for clk_period * 5;
        
        rden <= '0';
        wait;
    end process;

end behavior;