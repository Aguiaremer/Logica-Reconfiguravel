library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity totalizador_a is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        data_in  : in  std_logic_vector(4 downto 0);
        count_out: out std_logic_vector(2 downto 0)
    );
end entity;

architecture rtl of totalizador_a is
    signal shift_reg      : std_logic_vector(4 downto 0);
    signal internal_count : unsigned(2 downto 0);
    signal cycles         : integer range 0 to 5;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            internal_count <= (others => '0');
            shift_reg <= (others => '0');
            cycles <= 0;
        elsif rising_edge(clk) then
            if cycles = 0 then
                -- Carrega nova palavra e reseta contagem
                shift_reg <= data_in;
                internal_count <= (others => '0');
                cycles <= 5;
            else
                -- Conta 1 bit por ciclo
                if shift_reg(0) = '1' then
                    internal_count <= internal_count + 1;
                end if;
                -- Desloca para preparar o próximo bit
                shift_reg <= '0' & shift_reg(4 downto 1);
                cycles <= cycles - 1;
            end if;
        end if;
    end process;

    count_out <= std_logic_vector(internal_count);
end architecture;