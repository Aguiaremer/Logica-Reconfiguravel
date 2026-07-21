library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity T5 is
    port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        ready_out : out std_logic
    );
end T5;

architecture Behavioral of T5 is

    constant DEPTH_BRAM  : integer := 2048;
    constant DEPTH_FIFO  : integer := 1024;
    constant UPPER_LIMIT : integer := 768; -- 75%
    constant LOWER_LIMIT : integer := 512; -- 50%

    type state_wr_type is (RESET, LOAD_BRAM, WR_FIFO, WR_WAIT);
    signal state_wr : state_wr_type := RESET;

    type state_rd_type is (RESET_RD, RD_FIFO, RD_WAIT);
    signal state_rd : state_rd_type := RESET_RD;

    signal addr1 : std_logic_vector(10 downto 0) := (others => '0');
    signal di1   : std_logic_vector(7 downto 0)  := (others => '0');
    signal we1   : std_logic := '0';
    signal do1   : std_logic_vector(7 downto 0);

    signal wr_en_fifo    : std_logic := '0';
    signal rd_en_fifo    : std_logic := '0';
    signal fifo_usedw_sig: std_logic_vector(9 downto 0);
	 signal usedw_fifo  : integer range 0 to DEPTH_FIFO;
    signal data_fifo_out : std_logic_vector(7 downto 0);
    signal empty_fifo     : std_logic;
    signal full_fifo      : std_logic;

    signal addr2 : std_logic_vector(10 downto 0) := (others => '0');
    signal we2   : std_logic := '0';

    signal speed_cnt : integer range 0 to 6 := 0;
    signal tick_7x   : std_logic := '0';

begin

    
    BRAM1: entity work.BRAM
        port map (clock => clk, data => di1, rdaddress => addr1, rden => '1',
                  wraddress => addr1, wren => we1, q => do1);
						
	 usedw_fifo <= to_integer(unsigned(fifo_usedw_sig));
	
    FIFO_INST: entity work.fifo
        port map (clock => clk, data => do1, rdreq => rd_en_fifo, wrreq => wr_en_fifo,
                  empty => empty_fifo, full => full_fifo, q => data_fifo_out, usedw => fifo_usedw_sig);

    BRAM2: entity work.BRAM
        port map (clock => clk, data => data_fifo_out, rdaddress => (others => '0'), rden => '0',
                  wraddress => addr2, wren => we2, q => open);

    ------------------------------------------------------------------
    -- DIVISOR DE VELOCIDADE (7x mais lento)
    ------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                speed_cnt <= 0;
                tick_7x <= '0';
            elsif speed_cnt = 6 then
                speed_cnt <= 0;
                tick_7x <= '1';
            else
                speed_cnt <= speed_cnt + 1;
                tick_7x <= '0';
            end if;
        end if;
    end process;

    ------------------------------------------------------------------
    --MÁQUINA DE ESTADOS: ESCRITA (BRAM1 -> FIFO)
    ------------------------------------------------------------------
    process(clk)
        variable v_addr1 : integer range 0 to DEPTH_BRAM := 0;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state_wr   <= RESET;
                v_addr1    := 0;
                we1        <= '0';
                wr_en_fifo <= '0';
            else
                case state_wr is
                    when RESET =>
                        v_addr1 := 0;
                        state_wr <= LOAD_BRAM;

                    when LOAD_BRAM =>
                        if v_addr1 < DEPTH_BRAM then
                            we1   <= '1';
                            addr1 <= std_logic_vector(to_unsigned(v_addr1, 11));
                            di1   <= std_logic_vector(to_unsigned(v_addr1 mod 256, 8));
                            v_addr1 := v_addr1 + 1;
                        else
                            we1   <= '0';
                            v_addr1 := 0; 
                            state_wr <= WR_FIFO;
                        end if;

                    when WR_FIFO =>
                        if v_addr1 < DEPTH_BRAM then
                            if usedw_fifo >= UPPER_LIMIT then
                                wr_en_fifo <= '0';
                                state_wr   <= WR_WAIT;
                            else
                                we1        <= '0';
                                addr1      <= std_logic_vector(to_unsigned(v_addr1, 11));
                                wr_en_fifo <= '1';
                                v_addr1    := v_addr1 + 1;
                            end if;
                        else
                            wr_en_fifo <= '0';
                        end if;

                    when WR_WAIT =>
                        wr_en_fifo <= '0';
                        if usedw_fifo <= LOWER_LIMIT then
                            state_wr <= WR_FIFO;
                        end if;
                end case;
            end if;
        end if;
    end process;

    ------------------------------------------------------------------
    --MÁQUINA DE ESTADOS: LEITURA (FIFO -> BRAM2)
    ------------------------------------------------------------------
    process(clk)
        variable v_addr2 : integer range 0 to DEPTH_BRAM := 0;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state_rd   <= RESET_RD;
                v_addr2    := 0;
                rd_en_fifo <= '0';
                we2        <= '0';
                ready_out  <= '0';
            elsif tick_7x = '1' then 
                case state_rd is
                    when RESET_RD =>
                        if empty_fifo = '0' then
                            state_rd <= RD_FIFO;
                        end if;

                    when RD_FIFO =>
								if empty_fifo = '1' then
                                rd_en_fifo <= '0';
                                we2        <= '0';
                                state_rd   <= RD_WAIT;
                        elsif v_addr2 < DEPTH_BRAM then
                                rd_en_fifo <= '1';
                                we2        <= '1';
                                addr2      <= std_logic_vector(to_unsigned(v_addr2, 11));
                                v_addr2    := v_addr2 + 1;
                        else
                            rd_en_fifo <= '0';
                            we2        <= '0';
                            ready_out  <= '1';
                        end if;

                    when RD_WAIT =>
                        rd_en_fifo <= '0';
                        we2        <= '0';
                        if empty_fifo = '0' then
                            state_rd <= RD_FIFO;
                        end if;
                end case;
            else
                rd_en_fifo <= '0';
                we2        <= '0';
            end if;
        end if;
    end process;

end Behavioral;