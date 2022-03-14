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
        test: /\.m?js$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader",
          options: {
            presets: ['@babel/preset-env']
          }
        }
      },
      {
        test: /\.css$/i,
        use: [
          MiniCssExtractPlugin.loader,
          "css-loader"
        ],
      },
      {
        test: /\.styl$/i,
        use: [
          MiniCssExtractPlugin.loader,
          "css-loader",
          {
            loader: "stylus-loader",
          }
        ]
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