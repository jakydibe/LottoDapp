// scripts/deploy.js
async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // Deploy del contratto Lottery con placeholder per l'oracolo
  const Lottery = await ethers.getContractFactory("Lottery");
  const lottery = await Lottery.deploy("0x0000000000000000000000000000000000000000");
  await lottery.waitForDeployment();
  console.log("Lottery deployed to:", lottery.target);

  // Deploy del contratto Oracle, passando l'indirizzo del contratto Lottery
  const Oracle = await ethers.getContractFactory("Oracle");
  const oracle = await Oracle.deploy(lottery.target);
  await oracle.waitForDeployment();
  console.log("Oracle deployed to:", oracle.target);

  // Aggiorna l'indirizzo dell'oracolo nel contratto Lottery
  const tx = await lottery.setOracle(oracle.target);
  await tx.wait();
  console.log("Lottery oracle address set to:", oracle.target);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error("Errore durante il deploy:", error);
    process.exit(1);
  });
