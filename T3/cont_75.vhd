library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cont_75 is
    Port ( 
        CLK : in  STD_LOGIC;
        RST : in  STD_LOGIC;
        CLR : in  STD_LOGIC;
        EN  : in  STD_LOGIC;
        Q   : out STD_LOGIC_VECTOR (7 downto 0)
    );
end cont_75;

architecture Behavioral of cont_75 is

    component contador_4bits is 
        Port ( 
            CLK  : in  STD_LOGIC;
            RST  : in  STD_LOGIC;
            CLR  : in  STD_LOGIC;
            EN   : in  STD_LOGIC;
            PUSH : in  STD_LOGIC_VECTOR (3 downto 0);
            Q    : out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;

    signal count_reg : STD_LOGIC_VECTOR(7 downto 0);
    signal clr_geral : STD_LOGIC;
    signal en_dezena : STD_LOGIC;

begin 

    en_dezena <= EN when count_reg(3 downto 0) = "1001" else '0';

    clr_geral <= '1' when (CLR = '1') or (EN = '1' and std_logic_vector(count_reg(7 downto 4)) = "1000" and std_logic_vector(count_reg(3 downto 0)) = "1001") else '0';

    uni : contador_4bits
        Port map (
            CLK  => CLK,
            RST  => RST,
            CLR  => clr_geral,
            EN   => EN,
            PUSH => "0101",
            Q    => count_reg(3 downto 0)
        );

    dez : contador_4bits
        Port map (
            CLK  => CLK,
            RST  => RST,
            CLR  => clr_geral,
            EN   => en_dezena,
            PUSH => "0001",
            Q    => count_reg(7 downto 4)
        );

    Q <= count_reg;
end Behavioral;