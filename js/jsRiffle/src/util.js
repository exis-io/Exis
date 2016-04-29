var assert = function (cond, text) {
	if (cond) {
      return;
   }
	if (assert.useDebugger || ('RIFFLE_DEBUG' in global && RIFFLE_DEBUG)) {
      debugger;
   }

	throw new Error(text || "Assertion failed!");
};

exports.assert = assert;
