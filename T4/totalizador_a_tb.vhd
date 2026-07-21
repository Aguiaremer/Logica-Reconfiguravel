library ieee;
use ieee.std_logic_1164.all;

entity totalizador_a_tb is
end entity;

architecture sim of totalizador_a_tb is
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '0';
    signal data_in  : std_logic_vector(4 downto 0) := (others => '0');
    signal count_out: std_logic_vector(2 downto 0);

    constant clk_period : time := 10 ns;
begin
    -- Instância da Unidade Sob Teste (UUT)
    uut: entity work.totalizador_a
        port map (
            clk => clk,
            reset => reset,
            data_in => data_in,
            count_out => count_out
        );

    -- Gerador de Clock
    clk_process : process
    begin
        clk <= '0'; wait for clk_period/2;
        clk <= '1'; wait for clk_period/2;
    end process;

    -- Estímulos
    stim_proc: process
    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        -- Teste 1: Palavra "10111" (Total 4)
        data_in <= "10111";
        wait for 60 ns; -- Aguarda 6 ciclos (1 carga + 5 contagens)

        -- Teste 2: Palavra "00101" (Total 2)
        data_in <= "00101";
        wait for 60 ns;

        wait;
    end process;
end architecture;