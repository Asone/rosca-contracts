module.exports = function(deployer) {
    var now = Math.round(new Date().getTime()/1000);
    deployer.deploy(ROSCAtest, 5, "10000000000", 2, now + 1 , 20);
};

