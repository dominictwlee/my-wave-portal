import { ethers } from "hardhat";

(async function main() {
  const [owner, randoPerson] = await ethers.getSigners();
  const waveContractFactory = await ethers.getContractFactory("WavePortal");
  const waveContract = await waveContractFactory.deploy({ value: ethers.utils.parseEther("0.1") });
  await waveContract.deployed();
  console.log("Contract deployed to:", waveContract.address);
  console.log("Contract deployed by:", owner.address);

  let contractBalance = await ethers.provider.getBalance(waveContract.address);
  console.log("Contract balance:", ethers.utils.formatEther(contractBalance));

  let waveTransaction = await waveContract.wave("Wave 1");
  await waveTransaction.wait();

  waveTransaction = await waveContract.connect(randoPerson).wave("Wave 2");
  await waveTransaction.wait();

  contractBalance = await ethers.provider.getBalance(waveContract.address);
  console.log("Contract balance:", ethers.utils.formatEther(contractBalance));
})()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
