const { ethers, run, network } = require("hardhat");
const { keccak256 } = require("@ethersproject/keccak256");
const { toUtf8Bytes } = require("@ethersproject/strings");

async function main() {
  const issueCredentialFactory = await ethers.getContractFactory("IssueCred");
  console.log("deploying contract...");

  const issueCredential = await issueCredentialFactory.deploy();
  await issueCredential.waitForDeployment();
  const contractAddress = await issueCredential.getAddress();
  console.log(`Deployed contract to ${contractAddress}`);
  if (network.config.chainId === 11155111 && process.env.ETHERSCAN) {
    await issueCredential.deploymentTransaction().wait(6);
    await verify(contractAddress, []);
  }

  const doctorRole = keccak256(toUtf8Bytes("DOCTOR_ROLE"));

  const txnResponse = await issueCredential.registerProvider(
    "0xF412C7cB7C70173A935e2F7832ab2d0939a7ABC9",
    "Gargi Bendale",
    "123",
    doctorRole
  );

  await txnResponse.wait(1);

  registeredProviders = await issueCredential.getRegisteredProviders();
  console.log(registeredProviders);
}

async function verify(contractAddress, args) {
  console.log("verifying contract...");
  try {
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: args,
    });
  } catch (e) {
    if (e.message.toLowerCase().includes("already verified")) {
      console.log("Already Verified !");
    } else {
      console.log(e);
    }
  }
}

//main
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
