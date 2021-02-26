// The deployment script
const main = async () => {
    // Getting the first signer as the deployer
    const [deployer] = await ethers.getSigners();
    // Saving the info to be logged in the table (deployer address)
    var deployerLog = { Label: "Deploying Address", Info: deployer.address };
    // Saving the info to be logged in the table (deployer address)
    var deployerBalanceLog = { 
        Label: "Deployer ETH Balance", 
        Info: (await deployer.getBalance()).toString() 
    };

    let bondedTokenInfo, bondedTokenInstance;
    let collateralTokenInfo, collateralTokenInstance;
    let curveInfo, curveInstance;

    // Gets the abi, bytecode & name of the contracts
    bondedTokenInfo = await ethers.getContractFactory("BondedToken");
    collateralTokenInfo = await ethers.getContractFactory("CollateralToken");
    curveInfo = await ethers.getContractFactory("Curve");
    // Deploys the contracts
    bondedTokenInstance = await bondedTokenInfo.deploy(
        "Awesome Token Collateral",
        "ATC"
    );
    collateralTokenInstance = await collateralTokenInfo.deploy(
        "Epic Bonded Token",
        "EBT"
    );
    curveInstance = await curveInfo.deploy(
        bondedTokenInstance.address,
        collateralTokenInstance.address
    );
    // Setting the curve as a minter and initialising it 
    await bondedTokenInstance.addMinter(curveInstance.address);
    await curveInstance.init();
    // Saving the info to be logged in the table (deployer address)
    var bondTokenLog = { Label: "Deployed Bonded Token Address", Info: bondedTokenInstance.address };
    var collTokenLog = { Label: "Deployed Collateral Token Address", Info: collateralTokenInstance.address };
    var curveLog = { Label: "Deployed Curve Address", Info: curveInstance.address };

    console.table([deployerLog, deployerBalanceLog, bondTokenLog, collTokenLog, curveLog]);
}
// Runs the deployment script, catching any errors
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
  });