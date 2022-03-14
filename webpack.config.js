const path = require('path');
const { WebpackManifestPlugin } = require('webpack-manifest-plugin');
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

module.exports = {
  mode: process.env['BUILD_ENV'] || 'production',
  entry: {
  },
  output: {
    filename: '[name].[contenthash:7].js',
    path: path.resolve(__dirname, './public/assets/'),
    publicPath: '/assets'
  },
  module: {
    rules: [
      {
        test: /\.css$/i,
        use: [
          MiniCssExtractPlugin.loader,
          "css-loader"
        ],
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: '[name].[contenthash:7].css'
    }),
    new WebpackManifestPlugin()
  ]
};