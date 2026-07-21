library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity contador_4bits is
    Port ( 
        CLK : in  STD_LOGIC;
        RST : in  STD_LOGIC; -- Reset Assíncrono
        CLR : in  STD_LOGIC; -- Clear Síncrono
        EN  : in  STD_LOGIC; -- Enable
        Q   : out STD_LOGIC_VECTOR (3 downto 0)
    );
end contador_4bits;

architecture Behavioral of contador_4bits is
    signal count_reg : unsigned(3 downto 0) := (others => '0');
begin
    process(CLK, RST)
    begin
        -- Reset Assíncrono (prioridade máxima)
        if RST = '1' then
            count_reg <= (others => '0');
        elsif rising_edge(CLK) then
            -- Clear Síncrono
            if CLR = '1' then
                count_reg <= (others => '0');
            -- Incremento condicionado ao Enable
            elsif EN = '1' then
                count_reg <= count_reg + 1;
            end if;
        end if;
    end process;

    Q <= std_logic_vector(count_reg);
end Behavioral;