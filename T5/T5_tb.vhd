library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity T5_tb is
end T5_tb;

architecture sim of T5_tb is
    signal clk       : std_logic := '0';
    signal rst       : std_logic := '0';
    signal ready_out : std_logic;

    constant clk_period : time := 20 ns;
begin
    uut: entity work.T5
        port map (
            clk       => clk,
            rst       => rst,
            ready_out => ready_out
        );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin		
        rst <= '1';
        wait for 100 ns;
        rst <= '0';

        wait until ready_out = '1' for 500 us;

        if ready_out = '1' then
            report "SUCESSO: A transferencia de 2048 palavras terminou corretamente.";
        else
            report "ERRO: Timeout atingido antes do sinal ready_out subir." severity error;
        end if;

        wait for 1 us;
        report "Fim da simulacao.";
        wait;
    end process;

end sim;