const assert = require('assert');

console.log('Running tests...');

// Basic sanity test
assert.strictEqual(1 + 1, 2, 'Math should work');

// Check that app module loads
const app = require('./index.js');
assert.ok(app, 'App should export');

console.log('All tests passed!');
process.exit(0);
