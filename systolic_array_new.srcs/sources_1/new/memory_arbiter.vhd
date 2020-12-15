----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.12.2020 23:02:52
-- Design Name: 
-- Module Name: memory_arbiter - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

use IEEE.math_real.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library work;
use work.systolic_array_lib.all;

entity memory_arbiter is
  generic(
    WIDTH : integer := 32;
    DEPTH : integer := 8;
    NUM_MODULES : integer := 4
  );
  
  Port ( 
  
    clk : in std_logic;
    rst : in std_logic;
    
    read_out : in std_logic;
    
    data_in : in std_logic_vector(WIDTH-1 downto 0);
    valid : in std_logic;
    
    data_out : out memory_arbiter_out
    
  );
end memory_arbiter;

architecture Behavioral of memory_arbiter is
    
    type fifo_input_vector is array (0 to NUM_MODULES-1) of std_logic_vector(WIDTH-1 downto 0);
    subtype sel_int_type is integer range 0 to NUM_MODULES-1;
    
    -- increment counter with wrap-around
    function incr_counter(cnt : sel_int_type) return sel_int_type is
        variable temp : integer;
    begin
        temp := cnt;
        
        if temp = NUM_MODULES-1 then
            return 0;
        else
            temp := temp+1;
            return temp;
        end if;
    end incr_counter;


    constant sel_bits : integer := integer(ceil(log2(real(NUM_MODULES))));
    
    signal fifo_input : fifo_input_vector;
    signal fifo_rd_en : std_logic_vector(0 to NUM_MODULES-1);
    signal fifo_wr_en : std_logic_vector(0 to NUM_MODULES-1);
    signal sel : integer;

begin

    fifo_gen : for I in 0 to NUM_MODULES-1 generate
        fifo : shift_register_lut
            generic map(
                WIDTH => WIDTH,
                DEPTH => DEPTH
            )
            port map(
                clk => clk,
                rst => rst,
                
                wr_en => fifo_wr_en(i),
                rd_en => fifo_rd_en(i),
                
                data_in => fifo_input(i),
                data_out => data_out(i)
            );
    end generate fifo_gen;

    mux_process : process(clk, rst)
    begin
        if rst = '1' then
            sel <= 0;
        else
            if rising_edge(clk) then
                if valid = '1' then
                    fifo_input(sel) <= data_in;
                    
                    -- enable correct fifo
                    for i in 0 to NUM_MODULES-1 loop
                        if i = sel then
                            fifo_wr_en(sel) <= '1';
                        else
                            fifo_wr_en(i) <= '0';
                        end if;
                    end loop;
                    sel <= incr_counter(sel);
                end if;
                
                if read_out = '1' then
                    fifo_rd_en <= (others => '1');
                end if;
                
            end if;
        end if;
    
    end process;


end Behavioral;
