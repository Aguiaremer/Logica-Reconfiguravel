library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_contador is
-- Testbench não possui portas
end tb_contador;

architecture Behavioral of tb_contador is
    -- Sinais para conectar ao componente
    signal CLK : std_logic := '0';
    signal RST : std_logic := '0';
    signal CLR : std_logic := '0';
    signal EN  : std_logic := '0';
    signal Q   : std_logic_vector(3 downto 0);

    -- Constante de período do Clock (THigh + TLow = 20ns)
    constant CLK_PERIOD : time := 20 ns;

begin
    -- Instanciação do Contador (UUT - Unit Under Test)
    uut: entity work.contador_4bits
        port map (
            CLK => CLK,
            RST => RST,
            CLR => CLR,
            EN  => EN,
            Q   => Q
        );

    -- Processo de Clock: Quadrado, começando em Baixo (0)
    clk_process : process
    begin
        CLK <= '0';
        wait for 10 ns;
        CLK <= '1';
        wait for 10 ns;
    end process;

    -- Processo de Estímulos
    stim_proc: process
    begin		
        -- RST: nível alto de 0 a 15 ns
        RST <= '1';
        wait for 15 ns;
        RST <= '0';

        -- EN: Alto de 0 a 185 ns (já começou em 0ns, então mantemos até 185)
        EN <= '1';
        
        -- CLR: Alto de 75 a 95 ns e de 125 a 145 ns
        -- Controlamos o CLR e o EN através de waits relativos
        
        wait for 60 ns; -- Chegamos em 75ns (15 + 60)
        CLR <= '1';
        wait for 20 ns; -- Chegamos em 95ns
        CLR <= '0';
        
        wait for 30 ns; -- Chegamos em 125ns (95 + 30)
        CLR <= '1';
        wait for 20 ns; -- Chegamos em 145ns
        CLR <= '0';

        wait for 40 ns; -- Chegamos em 185ns (145 + 40)
        EN <= '0';      -- EN fica baixo no restante

        wait; -- Finaliza a simulação
    end process;

end Behavioral;