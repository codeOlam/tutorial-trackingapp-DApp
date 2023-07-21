import hre, { ethers } from "hardhat";

async function main() {
  // const currentTimestampInSeconds = Math.round(Date.now() / 1000);
  // const unlockTime = currentTimestampInSeconds + 60;

  // const lockedAmount = ethers.parseEther("0.001");
  const Tracking = await hre.ethers.getContractFactory("Tracking");
  const tracking = Tracking.deploy();
  // const Tracking = await ethers.getContractFactory("Tracking");

  // const tracking = await ethers.deployContract("Tracking", [unlockTime], {
  //   value: lockedAmount,
  // });

  // await tracking.waitForDeployment();

  console.log(`Tracking deployed to ${(await tracking).target}, using target`);
  console.log(`Tracking deployed to ${(await tracking).getAddress()}, using getAddress method`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
