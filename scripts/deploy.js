const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // ✅ Check balance before deploying
  const balance = await deployer.getBalance();
  console.log("Deployer balance:", hre.ethers.utils.formatEther(balance), "ETH");

  if (balance.lt(hre.ethers.utils.parseEther("0.01"))) {
    throw new Error("❌ Insufficient funds! Fund your wallet with OpenCampus tokens.");
  }

  // ✅ Deploy AchoToken (ERC-20)
  const initialSupply = hre.ethers.utils.parseUnits("1000000", 18); // 1M ACHO Tokens
  const AchoToken = await hre.ethers.getContractFactory("AchoToken");
  const achoToken = await AchoToken.deploy(initialSupply, deployer.address);

  await achoToken.deployed(); // ✅ FIX: Use `.deployed()` instead of `.waitForDeployment()`
  console.log("✅ AchoToken deployed to:", achoToken.address);

  // ✅ Deploy AchoAdPayments
  const platformWallet = deployer.address;
  const AchoAdPayments = await hre.ethers.getContractFactory("AchoAdPayments");
  const achoAdPayments = await AchoAdPayments.deploy(achoToken.address, platformWallet, deployer.address);

  await achoAdPayments.deployed(); // ✅ FIX: Use `.deployed()` instead of `.waitForDeployment()`
  console.log("✅ AchoAdPayments deployed to:", achoAdPayments.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
