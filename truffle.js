var DefaultBuilder = require("truffle-default-builder");

module.exports = {
  build: new DefaultBuilder({
    "index.html": "index.html",
    "app.js": [
      "javascripts/app.js"
    ],
    "app.css": [
      "stylesheets/app.css"
    ],
    "images/": "images/"
  }),
  networks:{
    development : {
      host: "localhost",
      port: 8545,
      gasPrice: 2e10,
      network_id: "*"
    },
    rpc: {
      host: "localhost",
      port: 8545,
      gasPrice: 2e10  // keep in sync with test/utils/consts.js
    }
  }
};
