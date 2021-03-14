module.exports = {
  'parser': 'babel-eslint',
  'extends': 'airbnb-base',
  'env': {
    'browser': true,
    'node': true
  },
  'globals': {
    '_st': 'readonly',
    'nsDataQueue': 'readonly',
    'cro': 'readonly',
  },
  'parserOptions': {
    'ecmaVersion': 2018,
    'sourceType': 'module'
  },
  'rules': {
    'curly': 'error',
    'func-names': 0,
    'no-param-reassign': [2, {
        'props': false
    }],
    'consistent-return': 'off',
    'class-methods-use-this': 'off',
    'max-len': ['error', 130, 2, {
      'ignoreUrls': true,
      'ignoreComments': false,
      'ignoreRegExpLiterals': true,
      'ignoreStrings': true,
      'ignoreTemplateLiterals': true,
    }],
    'brace-style': [2, 'stroustrup', { 'allowSingleLine': true }],
    // Workaround for ESLint failing to parse files with template literals
    // with this error: 'TypeError: Cannot read property 'range' of null'.
    // Might want to revert rules below when dependencies have been fixed.
    'template-curly-spacing': 'off',
    'indent' : 'off',
    // 'indent': ['error', 4],
  }
}
