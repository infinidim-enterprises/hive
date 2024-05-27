const fs = require("fs");
const vm = require("vm");
const path = require("path");

function user_pref(name, value) {
  preferences[name] = value;
}

const inputFilePath = path.resolve(__dirname, "user.js");
const outputFilePath = path.resolve(__dirname, "prefs.json");

const preferences = {};

const userJsContent = fs.readFileSync(inputFilePath, "utf8");

const script = new vm.Script(userJsContent);
const context = vm.createContext({ user_pref, preferences });
script.runInContext(context);

fs.writeFileSync(outputFilePath, JSON.stringify(preferences, null, 2));
