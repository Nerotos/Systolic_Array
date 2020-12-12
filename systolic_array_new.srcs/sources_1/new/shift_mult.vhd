library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.MATH_REAL.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


-- Implements a three stage shift multiplier

entity shift_multiplier is
    generic(
        DATA_WIDTH : integer := 32;
        --NUM_PIPELINE_STAGES: integer := 3; -- Configure number of pipeline stages
        NUM_SIGN_BITS: integer := 0 -- Set to '1' to enable signed operations
    );

    port(
        clk         : in std_logic;
        rst         : in std_logic;

        x           : in std_logic_vector(DATA_WIDTH-1 downto 0);
        y           : in std_logic_vector(DATA_WIDTH-1 downto 0);
        enable       : in std_logic;

        z           : out std_logic_vector(2*DATA_WIDTH-1 downto 0);
        valid       : out std_logic

    );
end shift_multiplier;

architecture behav of shift_multiplier is

    -- Define boundaries that each stage has to process
    constant NUM_SHIFT_OPS              : integer   := DATA_WIDTH + 1 -NUM_SIGN_BITS; -- how often must we shift our data
    constant PROCESS_BITS_STAGE         : integer  := integer(real(NUM_SHIFT_OPS)/real(3)); -- round to nearest
    constant PROCESS_BITS_LAST_STAGE    : integer := NUM_SHIFT_OPS - (2*PROCESS_BITS_STAGE);

    constant STAGE_1_LSB : integer := 0;
    constant STAGE_1_MSB : integer := DATA_WIDTH-1-NUM_SIGN_BITS + PROCESS_BITS_STAGE;
    constant STAGE_1_START_H : integer := DATA_WIDTH-1-NUM_SIGN_BITS;
    constant STAGE_1_START_L : integer := 0;

    constant STAGE_2_LSB : integer := DATA_WIDTH-1-NUM_SIGN_BITS + PROCESS_BITS_STAGE + 1;
    constant STAGE_2_MSB : integer := STAGE_2_LSB + PROCESS_BITS_STAGE;
    constant STAGE_2_START_H : integer := STAGE_1_START_H + PROCESS_BITS_STAGE;
    constant STAGE_2_START_L : integer := STAGE_1_START_L + PROCESS_BITS_STAGE;

    constant STAGE_3_LSB : integer := STAGE_2_MSB + 1;
    constant STAGE_3_MSB : integer := 2*DATA_WIDTH-1;
    constant STAGE_3_START_H : integer := STAGE_2_START_H + PROCESS_BITS_STAGE;
    constant STAGE_3_START_L : integer := STAGE_2_START_L + PROCESS_BITS_STAGE;
    
    -- Define types of stage registers
    type generic_stage_reg_type is record
        data_x  : std_logic_vector(DATA_WIDTH-1-NUM_SIGN_BITS downto 0);
        data_y  : std_logic_vector(DATA_WIDTH-1-NUM_SIGN_BITS downto 0);
        data_z  : std_logic_vector((2*DATA_WIDTH)-1 downto 0);
        data_rdy : std_logic;
    end record;

    constant stage_reg_rst : generic_stage_reg_type :=(
        data_x => (others=>'0'),
        data_y => (others=>'0'),
        data_z => (others=>'0'),
        data_rdy => '0'
    );
    
    
    function SHIFT_MULTIPLY(START_HIGH, START_LOW, BITS_STAGE : integer; reg : generic_stage_reg_type) return generic_stage_reg_type is
        variable temp : generic_stage_reg_type;
    begin
        temp := reg;
        
        for i in 0 to BITS_STAGE-1 loop
            if temp.data_y(0) = '1' then
                temp.data_z(START_HIGH+i downto START_LOW+i) := std_logic_vector( unsigned( temp.data_z(START_HIGH+i downto START_LOW+i) ) + unsigned(temp.data_x) );
            end if;
            --temp.data_x := temp.data_x(DATA_WIDTH-1-1 downto 0) & '0'; -- shift data_x left
            temp.data_y := '0' & temp.data_y(DATA_WIDTH-1-NUM_SIGN_BITS downto 1) ; -- shift data_y right
        end loop;
        
        return temp;
    end SHIFT_MULTIPLY;

    signal stage_2_reg : generic_stage_reg_type;
    signal stage_2_next_reg : generic_stage_reg_type;
    signal stage_3_reg : generic_stage_reg_type;
    signal stage_3_next_reg : generic_stage_reg_type;

begin

    assert (NUM_SIGN_BITS = 1 or NUM_SIGN_BITS= 0) report "NUM_SIGN_BITS must be 0 or 1" severity error;
   -- assert (NUM_STAGES <= DATA_WIDTH-NUM_SIGN_BITS) report "There can't be more stages then bits used per number");

    pipeline : process(x,y,enable,stage_2_reg, stage_3_reg)
        variable stage_1_var : generic_stage_reg_type;
        variable stage_2_var : generic_stage_reg_type;
        variable stage_3_var : generic_stage_reg_type;
    begin

        -- STAGE 1
        -- Read input
        if enable = '1' then
        
            if (NUM_SIGN_BITS = 0) then
                stage_1_var.data_x := x;
                stage_1_var.data_y := y;
                stage_1_var.data_z := (others => '0');
                stage_1_var.data_rdy := enable;
            else 
                stage_1_var.data_x := std_logic_vector(abs( signed(x(DATA_WIDTH-2 downto 0)) ));
                stage_1_var.data_y := std_logic_vector(abs( signed(y(DATA_WIDTH-2 downto 0)) ));
                stage_1_var.data_z := (others => '0');
                stage_1_var.data_z(2*DATA_WIDTH-1) := x(DATA_WIDTH-1) xor y(DATA_WIDTH-1); -- sign bit
                stage_1_var.data_rdy := enable;
            end if;
            
            
        end if;
        
        -- shift-multiply algorithm
        stage_1_var := SHIFT_MULTIPLY(STAGE_1_START_H, STAGE_1_START_L, PROCESS_BITS_STAGE, stage_1_var);
        stage_2_next_reg <= stage_1_var;
        
        -- STAGE 2
        stage_2_var := stage_2_reg;
        stage_2_var := SHIFT_MULTIPLY(STAGE_2_START_H, STAGE_2_START_L, PROCESS_BITS_STAGE, stage_2_var);
        stage_3_next_reg <= stage_2_var;
        
        -- STAGE 3
        stage_3_var := stage_3_reg;
        stage_3_var := SHIFT_MULTIPLY(STAGE_3_START_H, STAGE_3_START_L, PROCESS_BITS_LAST_STAGE, stage_3_var);

        -- Set output
        -- Check sign bit. Calculate two's complement if necessary
        if stage_3_var.data_z(2*DATA_WIDTH-1) = '1' and NUM_SIGN_BITS = 1 then
            stage_3_var.data_z := stage_3_var.data_z(2*DATA_WIDTH-1) & std_logic_vector( unsigned( not stage_3_var.data_z(2*DATA_WIDTH-2 downto 0)) + 1);
        end if;
        z <= stage_3_var.data_z;
        valid <= stage_3_var.data_rdy;

    end process;
    
    -- Update registers
    synch: process(clk, rst)
    begin
        if rst = '1' then
            -- reset registers
            stage_2_reg <= stage_reg_rst;
            stage_3_reg <= stage_reg_rst;
        else
            if rising_edge(clk) then
                -- Shift registers to next stage if valid data is present
                if stage_2_next_reg.data_rdy = '1' then
                    stage_2_reg <= stage_2_next_reg;
                end if;
                
                if stage_3_next_reg.data_rdy = '1' then
                    stage_3_reg <= stage_3_next_reg;
                end if;
            end if;

        end if;

    end process;

end behav;