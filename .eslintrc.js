module.exports = {
	"root": true,
	"env": {
		// Using 2017 since 2019 isn't accepted. I suppose that's
		// because no globals have been added to 2019 w.r.t 2017.
		"es2017": true,
		"node": true
	},
	"globals": {
		"Atomics": "readonly",
		"SharedArrayBuffer": "readonly"
	},
	"parserOptions": {
		"ecmaVersion": 2019
	},
	"extends": "eslint:recommended",
	"rules": {
		"no-extra-parens": "warn",
		"semi": "warn",
		"camelcase": ["warn", { "properties": "always", "genericType": "always" }],
		"brace-style": ["warn", "allman", { "allowSingleLine": true }],
		"quotes": ["warn", "single", { "avoidEscape": true, "allowTemplateLiterals": true }]
	}
};
