var htmlWebpackPlugin = require('html-webpack-plugin')
var path = require('path')

var jsDir = 'src/main/js/'
var staticDir = 'src/main/static/'
var webDir = 'src/main/resources/web/'
var frontEndStaticDir = 'static/'

module.exports = {
  entry: [
    path.join(__dirname, jsDir, 'index.js'),
  ],
  module: {
    loaders: [
      { test: /\.jsx?$/,
        loader: "babel-loader",
        exclude: /node_modules/,
        query: {
          presets: [
            'es2015',
            'react',
            'stage-1',
          ],
        },
      },
      //{ test: new RegExp(staticDir),
      //  exclude: path.join(staticDir, "index.html"),
      //  loader: "file?name=[path][name].[ext]&context=" + path.join(webDir, frontEndStaticDir),
      //},
    ],
  },
  output: {
    filename: path.join(frontEndStaticDir, "index.js"),
    path: path.join(__dirname, webDir),
  },

  plugins: [
    new htmlWebpackPlugin({
      title: 'Ben Pence\'s Blog',
      template: path.join(__dirname, staticDir, 'index.html'),
      filename: path.join(__dirname, webDir, 'index.html'),
      inject: 'body',
    }),
  ]
}
