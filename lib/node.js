// Generated by LispyScript v0.2.5
require("amd-loader");
var fs = require("fs");
var ls = require("../lib/ls");
global.define = function() {
    var factory = Array.prototype.slice.call(arguments,-1);
    return factory(require,exports,module);
};
require.extensions[".ls"] = function(module,filename) {
    var code = fs.readFileSync(filename,"utf8");
    return module._compile(ls._compile(code,filename),filename);
};
require("../src/macros");
