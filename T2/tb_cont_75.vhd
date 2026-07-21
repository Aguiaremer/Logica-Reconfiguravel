library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_cont_75 is
-- Testbench não tem portas
end tb_cont_75;

architecture Behavioral of tb_cont_75 is

    component cont_75 is
        Port (  
            CLK : in  STD_LOGIC;
            RST : in  STD_LOGIC;
            CLR : in  STD_LOGIC;
            EN  : in  STD_LOGIC;
            Q   : out STD_LOGIC_VECTOR (7 downto 0)
        );
    end component;

    signal CLK : STD_LOGIC := '0';
    signal RST : STD_LOGIC := '0';
    signal CLR : STD_LOGIC := '0';
    signal EN  : STD_LOGIC := '0';
    signal Q   : STD_LOGIC_VECTOR(7 downto 0);

    constant clk_period : time := 10 ns;

begin

    uut: cont_75 
        port map (
            CLK => CLK,
            RST => RST,
            CLR => CLR,
            EN  => EN,
            Q   => Q
        );

    clk_process : process
    begin
        CLK <= '0';
        wait for clk_period/2;
        CLK <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin		
        RST <= '1';
        wait for 20 ns;	
        RST <= '0';
        
        EN <= '1';
        wait;
    end process;

end Behavioral;