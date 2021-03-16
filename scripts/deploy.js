const main = async () => {
    const [deployer] = await ethers.getSigners();

    var deployerLog = { Label: "Deploying Address", Info: deployer.address };

    var deployerBalanceLog = {
        Label: "Deployer Ether Balance",
        Info: (await deployer.getBalance()).toString()
    };

    let bondedTokenInfo, bondedTokenInstance;
    let collateralTokenInfo, collateralTokenInstance;
    let CurveInfo, curveInstance;

    bondedTokenInfo = await ethers.getContractFactory("BondedToken");
    collateralTokenInfo = await ethers.getContractFactory("CollateralToken");
    CurveInfo = await ethers.getContractFactory("Curve");

    bondedTokenInstance = await bondedTokenInfo.deploy(
        "Epic Bonded Token",
        "EBT"
    );
    collateralTokenInstance = await collateralTokenInfo.deploy(
        "Awesome Token Collateral",
        "ATC"
    );
    curveInstance = await CurveInfo.deploy(
        bondedTokenInstance.address,
        collateralTokenInstance.address
    );

    await bondedTokenInstance.addMinter(curveInstance.address);
    await curveInstance.initialised();

    var bondTokenLog = { Label: "Deployed Bonded Token Address", Info: bondedTokenInstance.address };
    var collTokenLog = { Label: "Deployed Collateral Token Address", Info: collateralTokenInstance.address };
    var curveLog = { Label: "Deployed Curve Address", Info: curveInstance.address };

    console.table([deployerLog, deployerBalanceLog, bondTokenLog, collTokenLog, curveLog]);
}
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });