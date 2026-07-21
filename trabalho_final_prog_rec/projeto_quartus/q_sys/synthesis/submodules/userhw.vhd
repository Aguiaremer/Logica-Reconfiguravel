library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity user_hw is
  generic (
    data_width  : integer := 16; -- 16-bit audio/signal data
    coeff_width : integer := 16; -- 16-bit math precision for coefficients
    num_taps    : integer := 32  -- 32 physical filter taps
  );
  port (
    clk     : in    std_logic;
    reset_n : in    std_logic;

    -- ====================================================================
    -- Avalon-MM Interface (For Coefficient Configuration)
    -- ====================================================================
    mm_write     : in    std_logic;
    mm_addr      : in    std_logic_vector(5 downto 0); -- 2^6 = 64 addresses
    mm_writedata : in    std_logic_vector(coeff_width - 1 downto 0);
    mm_read      : in    std_logic;
    mm_readdata  : out   std_logic_vector(coeff_width - 1 downto 0);

    -- ====================================================================
    -- Avalon-ST Sink (input from stream source / FIFO)
    -- ====================================================================
    st_sink_data          : in    std_logic_vector(data_width - 1 downto 0);
    st_sink_valid         : in    std_logic;
    st_sink_ready         : out   std_logic;
    st_sink_startofpacket : in    std_logic;
    st_sink_endofpacket   : in    std_logic;
    st_sink_empty         : in    std_logic;

    -- ====================================================================
    -- Avalon-ST Source (output to stream sink / FIFO)
    -- ====================================================================
    st_source_data          : out   std_logic_vector(data_width - 1 downto 0);
    st_source_valid         : out   std_logic;
    st_source_ready         : in    std_logic;
    st_source_startofpacket : out   std_logic;
    st_source_endofpacket   : out   std_logic;
    st_source_empty         : out   std_logic
  );
end entity user_hw;

architecture a_user_hw of user_hw is

  -- Array types cleanly tied to NUM_TAPS for physical structure

  type data_array_type is array (0 to NUM_TAPS - 1) of signed(DATA_WIDTH - 1 downto 0);

  type coeff_array_type is array (0 to NUM_TAPS - 1) of signed(COEFF_WIDTH - 1 downto 0);

  -- Pipeline stage types for MAC (Multiply-Accumulate) operations
  -- Multiplying 16-bit by 16-bit results in a 32-bit product

  type prod_array_type is array (0 to NUM_TAPS - 1) of signed((DATA_WIDTH + COEFF_WIDTH) - 1 downto 0);

  -- Internal registers
  signal data_shifter      : data_array_type;
  signal coefficients_regs : coeff_array_type;
  signal products          : prod_array_type;

  -- Math Processing Registers (Matches 3-Stage pipeline delay)
  signal pipeline_out_data : signed(data_width - 1 downto 0);

  -- Control Pipeline Shift Registers
  signal pipe_valid : std_logic_vector(2 downto 0);
  signal pipe_sop   : std_logic_vector(2 downto 0);
  signal pipe_eop   : std_logic_vector(2 downto 0);

  signal stream_stall      : std_logic;
  signal swapped_sink_data : signed(15 downto 0);

begin

  -- Byte-swap incoming data to align 32-bit FIFO packing with little-endian Nios CPU
  swapped_sink_data <= signed(st_sink_data(7 downto 0) & st_sink_data(15 downto 8));

  -- ====================================================================
  -- 1. MM Coefficient Storage
  -- ====================================================================
  mm_write_proc : process (clk, reset_n) is
  begin

    if (reset_n = '0') then
      coefficients_regs <= (others => (others => '0'));
    elsif rising_edge(clk) then
      if (mm_write = '1') then
        coefficients_regs(to_integer(unsigned(mm_addr))) <= signed(mm_writedata);
      end if;
    end if;

  end process mm_write_proc;

  -- ====================================================================
  -- 2. Avalon-ST Flow Control Mapping & Stalling
  -- ====================================================================
  -- Stall when data is ready to exit our pipe but downstream FIFO is full
  stream_stall  <= pipe_valid(2) and not st_source_ready;
  st_sink_ready <= not stream_stall;

  -- ====================================================================
  -- 3. Shift Register & Core Math Engine Pipeline
  -- ====================================================================
  fifo_shift_proc : process (clk, reset_n) is

    variable sum_accumulator : signed((data_width + coeff_width) - 1 downto 0);

  begin

    if (reset_n = '0') then
      data_shifter      <= (others => (others => '0'));
      products          <= (others => (others => '0'));
      pipeline_out_data <= (others => '0');
      pipe_valid        <= (others => '0');
      pipe_sop          <= (others => '0');
      pipe_eop          <= (others => '0');
    elsif rising_edge(clk) then
      if (stream_stall = '0') then
        -- ==================================================================
        -- STAGE 1: Shift Register and Sample Input Updates
        -- ==================================================================
        if (st_sink_valid = '1') then
          -- Shift audio history
          for i in num_taps - 1 downto 1 loop

            data_shifter(i) <= data_shifter(i - 1);

          end loop;

          data_shifter(0) <= signed(swapped_sink_data);

          pipe_valid <= pipe_valid(1 downto 0) & '1';
          pipe_sop   <= pipe_sop(1 downto 0) & st_sink_startofpacket;
          pipe_eop   <= pipe_eop(1 downto 0) & st_sink_endofpacket;
        else
          -- Keep old data in shifter during idle, but cycle invalid control downstream
          pipe_valid <= pipe_valid(1 downto 0) & '0';
          pipe_sop   <= pipe_sop(1 downto 0) & '0';
          pipe_eop   <= pipe_eop(1 downto 0) & '0';
        end if;

        -- ==================================================================
        -- STAGE 2: Parallel Multiplication (Data * Coefficients)
        -- ==================================================================
        for i in 0 to num_taps - 1 loop

          products(i) <= data_shifter(i) * coefficients_regs(i);

        end loop;

        -- ==================================================================
        -- STAGE 3: Combinational Accumulation and Scaling
        -- ==================================================================
        sum_accumulator := (others => '0');

        for i in 0 to num_taps - 1 loop

          sum_accumulator := sum_accumulator + products(i);

        end loop;

        -- Truncate / scale back to your 16-bit output width.
        -- Dropping the bottom 15 fractional bits assuming Q15 formatting.
        pipeline_out_data <= sum_accumulator((data_width + coeff_width) - 2 downto coeff_width - 1);
      end if;
    end if;

  end process fifo_shift_proc;

  -- ====================================================================
  -- Avalon-MM Read Interface Allocation
  -- ====================================================================
  mm_read_proc : process (clk) is
  begin

    if rising_edge(clk) then
      if (mm_read = '1') then
        mm_readdata <= std_logic_vector(coefficients_regs(to_integer(unsigned(mm_addr))));
      end if;
    end if;

  end process mm_read_proc;

  -- ====================================================================
  -- 4. Streaming Source Output Assignment
  -- ====================================================================
  -- Byte-swap the results back to match the Nios memory space layout
  st_source_data(15 downto 8) <= std_logic_vector(pipeline_out_data(7 downto 0));
  st_source_data(7 downto 0)  <= std_logic_vector(pipeline_out_data(15 downto 8));

  st_source_valid         <= pipe_valid(2);
  st_source_startofpacket <= pipe_sop(2);
  st_source_endofpacket   <= pipe_eop(2);
  st_source_empty         <= '0';

end architecture a_user_hw;
