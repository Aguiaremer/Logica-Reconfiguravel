library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cronometro is
    Port ( 
        CLK       : in  STD_LOGIC; -- 50MHz
        RST_HARD  : in  STD_LOGIC; -- Reset Físico
        BT_START  : in  STD_LOGIC; -- Botão 1: Start/Stop/Resume
        BT_CLEAR  : in  STD_LOGIC; -- Botão 2: Zerar
        HEX0      : out STD_LOGIC_VECTOR (6 downto 0); -- Cent. Unidade
        HEX1      : out STD_LOGIC_VECTOR (6 downto 0); -- Cent. Dezena
        HEX2      : out STD_LOGIC_VECTOR (6 downto 0); -- Seg. Unidade
        HEX3      : out STD_LOGIC_VECTOR (6 downto 0)  -- Seg. Dezena
    );
end cronometro;

architecture Behavioral of cronometro is

    -- Sinais de Controle
    signal tick_10ms : std_logic := '0';
    signal rodando   : std_logic := '0';
    signal clr_geral : std_logic := '0';
    
    -- Sinais de Debounce
    signal bt1_deb, bt2_deb : std_logic := '0';
    signal bt1_old          : std_logic := '0';

    -- Sinais dos Contadores (BCD)
    signal c_un, c_de, s_un, s_de : std_logic_vector(3 downto 0);
    
    -- Sinais de Habilitação (Cascateamento)
    signal en_c_un, en_c_de, en_s_un, en_s_de : std_logic;

begin

    -------------------------------------------------------------------
    -- 1. GERAÇÃO DE CLOCK ENABLE (10ms = 100Hz)
    -- 50.000.000 ciclos / 100 = 500.000 ciclos para 1 tick
    -------------------------------------------------------------------
    process(CLK, RST_HARD)
        variable count : integer range 0 to 500000 := 0;
    begin
        if RST_HARD = '1' then
            count := 0;
            tick_10ms <= '0';
        elsif rising_edge(CLK) then
            tick_10ms <= '0';
            if count = 499999 then
                tick_10ms <= '1';
                count := 0;
            else
                count := count + 1;
            end if;
        end if;
    end process;

    -------------------------------------------------------------------
    -- 2. DEBOUNCE (30ms @ 50MHz = 1.500.000 ciclos)
    -------------------------------------------------------------------
    process(CLK)
        variable cnt1, cnt2 : integer range 0 to 1500000 := 0;
    begin
        if rising_edge(CLK) then
            -- Botão 1
            if BT_START = '1' then
                if cnt1 < 1500000 then cnt1 := cnt1 + 1; else bt1_deb <= '1'; end if;
            else cnt1 := 0; bt1_deb <= '0'; end if;
            -- Botão 2
            if BT_CLEAR = '1' then
                if cnt2 < 1500000 then cnt2 := cnt2 + 1; else bt2_deb <= '1'; end if;
            else cnt2 := 0; bt2_deb <= '0'; end if;
        end if;
    end process;

    -------------------------------------------------------------------
    -- 3. LÓGICA DE ESTADO (START/STOP e CLEAR)
    -------------------------------------------------------------------
    process(CLK, RST_HARD)
    begin
        if RST_HARD = '1' then
            rodando <= '0';
            clr_geral <= '1';
        elsif rising_edge(CLK) then
            bt1_old <= bt1_deb;
            clr_geral <= '0';

            -- Toggle Start/Stop na borda de subida do botão debounced
            if bt1_deb = '1' and bt1_old = '0' then
                rodando <= not rodando;
            end if;

            -- Clear só funciona se parado (rodando = '0')
            if rodando = '0' and bt2_deb = '1' then
                clr_geral <= '1';
            end if;
        end if;
    end process;

    -------------------------------------------------------------------
    -- 4. CASCATEAMENTO POR CLOCK ENABLE
    -------------------------------------------------------------------
    -- O primeiro contador só anda se (Estiver em modo 'rodando' AND houver o tick de 10ms)
    en_c_un <= rodando and tick_10ms;
    
    -- Os próximos só andam se o anterior estiver em "9" e o sinal de habilitação do anterior for '1'
    en_c_de <= '1' when (en_c_un = '1' and c_un = "1001") else '0';
    en_s_un <= '1' when (en_c_de = '1' and c_de = "1001") else '0';
    en_s_de <= '1' when (en_s_un = '1' and s_un = "1001") else '0';

    -------------------------------------------------------------------
    -- 5. INSTANCIAÇÃO DOS COMPONENTES (Usando os seus VHDLs base)
    -------------------------------------------------------------------
    
    -- Contadores (Note que todos usam o CLK de 50MHz agora)
    U0: entity work.contador_4bits port map(CLK=>CLK, RST=>RST_HARD, CLR=>clr_geral, EN=>en_c_un, PUSH=>"0000", Q=>c_un);
    U1: entity work.contador_4bits port map(CLK=>CLK, RST=>RST_HARD, CLR=>clr_geral, EN=>en_c_de, PUSH=>"0000", Q=>c_de);
    U2: entity work.contador_4bits port map(CLK=>CLK, RST=>RST_HARD, CLR=>clr_geral, EN=>en_s_un, PUSH=>"0000", Q=>s_un);
    U3: entity work.contador_4bits port map(CLK=>CLK, RST=>RST_HARD, CLR=>clr_geral, EN=>en_s_de, PUSH=>"0000", Q=>s_de);

    -- Decodificadores
    D0: entity work.bcd_7seg port map(BCD => c_un, SEG => HEX0);
    D1: entity work.bcd_7seg port map(BCD => c_de, SEG => HEX1);
    D2: entity work.bcd_7seg port map(BCD => s_un, SEG => HEX2);
    D3: entity work.bcd_7seg port map(BCD => s_de, SEG => HEX3);

end Behavioral;