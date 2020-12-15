----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.12.2020 21:26:50
-- Design Name: 
-- Module Name: shift_register_lut - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity shift_register_lut is
  generic(
    WIDTH : integer := 32;
    DEPTH : integer := 8
  );
  Port (
    clk         : in std_logic;
    rst         : in std_logic;
    
    wr_en       : in std_logic;
    data_in     : in std_logic_vector(WIDTH-1 downto 0);
    rd_en       : in std_logic;
    data_out    : out std_logic_vector(WIDTH-1 downto 0);
    
    full        : out std_logic;
    empty       : out std_logic
  );
end shift_register_lut;

architecture Behavioral of shift_register_lut is

    type shift_reg_type is array (0 to DEPTH-1) of std_logic_vector(WIDTH-1 downto 0);
    subtype index_int is integer range 0 to DEPTH-1;
    
    function incr_counter(cnt : index_int) return index_int is
        variable temp : integer;
    begin
        temp := cnt;
        
        if temp = DEPTH-1 then
            return DEPTH-1;
        else
            temp := temp+1;
            return temp;
        end if;
    end incr_counter;

    function decr_counter(cnt : index_int) return index_int is
        variable temp : integer;
    begin
        temp := cnt;
        
        if temp = 0 then
            return 0;
        else
            temp := temp-1;
            return temp;
        end if;
    end decr_counter;

    signal shift_reg : shift_reg_type;
    signal counter  : index_int;

begin

    process(clk, rst)
    begin
        if rst = '1' then
            shift_reg <= (others => (others=>'0'));
            counter <= 0;
            empty <= '1';
        else
            if rising_edge(clk) then
            
                empty <= '0';
                full <= '0';
            
                -- update counter
                if wr_en = '1' and rd_en = '1' then
                    -- no change
                elsif wr_en = '1' then
                    counter <= incr_counter(counter);
                elsif rd_en = '1' then
                    counter <= decr_counter(counter );
                end if;
                
                -- set full/empty flag
                if counter = 0 then
                    if wr_en = '0' then
                        empty <= '1';
                    end if;
                elsif counter = DEPTH-2 then
                    if wr_en = '1' then
                        full <= '1';
                    end if;
                elsif counter = DEPTH-1 then
                    if rd_en = '0' then
                        full <= '1';
                    end if;
                end if;
                
                -- store new data if valid and not full
                if wr_en = '1' and rd_en = '1' then
                    
                   if counter > 0 then
                        data_out <= shift_reg(0);
                        for i in 0 to DEPTH-1 loop
                            if i <= counter-1 then
                                shift_reg(i) <= shift_reg(i+1);
                            end if;
                        end loop;
                    end if;
                    
                    if counter < DEPTH-1 then
                        shift_reg(counter-1) <= data_in;
                    end if;
                    
 
                    
                elsif wr_en = '1' then
                    if counter < DEPTH-1 then
                        shift_reg(counter) <= data_in;
                    end if;
                elsif rd_en = '1' then
                    if counter > 0 then
                        data_out <= shift_reg(0);
                        for i in 0 to DEPTH-2 loop
                            shift_reg(i) <= shift_reg(i+1);
                        end loop;
                    end if;
                end if;
                
 
            end if;
        
        end if;
    end process;


end Behavioral;
