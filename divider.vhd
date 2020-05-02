library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use WORK.divider_const.all;

--Additional standard or custom libraries go here
entity divider is 
	port(
		--Inputs
			clk 		: in std_logic;
			start		: in std_logic;
			rst		: in std_logic;
			dividend	: in std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
			divisor	: in std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
				
		--Outputs
			quotient	: out std_logic_vector (DIVIDEND_WIDTH - 1 downto 0);
			remainder: out std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
			overflow	: out std_logic
		);
end entity divider;

-- structural architecture for divider
architecture structural_combinational of divider is

-- Signals and components go here

	-- set the length of DATA_WIDTH to equal to DIVISOR_WIDTH
	constant DATA_WIDTH : natural := DIVISOR_WIDTH;
	
	-- components
	component comparator is
		generic(
					-- set the width for DATA_WIDTH
					DATA_WIDTH : natural := 4
		);
		
		port(
			-- inputs
			DINL 			: in std_logic_vector (DATA_WIDTH downto 0);
			DINR 			: in std_logic_vector (DATA_WIDTH - 1 downto 0);
			-- outputs
			DOUT 			: out std_logic_vector (DATA_WIDTH - 1 downto 0);
			isGreaterEq : out std_logic
		);
	end component comparator;
	
	
	-- types
	type short_array is array (0 to DIVIDEND_WIDTH) of std_logic_vector(DATA_WIDTH - 1 downto 0);
	type long_array is array (0 to (DIVIDEND_WIDTH - 1)) of std_logic_vector(DATA_WIDTH downto 0);
	
	-- initalize arrays to be used for storing comparators from dout_array to din_array and back to computing comparators
	
	-- signals
	signal dout_array : short_array;
	signal din_array 	: long_array;


-- structural design
begin

	dout_array(DIVIDEND_WIDTH) <= (others => '0');
	
	-- GENERATE Function that begins from counting downwards to 0
	compare_block : for i in (DIVIDEND_WIDTH - 1) downto 0 GENERATE
	-- concatenate dividend(i) to the end of dout_array(i + 1) and store into din_array
		din_array(i) <= dout_array(i + 1) & dividend(i);
			
	compare : comparator
		-- map DATA_WIDTH
		generic map (
						DATA_WIDTH => DATA_WIDTH
		)	
		-- map inputs/outports from component comparator to other signals/inputs/outputs of the entity divider
		port map (
					DINL			=> din_array(i),
					DINR			=> divisor,
					DOUT			=> dout_array(i),
					isGreaterEq	=> quotient(i)
		);
	end GENERATE;
	
	-- checking case for when start button is pressed as well as overflow
	START_PROCESS : process(start) is
	begin
		-- when start button is pressed continue
		if (rising_edge(start)) then
			
			-- if so, convert divisor to unsigned integer and if it's 0, then set overflow to 1
			if (to_integer(unsigned(divisor))) = 0 then
				overflow <= '1';
				remainder <= std_logic_vector(to_unsigned(0, DIVISOR_WIDTH));
			
			-- otherwise, set overflow to 0 and then remainder equal to the first instance of the dout_array
			else
				overflow <= '0';
				remainder <= dout_array(0);
			
			end if;
		end if;
	end process START_PROCESS;
			
end architecture structural_combinational;

-------------------------------------------------------------------

-- architecture for behavioral divider
architecture behavioral_sequential of divider is

	-- Components
	component comparator is 
		generic( 
			DATA_WIDTH	: natural := DIVISOR_WIDTH 
			); 
		port(
			--Inputs
			DINL			: in std_logic_vector (DATA_WIDTH downto 0);
			DINR			: in std_logic_vector (DATA_WIDTH - 1 downto 0);
			
			--Outputs
			DOUT			: out std_logic_vector (DATA_WIDTH - 1 downto 0);
			isGreaterEq	: out std_logic
		);
	end component comparator;
	
	--Signals
		signal DINL_sig		: std_logic_vector (DIVISOR_WIDTH downto 0);
		signal DINR_sig		: std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
		
		signal DOUT_sig		: std_logic_vector (DIVISOR_WIDTH - 1 downto 0);
		signal isGreaterEq_sig: std_logic;
		
		signal temp_int 		: integer;
		
	--Constants
		constant zeros_dividend : std_logic_vector(DIVIDEND_WIDTH - 1 downto 0) := (others => '0');
		constant zeros_divisor 	: std_logic_vector(DIVISOR_WIDTH - 1 downto 0) := (others => '0');

begin

	comp_process : comparator 
		port map (
					--Inputs
					DINL 			=> DINL_sig,
					DINR 			=> DINR_sig,
					
					--Outputs
					DOUT 			=> DOUT_sig,
					isGreaterEq => isGreaterEq_sig
				);
					
	-- begin process statement
	start_process : process(clk) is
	
		--Variables
		-- comparator variables --
		variable tempDINL			: std_logic_vector (DIVISOR_WIDTH downto 0) 		:= (others => '0');
		
		--divider variables--
		variable temp_result		: std_logic_vector(DIVISOR_WIDTH - 1 downto 0)	:= (others => '0');
		variable temp_input		: std_logic_vector(DIVISOR_WIDTH downto 0)		:= (others => '0');
		variable temp_quotient	: std_logic_vector(DIVIDEND_WIDTH - 1 downto 0) := (others => '0');

		variable temp_remainder	: std_logic_vector(DIVISOR_WIDTH - 1 downto 0);
		variable temp_dividend	: std_logic_vector(DIVIDEND_WIDTH - 1 downto 0);
		variable temp_index 		: integer := temp_int;

	begin
	
		-- set signals and variable
		DINL_sig			<= tempDINL;
		DINR_sig		 	<= divisor;
		quotient 		<= temp_quotient;
		temp_dividend 	:= dividend;
		remainder 		<= temp_remainder;
		temp_int 		<= temp_index;

		-- if rising edge on clock, proceed computation
		if rising_edge(clk) then
		
			-- assign index to a temp variable
			temp_index := temp_int;
			
			-- if start is high, then reset everything to 0
			if (start = '1') then
				temp_input := (others => '0');
				temp_result	:= zeros_divisor;
				temp_quotient := zeros_dividend;
				temp_index := DIVIDEND_WIDTH;
			end if;
			
			-- while temp index is greater than or equal to 0, continue below
			if (temp_index >= 0) then
				
				-- if temp is not dividend_width, then continue to perform computation
				if (temp_index /= DIVIDEND_WIDTH) then
					-- set DOUT value into temp_result and store that value by diffing left of temp_input
					temp_result := DOUT_sig;
					temp_input(temp_input'Left downto 1) := temp_result;
					temp_quotient(temp_index) := isGreaterEq_sig;
				end if;
				
				-- if temp is not 0, then have right side of temp_input become temp_dividend
				if (temp_index /= 0) then
					temp_input(temp_input'Right) := temp_dividend(temp_index - 1);
					tempDINL := temp_input;
				end if;
				
				-- if temp is 0, set remainder to get temp_result
				if (temp_index = 0) then
					temp_remainder := temp_result;
				end if;
				
				-- decrement temp index
				temp_index := temp_index - 1;

				-- if divisor is 0, set overflow to high and quotient becomes 0
				if ( divisor = zeros_divisor ) then
					overflow 		<= '1'; 
					temp_quotient 	:= zeros_dividend;
				else 
					overflow 		<= '0';
				end if;
				
			end if;
		end if;
	end process start_process;
end architecture behavioral_sequential;

--------------------------------------------------------------------------------

architecture fsm_behavior of divider is

		-- function of get_msb_pos
--	function get_msb_pos(data : std_logic_vector) return natural is 
--		variable temp : natural := 0;
--	begin
--		for i in data'low to data'high loop
--			if data(i) = '0' then
--				temp := temp;
--			elsif data(i) = '1' then
--				temp := i;
--			else 
--				temp := 0;
--			end if;
--		end loop;

--		return temp;

--	end function get_msb_pos;
	
	-- function of get_msb_pos using recursion 
	function get_msb_pos(data : std_logic_vector) return natural is 
		variable temp : natural := 0;
		variable upper, lower : std_logic_vector((data'length / 2 - 1) downto 0);
	begin
		case(data'length) is
			-- stop recursive call when there are 2 bits
			when 2 =>
				for i in data'low to data'high loop
					if data(i) = '0' then
						temp := temp;
					elsif data(i) = '1' then
						temp := i;
					else 
						temp := 0;
					end if;
				end loop;
			
			-- call function again recursively
			when OTHERS =>
				-- reassign the upper and lower boundaries
				upper := data(data'high downto data'length/2);
				lower := data((data'length/2 - 1) downto 0);
				
				-- if the first half is all 0, then find the msb of the lower half
				if (to_integer(unsigned(upper)) = 0) then
					temp := get_msb_pos(lower);
				-- otherwise recurse through the upper half if there is a 1 there
				else
					temp := get_msb_pos(upper) + data'length/2;
				end if;
		end case;
		
		return temp;
		
	end function get_msb_pos;
	
	-- Declare states, signals, and constants
	type state is (S0, S1, S2, S3);
	signal current_state, next_state : state;	
	
	signal dividend_temp, divisor_temp, quotient_temp, dividend_c, divisor_c, quotient_c  : std_logic_vector(DIVIDEND_WIDTH - 1 downto 0);
	signal overflow_temp, zero_temp, overflow_c, zero_c : std_logic;
	
	constant zeros_dividend : std_logic_vector(DIVIDEND_WIDTH - 1 downto 0) := (others => '0');
	constant zeros_divisor 	: std_logic_vector(DIVISOR_WIDTH - 1 downto 0) := (others => '0');
	
	signal dividend_int, divisor_int : integer;
	
begin	

	-- clock process
	clocked_process: process(clk, rst) is
	
	begin
	
		-- if reset is active low, then set default values for the temp signals
		if (rst = '0') then
			current_state 	<= S0;
			dividend_temp 	<= std_logic_vector(abs(signed(dividend)));
			divisor_temp 	<= std_logic_vector(resize(abs(signed(divisor)), DIVIDEND_WIDTH));
			quotient_temp 	<= zeros_dividend;
			overflow_temp 	<= '0';
			zero_temp		<= '0';
			
		-- otherwise begin operation by assigned the combinational signals and the next state
		elsif (rising_edge(clk)) then
			current_state 	<= next_state;
			dividend_temp 	<= dividend_c;
			divisor_temp 	<= divisor_c;
			quotient_temp 	<= quotient_c;
			overflow_temp 	<= overflow_c;
			zero_temp		<= zero_c;
		end if;
	end process clocked_process;
	
	-- asynchronous combinational process
	comb_process: process(dividend_temp, divisor_temp, quotient_temp, overflow_temp, zero_temp, start, current_state) is
	
		-- variables used for shifting to left and check for positive or negative numbers
		variable diff : natural;
		variable sign : std_logic;
		
	begin

		-- initalize signals and variables before moving to state method
		dividend_c 		<= dividend_temp;
		divisor_c 		<= divisor_temp;
		quotient_c 		<= quotient_temp;
		overflow_c 		<= overflow_temp;
		zero_c 			<= zero_temp;
		
		-- helper signals for conversion of integers
		dividend_int 	<= to_integer(unsigned(dividend_temp));
		divisor_int		<= to_integer(unsigned(divisor_temp));

		case (current_state) is
		
			-- first case when start is active low; move to next state and set signals accordingly
			when S0 =>
				if (start = '0') then
					next_state 	<= S1;
					dividend_c 	<= std_logic_vector(abs(signed(dividend)));
					divisor_c 	<= std_logic_vector(resize(abs(signed(divisor)), DIVIDEND_WIDTH));
					quotient_c 	<= zeros_dividend;
					overflow_c	<= '0';
					zero_c		<= '0';
					
					-- use xor command to see if either the dividend or divisor is negative
					-- if just one is negative, the quotient should be negative; otherwise it is positive
					sign := dividend(DIVIDEND_WIDTH - 1) xor divisor(DIVISOR_WIDTH - 1);
				else
					next_state 	<= S0;
				end if;

			-- next state if start test passes; check for conditional cases where divisor or dividend is 0 
			-- if so, move to state 3 for overflow or zero flag check
			when S1 =>
				if (divisor_int = 0) then
					next_state 		<= S3;
					overflow_c 	<= '1';
				elsif(dividend_int = 0) then
					next_state 		<= S3;
					zero_c 		<= '1';
				else
					next_state 		<= S2;
				end if;

			-- if divisor is not 0 and the dividend is greater than the divisor
			-- perform the operation one bit at a time until it reaches the end
			when S2 =>
				if (divisor_int /= 0 and (unsigned(dividend_temp) >= unsigned(divisor_temp))) then
				
					-- basically a loop that continues over and over; use the function to get msb
					next_state 	<= S2;
					diff 			:= get_msb_pos(dividend_temp) - get_msb_pos(divisor_temp);	
					
					-- if shifted divisor is greater than dividend, decrement shift by one; otherwise let it stay the same
					if ((unsigned(divisor_temp) SLL diff) > unsigned(dividend_temp)) then
						diff 		:= diff - 1;
					else
						diff 		:= diff;
					end if;
					
					-- after computation, store into quotient and dividend signals respectively
					quotient_c <= std_logic_vector(unsigned(quotient_temp) + (to_unsigned(1, quotient_temp'length) SLL diff));
					dividend_c <= std_logic_vector(unsigned(dividend_temp) - (unsigned(divisor_temp) SLL diff));
				else
					next_state <= S3;
				end if;
			
			-- conditional check for overflow or zero; 
			when S3 =>
			
				-- if either overflow or zero is 1, set quotient and remainder to be 0 and return to state 0
				if (overflow_temp = '1') then
					quotient 	<= zeros_dividend;
					remainder 	<= zeros_divisor;
					overflow 	<= '1';
					next_state 	<= S0;
					
				elsif (zero_temp = '1') then
					quotient 	<= zeros_dividend;
					remainder 	<= zeros_divisor;
					overflow 	<= '0';
					next_state 	<= S0;
					
				-- if neither overflow or zero is 1, check if a number is negative
				else
					overflow 	<= '0';
					next_state 	<= S0;
					
					-- if so, covert to two's complement
					if (sign = '1') then
						quotient <= std_logic_vector(not(unsigned(quotient_temp)) + 1);
					else
						quotient <= quotient_temp;
					end if;
					
					if ((dividend(DIVIDEND_WIDTH - 1)) = '1') then
						remainder <= std_logic_vector(not(resize(unsigned(dividend_temp), remainder'length)) + 1);
					else
						remainder <= std_logic_vector(resize(unsigned(dividend_temp), remainder'length));
					end if;	
				end if;
				
			-- for any other case or situation, just start back at state 0
			when OTHERS =>
				next_state		<= S0;
				
		end case; 
	end process comb_process;
	
end architecture fsm_behavior;