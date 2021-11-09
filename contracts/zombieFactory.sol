pragma solidity ^0.5.12;

import "./ownable.sol";
import "./safemath.sol";

contract ZombieFactory is Ownable {

  using SafeMath for uint256;

  event NewZombie(uint zombieId, string name, uint dna);

  uint dnaDigits = 16;
  uint dnaModulus = 10 ** dnaDigits;
  uint public cooldownTime = 1 days;    
  uint public zombiePrice = 0.01 ether; //僵尸默认价格
  uint public zombieCount = 0; //僵尸总数量
  struct Zombie {
    string name;
    uint dna; //随机数
    uint16 winCount;
    uint16 lossCount;
    uint32 level;
    uint32 readyTime;
  }

  Zombie[] public zombies;
  //自己拥有的僵尸
  mapping (uint => address) public zombieToOwner;
  //拥有僵尸的数量
  mapping (address => uint) ownerZombieCount;
  mapping (uint => uint) public zombieFeedTimes;

  function _createZombie(string memory _name, uint _dna) internal {
    uint id = zombies.push(Zombie(_name, _dna, 0, 0, 1, 0)) - 1;
    //储存地址
    zombieToOwner[id] = msg.sender; 
    //保存拥有僵尸的数量
    ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);

    zombieCount = zombieCount.add(1);
    emit NewZombie(id, _name, _dna);
  }
  //获取随机数
  function _generateRandomDna(string memory _str) private view returns (uint) {
    return uint(keccak256(abi.encodePacked(_str,now))) % dnaModulus;
  }

  //创建僵尸
  function createZombie(string memory _name) public{
    //一个地址只能创建一个僵尸
    require(ownerZombieCount[msg.sender] == 0);
    uint randDna = _generateRandomDna(_name);
    randDna = randDna - randDna % 10;
    _createZombie(_name, randDna);
  }

  //购买僵尸
  function buyZombie(string memory _name) public payable{
    require(ownerZombieCount[msg.sender] > 0);
    require(msg.value >= zombiePrice);
    uint randDna = _generateRandomDna(_name);
    randDna = randDna - randDna % 10 + 1;
    _createZombie(_name, randDna);
  }

 //设置僵尸价格
  function setZombiePrice(uint _price) external onlyOwner {
    zombiePrice = _price;
  }

}
