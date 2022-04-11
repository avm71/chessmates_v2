
const hre = require("hardhat");

async function main() {

  const ChessMates = await hre.ethers.getContractFactory("ChessMates");
  const chessMates = await ChessMates.deploy();

  await chessMates.deployed();

  console.log("ChessMates deployed to:", chessMates.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
