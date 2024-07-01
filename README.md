Write 2 cotracts, contract A and contract B.

### Part 1

**Contract A**
- Has a increment method and a getter
- The increment is only callable by contract B

**Contract B**
- It has an increment_A method that is used to increment the counter in A
- It has a get_a_in_b that calls the getter in A and returns it


Write tests in starknet foundry that
- Call increment_A and gettter in B to check that the value has incremented
- Use proper interfaces to be used in the contracts and import them to call each other

### Part 2
- Make both contracts upgradeable
- use OZ upgradeable component in one and low level syscall in other to manage the upgradeablility
- In contract 2 
	- add new storage variable called total_handshakes
	- add a new function handshake() that first calls the 
		- get_a_in_b() 
		- increment_a()
		- get_a_in_b()
		and checks if proper increment happened, if yes then increments the total_handshakes variable in b
