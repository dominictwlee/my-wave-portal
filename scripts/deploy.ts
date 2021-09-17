import { ethers } from "hardhat";

(async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("account balance:", (await deployer.getBalance()).toString());

  const waveContractFactory = await ethers.getContractFactory("WavePortal");
  const waveContract = await waveContractFactory.deploy({ value: ethers.utils.parseEther("0.1") });
  await waveContract.deployed();

  console.log("WavePortal address:", waveContract.address);
})()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
