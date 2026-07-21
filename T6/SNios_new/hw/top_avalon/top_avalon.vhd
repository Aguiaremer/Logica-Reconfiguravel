library ieee;
use ieee.std_logic_1164.all;

entity top_avalon is
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
end top_avalon;

architecture rtl of top_avalon is

    -- Signals (reordenados e renomeados)
    signal rst_i          : std_logic;
    signal clear_s        : std_logic;
    signal enable_s       : std_logic;
    signal load_en_s      : std_logic;
    signal w_en_reg0      : std_logic;
    signal w_en_reg1      : std_logic;
    signal rd_en_reg0     : std_logic;
    signal rd_en_reg1     : std_logic;
    signal counter_q      : std_logic_vector(7 downto 0);
    signal counter_load   : std_logic_vector(7 downto 0);
    signal out_reg0       : std_logic_vector(31 downto 0);
    signal out_reg1       : std_logic_vector(31 downto 0);

    -- Component declarations
    component top_bram
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
    end component;

    component cont8
        port (
            RST  : in  std_logic;
            CLK  : in  std_logic;
            Q    : out std_logic_vector(7 downto 0);
            EN   : in  std_logic;
            CLR  : in  std_logic;
            LD   : in  std_logic;
            LOAD : in  std_logic_vector(7 downto 0)
        );
    end component;

    component reg32
        port (
            clock  : in  std_logic;
            resetn : in  std_logic;
            WE     : in  std_logic;
            D      : in  std_logic_vector(31 downto 0);
            Q      : out std_logic_vector(31 downto 0)
        );
    end component;

begin

    -- Lógica de Reset Invertido
    rst_i <= not resetn;

    -- Instanciação do bloco wrapper da memória BRAM
    bram_wrapper_inst : top_bram
        port map (
            clock      => clock,
            resetn     => resetn,
            chipselect => chipselect,
            writedata  => writedata,
            write_en   => write_en,
            readdata   => readdata,
            add        => add,
            read_en    => read_en
        );

end rtl;