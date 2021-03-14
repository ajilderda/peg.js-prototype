const Path = require('path');
const Webpack = require('webpack');
const merge = require('webpack-merge');
const common = require('./webpack.common.js');

module.exports = merge(common, {
  mode: 'production',
  // devtool: 'source-map',
  // stats: 'errors-only',
  bail: true,
  output: {
    filename: () => {
      const d = new Date();
      const year = d.getFullYear();
      const month = ("0" + (d.getMonth() + 1)).slice(-2);
      const day = ("0" + d.getDate()).slice(-2);
      const hours = ("0" + (d.getHours())).slice(-2);
      const minutes = ("0" + (d.getMinutes())).slice(-2);
      const dateToday = `${year}${month}${day}`;
      const currentTime = `${hours}${minutes}`;
      return `js/[name].${dateToday}${currentTime}.js`;
    },
    // uncomment to seperate scripts into separate chunks
    // chunkFilename: 'js/[name].[chunkhash:8].chunk.js'
  },
  plugins: [
    new Webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify('production')
    })
  ],
  module: {
    rules: [
      {
        test: /\.js$/,
        include: Path.resolve(__dirname, '../src'),
        enforce: 'pre',
        loader: 'eslint-loader',
        options: {
          emitWarning: true,
          configFile: 'eslint/eslint.config.prod.js'
        }
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: 'babel-loader'
      },
      {
        test: /\.s?css/i,
        use: [
          // uncomment loader below if you want to build the css into a seperate file
          // MiniCssExtractPlugin.loader,
          'css-loader?sourceMap=false',
          'sass-loader'
        ]
      }
    ]
  }
});
