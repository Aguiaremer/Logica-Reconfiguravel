library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_bram is
    port (
        clock      : in  std_logic;
        resetn     : in  std_logic;
        chipselect : in  std_logic;
        writedata  : in  std_logic_vector(31 downto 0);
        write_en   : in  std_logic;
        readdata   : out std_logic_vector(31 downto 0);
        add        : in  std_logic_vector(1 downto 0);
        read_en    : in  std_logic
    );
end top_bram;

architecture behavioral of top_bram is

    component bram
        port (
            address : in  std_logic_vector(9 downto 0);
            clock   : in  std_logic;
            data    : in  std_logic_vector(7 downto 0);
            wren    : in  std_logic;
            q       : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Tipos customizados para mascarar a máquina de busca/leitura original
    type t_state is (ST_IDLE, ST_WAIT, ST_CAPTURE);
    signal current_state : t_state := ST_IDLE;

    -- Registradores internos inicializados para mitigar problemas com 'U' ou 'X'
    signal addr_ptr         : std_logic_vector(9 downto 0) := (others => '0');
    signal byte_buffer      : std_logic_vector(7 downto 0) := (others => '0');
    signal expected_sum_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal packet_id_reg    : std_logic_vector(7 downto 0) := (others => '0');
    
    -- Sinais de barramento e acumulador
    signal write_strobe     : std_logic := '0';
    signal ram_output_sig   : std_logic_vector(7 downto 0) := (others => '0');
    signal acc_checksum     : unsigned(7 downto 0) := (others => '0');

begin

    -- Instanciação do bloco de memória nativo da FPGA
    memory_core_inst : bram
        port map (
            address => addr_ptr,
            clock   => clock,
            data    => byte_buffer,
            wren    => write_strobe,
            q       => ram_output_sig
        );

    -- Processo sequencial principal para gerenciar escrita e amostragem
    proc_bus_sync : process(clock, resetn)
    begin
        if resetn = '0' then
            addr_ptr         <= (others => '0');
            byte_buffer      <= (others => '0');
            write_strobe     <= '0';
            acc_checksum     <= (others => '0');
            expected_sum_reg <= (others => '0');
            packet_id_reg    <= (others => '0');
            current_state    <= ST_IDLE;
        elsif rising_edge(clock) then
            write_strobe <= '0';

            -- Decodificação de ciclos de escrita Avalon-MM
            if chipselect = '1' and write_en = '1' then
                case add is
                    when "00" => 
                        addr_ptr <= writedata(9 downto 0);
                    when "01" => 
                        byte_buffer <= writedata(7 downto 0);
                    when "10" =>
                        packet_id_reg    <= writedata(31 downto 24);
                        expected_sum_reg <= writedata(23 downto 16);
                        
                        if writedata(0) = '1' then
                            write_strobe <= '1';
                            acc_checksum <= acc_checksum + unsigned(byte_buffer);
                        end if;
                        if writedata(1) = '1' then
                            current_state <= ST_WAIT;
                        end if;
                        if writedata(2) = '1' then
                            acc_checksum <= (others => '0');
                        end if;
                    when others => 
                        null;
                end case;
            end if;

            -- Máquina de leitura síncrona reestruturada
            case current_state is
                when ST_WAIT =>
                    current_state <= ST_CAPTURE;
                when ST_CAPTURE =>
                    byte_buffer   <= ram_output_sig;
                    current_state <= ST_IDLE;
                when others =>
                    null;
            end case;
        end if;
    end process;

    -- Processo combinacional para interfaceamento de leitura e tri-state
    proc_avalon_output : process(chipselect, read_en, add, addr_ptr, byte_buffer, acc_checksum, packet_id_reg, expected_sum_reg)
        variable v_checksum_valid : std_logic;
    begin
        -- Validação paralela do checksum calculado versus o esperado pelo Nios II
        if expected_sum_reg = std_logic_vector(acc_checksum) then
            v_checksum_valid := '1';
        else
            v_checksum_valid := '0';
        end if;

        -- Controle de alta impedância (Z) para evitar contenção de barramento externo
        if (chipselect = '1' and read_en = '1') then
            case add is
                when "00" => 
                    readdata <= std_logic_vector(resize(unsigned(addr_ptr), 32));
                when "01" => 
                    readdata <= std_logic_vector(resize(unsigned(byte_buffer), 32));
                when "10" => 
                    readdata <= packet_id_reg & expected_sum_reg & std_logic_vector(acc_checksum) & v_checksum_valid & "0000000";
                when others => 
                    readdata <= (others => '0');
            end case;
        else
            readdata <= (others => 'Z');
        end if;
    end process;

end behavioral;