library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity totalizador_b_tb is
end entity;

architecture sim of totalizador_b_tb is
    -- Sinais para conectar na UUT
    signal clk      : std_logic := '0';
    signal reset    : std_logic := '0'; -- Adicionado Reset
    signal entrada  : std_logic_vector(4 downto 0) := (others => '0');
    signal out_b1, out_b2, out_b3, out_b4, out_b5, out_b6 : std_logic_vector(2 downto 0);

    constant clk_period : time := 50 ns; -- Clock de 50MHz (mais seguro para Gate-Level)

begin
    -- Instanciação da Unidade Sob Teste (UUT)
    -- O label 'uut' deve ser o mesmo usado no seu arquivo .do (-sdftyp /uut=...)
    uut: entity work.totalizador_b
        port map (
            clk     => clk,
            -- Se sua entidade não tiver reset, remova a linha abaixo
            -- reset   => reset, 
            entrada => entrada,
            out_b1  => out_b1,
            out_b2  => out_b2,
            out_b3  => out_b3,
            out_b4  => out_b4,
            out_b5  => out_b5,
            out_b6  => out_b6
        );

    -- Gerador de Clock
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Processo de Estímulos
    stim_proc: process
    begin
        -- 1. Reset Inicial (Essencial para Gate-Level não ficar vermelho)
        reset <= '1';
        entrada <= "00000";
        wait for clk_period * 2;
        reset <= '0';
        wait for 5 ns; -- Pequeno deslocamento para não coincidir com a borda

        -- 2. Testes de combinações
        -- Observe que usamos "wait for clk_period" para sincronizar
        
        entrada <= "10110"; -- 3 bits '1'
        wait for clk_period;

        entrada <= "00001"; -- 1 bit '1'
        wait for clk_period;

        entrada <= "11111"; -- 5 bits '1'
        wait for clk_period;

        entrada <= "01010"; -- 2 bits '1'
        wait for clk_period;

        -- Finaliza
        wait;
    end process;

end architecture;