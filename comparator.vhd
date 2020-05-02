
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--Additional standard or custom libraries go here
entity comparator is
generic (
	constant DATA_WIDTH	: natural := 4
);
port(
	--Inputs
	signal dinl 		: in std_logic_vector (DATA_WIDTH downto 0);
	signal dinr 		: in std_logic_vector (DATA_WIDTH - 1 downto 0);

	--Outputs
	signal dout	    	: out std_logic_vector (DATA_WIDTH - 1 downto 0);
	signal isGreaterEq 	: out std_logic
);
end entity comparator;

architecture behavior of comparator is

begin
	compare_process: process(dinl, dinr)
	begin
		if ( signed(dinl) >= signed(dinr) ) then
			dout <= std_logic_vector(resize(signed(dinl) - signed(dinr), DATA_WIDTH));
			isGreaterEq <= '1';
		else
			dout <= std_logic_vector(resize(signed(dinl), DATA_WIDTH));
			isGreaterEq <= '0';
		end if;
	end process;

end architecture behavior;
