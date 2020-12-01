----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.12.2020 23:59:14
-- Design Name: 
-- Module Name: systolic_array - Behavioral
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

library work;
use work.systolic_array_lib.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ram is
  generic(
    DATA_WIDTH : integer := 32;
    ADDR_BITS  : integer := 6
  );
  Port ( 
    clk       : in std_logic;  
      
    din       : in std_logic_vector(DATA_WIDTH-1 downto 0);
    addr      : in std_logic_vector(ADDR_BITS-1 downto 0);
    en        : in std_logic;
    wen       : in std_logic;
    
    dout      : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end ram;

architecture Behavioral of ram is
    type ram_type is array(0 to (2**ADDR_Bits)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    
    signal my_ram : ram_type;
    
    -- Enforce block ram
    attribute ram_style : string;
    attribute ram_style of my_ram : signal is "block";
begin

process(clk)
begin
    if rising_edge(clk) then
        if en = '1' then
            if wen = '1' then
                my_ram(conv_integer(addr)) <= din;
            else
                dout <= my_ram(conv_integer(addr));
            end if;
        end if;
    end if;
    
end process;


end Behavioral;
