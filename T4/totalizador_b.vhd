library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity totalizador_b is
    port (
        clk      : in  std_logic;
        entrada  : in  std_logic_vector(4 downto 0);
        out_b1   : out std_logic_vector(2 downto 0); -- FOR Variable
        out_b2   : out std_logic_vector(2 downto 0); -- WHILE Variable
        out_b3   : out std_logic_vector(2 downto 0); -- IF-THEN Variable
        out_b4   : out std_logic_vector(2 downto 0); -- CASE-WHEN Signal
        out_b5   : out std_logic_vector(2 downto 0); -- SOMA Direta
        out_b6   : out std_logic_vector(2 downto 0)  -- DEMUX/Lookup
    );
end entity;

architecture behavioral of totalizador_b is
    -- Sinais auxiliares para os métodos de SIGNALS (b.5)
    -- Inicializamos com zero para evitar 'X' no tempo zero da simulação gate-level
    signal s_bit0 : unsigned(2 downto 0) := "000";
    signal s_bit1 : unsigned(2 downto 0) := "000";
    signal s_bit2 : unsigned(2 downto 0) := "000";
    signal s_bit3 : unsigned(2 downto 0) := "000";
    signal s_bit4 : unsigned(2 downto 0) := "000";
begin

    process(clk)
        -- Inicialização explícita na declaração das variáveis para simulação funcional
        variable v_count_for   : unsigned(2 downto 0) := "000";
        variable v_count_while : unsigned(2 downto 0) := "000";
        variable v_count_if    : unsigned(2 downto 0) := "000";
        variable i : integer := 0;
    begin
        if rising_edge(clk) then
            
            -- b.1) VARIABLES FOR
            v_count_for := "000"; -- Reset obrigatório a cada subida de clock
            for j in 0 to 4 loop
                if entrada(j) = '1' then 
                    v_count_for := v_count_for + 1; 
                end if;
            end loop;
            out_b1 <= std_logic_vector(v_count_for);

            -- b.2) VARIABLES WHILE
            v_count_while := "000"; -- Reset obrigatório
            i := 0;
            while i < 5 loop
                if entrada(i) = '1' then 
                    v_count_while := v_count_while + 1; 
                end if;
                i := i + 1;
            end loop;
            out_b2 <= std_logic_vector(v_count_while);

            -- b.3) VARIABLES IF-THEN (Hardcoded)
            v_count_if := "000"; -- Reset obrigatório
            if entrada(0) = '1' then v_count_if := v_count_if + 1; end if;
            if entrada(1) = '1' then v_count_if := v_count_if + 1; end if;
            if entrada(2) = '1' then v_count_if := v_count_if + 1; end if;
            if entrada(3) = '1' then v_count_if := v_count_if + 1; end if;
            if entrada(4) = '1' then v_count_if := v_count_if + 1; end if;
            out_b3 <= std_logic_vector(v_count_if);

            -- b.4) SIGNALS CASE/WHEN 
            case entrada is
                when "00000" => out_b4 <= "000";
                when "00001" | "00010" | "00100" | "01000" | "10000" => out_b4 <= "001";
                when "00011" | "00101" | "01001" | "10001" | "00110" | "01010" | "10010" | "01100" | "10100" | "11000" => out_b4 <= "010";
                when "00111" | "01011" | "10011" | "01101" | "10101" | "11001" | "01110" | "10110" | "11010" | "11100" => out_b4 <= "011";
                when "01111" | "10111" | "11011" | "11101" | "11110" => out_b4 <= "100";
                when "11111" => out_b4 <= "101";
                when others => out_b4 <= "000"; -- Essencial para filtrar estados metaestáveis (X, U, Z)
            end case;

            -- b.5) SIGNALS SOMA DIRETA (Atribuição do resultado da soma dos sinais)
            out_b5 <= std_logic_vector(s_bit0 + s_bit1 + s_bit2 + s_bit3 + s_bit4);
            
            -- b.6) SOMA via "DEMUX"
            -- Usando uma lógica de soma protegida contra estados indefinidos
				out_b6 <= std_logic_vector(
					resize(unsigned(entrada(0 downto 0)), 3) + 
					resize(unsigned(entrada(1 downto 1)), 3) + 
					resize(unsigned(entrada(2 downto 2)), 3) + 
					resize(unsigned(entrada(3 downto 3)), 3) + 
					resize(unsigned(entrada(4 downto 4)), 3)
				 );
        end if;
    end process;

    -- Lógica para o b.5 (fora do processo para ser concorrente)
    s_bit0 <= "001" when entrada(0) = '1' else "000";
    s_bit1 <= "001" when entrada(1) = '1' else "000";
    s_bit2 <= "001" when entrada(2) = '1' else "000";
    s_bit3 <= "001" when entrada(3) = '1' else "000";
    s_bit4 <= "001" when entrada(4) = '1' else "000";

end architecture;