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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity systolic_array is
  generic(
    SIZE_MATRIX_A   : matrix_size_type := (4,4); -- size in (rows, columns)
    SIZE_MATRIX_B   : matrix_size_type := (4,4);
    DATA_WIDTH : integer := 32
  );
  Port ( 
    clk : in std_logic;
    rst : in std_logic;
    
    matrix_a_entry : in std_logic_vector(DATA_WIDTH-1 downto 0);
    matrix_b_entry : in std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end systolic_array;

architecture Behavioral of systolic_array is

begin
    -- Make sure that a valid matrix configuration is present
    assert (SIZE_MATRIX_A(1) = SIZE_MATRIX_A(0) )
        report "Columns of A == ROWS of B is not fulfilled" severity error;

end Behavioral;
