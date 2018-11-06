
var path = require('path');
const CopyWebpackPlugin = require('copy-webpack-plugin');
const FileManagerPlugin = require('filemanager-webpack-plugin');

module.exports = {
  entry: './src/app.js',
  output: {
    path: path.join(__dirname, 'dist'),
    filename: 'populations.js',
    library: 'Populations',
    libraryTarget: 'umd',
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /(node_modules|bower_components)/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env']
          }
        }
      },
      {
        test: /\.(png|jpg)$/,
        loader: 'url-loader',
        query: {
          limit: 8192
        }
      },
      {
        test: /\.styl$/,
        loader: 'style-loader!css-loader!stylus-loader?paths=node_modules/bootstrap-stylus/stylus/',
        include: path.join(__dirname, 'src', 'styles')
      }
    ]
  },
  plugins: [
    new CopyWebpackPlugin([
      {
        from: 'src/populations.d.ts',
        toType: 'file'
      },
      {
        from: 'examples/',
        to: '../public',
        toType: 'dir'
      }
    ], {}),
    new FileManagerPlugin({
      onEnd: {
        copy: [
          {
            source: 'dist/populations.js',
            destination: 'public/lib/populations.js'
          }
        ]
      }
    })
  ]
};