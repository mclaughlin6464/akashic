pragma solidity ^0.4.19;

contract owned{
	address public owner;

	function owned() public {
		owner = msg.sender;
	}

	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address newOwner) onlyOwner public {
		owner = newOwner;
	}
	// keep this here during dev
	function kill() public{
		if (msg.sender == owner) selfdestruct(owner);
	}
}

contract akashic is owned{
	uint depositAmountInWei;
	mapping (address => Researcher) researchers;
	mapping (uint256 => Hypothesis) hypotheses;

	struct Hypothesis {
		address researcher; //should be private
		uint timeCreated;
		bool published;
		string name; //should be private
	}

	struct Researcher {
		//string name
		uint256[] hypothesisAddresses;
		uint256 nHypotheses; 
	}

	function akashic(uint depositAmountInEther)public {
		depositAmountInWei = depositAmountInEther* 1 ether;
	}	

	function newHypothesis(uint256 hypothesisHash, string name) public payable returns (string){
		require(msg.value == depositAmountInWei);// if the deposit is wrong, don't proceed
		return "Hello";
		Hypothesis storage _newHypothesis;
		_newHypothesis.timeCreated = now;
		_newHypothesis.name = name;
		_newHypothesis.published = false;
		hypotheses[hypothesisHash] = _newHypothesis;	
		// add this to the researcher.
		Researcher storage researcher = researchers[msg.sender];
		researcher.hypothesisAddresses[researcher.nHypotheses++] = hypothesisHash;
	}
	function publishHypothesis(uint256 hypothesisHash) public {
		require(msg.sender == owner); // would like to have a list of valid owners
		hypotheses[hypothesisHash].published=true;
		hypotheses[hypothesisHash].researcher.transfer(depositAmountInWei); // return to the researcher
	}
	function getDate(uint256 hypothesisHash)public view returns (uint){
		return hypotheses[hypothesisHash].timeCreated; // probably can convert to a real date
	}

	function isPublished(uint256 hypothesisHash)public view returns (bool){
		return hypotheses[hypothesisHash].published; 
	}
	// TODO can I return a struct? 
	function getNHypotheses() public view returns (uint){
		return researchers[msg.sender].nHypotheses;
	}
	function getHypothesisAddress(uint idx) public view returns (uint256){
		require(idx<researchers[msg.sender].nHypotheses);
		return researchers[msg.sender].hypothesisAddresses[idx];
	}
}
