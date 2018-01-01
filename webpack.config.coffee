# output.pathに絶対パスを指定する必要があるため、pathモジュールを読み込んでおく
path = require "path"
webpack = require "webpack"

module.exports = {
  # エントリーポイントの設定
  entry: './src/main.coffee'
  # 出力の設定
  output:
    # 出力するファイル名
    filename: 'BrownianMotion.js'
    # 出力先のパス（v2系以降は絶対パスを指定する必要がある）
    path: path.resolve(__dirname, 'public/js')
  module:
    # coffeescriptはtranscompileしておく
    rules: [
      {
        test: /\.coffee$/
        loader: 'babel-loader!coffeescript-loader'
      }
    ]
  externals: [
    {
      Three: 'three'
      jQuery: 'jQuery'
      datGUI: 'dat.gui'
    }
  ]
}
