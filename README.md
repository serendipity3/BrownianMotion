# BrownianMotion.js
javascript for a physics simulation of Brownian motion using Three.js and jQuery via Node.js + Webpack (and coffeescript2 w/ babel)

+ node.js v8.9.0

## Usage
See `public/index.html`.

## For Developers
Fist, type `npm i -s` and then
+ `npm run server`: you can access http://localhost:8000/
+ `npm run webpack`: `webpack --watch --config ./webpack.config.coffee`
+ `npm start`: `concurrently \"npm run server\" \"npm run webpack\"`
