/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, {
/******/ 				configurable: false,
/******/ 				enumerable: true,
/******/ 				get: getter
/******/ 			});
/******/ 		}
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


// THREE = require "three"
var $, main, molecules;

molecules = __webpack_require__(1);

$ = __webpack_require__(2);

main = function main() {
  var _animate, aspect, bathT, camera, canvas, canvasDOM, canvasID, canvasThree, center, d0, dMax, dim, directionalLight, displayLenght, dt, elementID, geometry, getTemperature, gridHelper, halfN, height, i, k, label, margin, material, n, origin, particle, particleNumber, particleThree, position, positionThree, realLength, ref, remap, renderer, resize, scale, scene, sgm, sqrtN, t, v0, width;
  // init renderer {{{
  canvasID = 'canvas';
  canvasDOM = document.getElementById(canvasID);
  height = (canvasDOM.currentStyle || document.defaultView.getComputedStyle(canvasDOM, '')).height;
  width = (canvasDOM.currentStyle || document.defaultView.getComputedStyle(canvasDOM, '')).width;
  height = parseInt(height, 10);
  width = parseInt(width, 10);
  //    height = window.innerHeight
  //    width = window.innerWidth
  renderer = new THREE.WebGLRenderer();
  renderer.setSize(width, height);
  renderer.setClearColor(0xcccccc, 1.0);
  canvasDOM.appendChild(renderer.domElement);
  // }}}

  // init camera {{{
  // display (x,y)-point of BrownianMotion
  d0 = [0, 1].fill(0);
  dMax = [width, height];
  center = [width / 2, height / 2];
  aspect = width / height;
  camera = new THREE.OrthographicCamera(-width / 2, width / 2, -height / 2, height / 2, 0.01, 100);
  camera.position.set(center[0], center[1], -10);
  camera.up.set(0, -1, 0);
  camera.lookAt(center[0], center[1], 0);
  // }}}

  // init scene {{{
  scene = new THREE.Scene();
  // add DirectionalLight {{{
  directionalLight = new THREE.DirectionalLight(0xffffff, 1);
  directionalLight.position.set(0, 0, 10);
  directionalLight.lookAt(new THREE.Vector3(0, 0, 0));
  scene.add(directionalLight);
  // }}}
  // add gridHelper {{{
  gridHelper = new THREE.GridHelper(2 * width, 40); //  引数(size, divisions)
  scene.add(gridHelper);
  gridHelper.rotation.x = Math.PI / 2;
  // }}}
  //    # add axesHelper {{{
  //    axesHelper = new THREE.AxesHelper()
  //    scene.add(axesHelper)
  //    # }}}
  // }}}
  dim = 2;
  n = width / 20;
  displayLenght = 10 * n;
  sgm = molecules.parameters[1][4];
  realLength = 6e1 * sgm;
  scale = displayLenght / realLength;
  canvasThree = [displayLenght, Math.floor(displayLenght * aspect)];
  canvas = [realLength, realLength * aspect];
  bathT = 300e0;
  dt = 15e0 * molecules.FS;
  v0 = 4e2;
  elementID = 2;
  particleNumber = 400;
  // add particle {{{
  // resize real -> Three
  resize = function resize(_r) {
    var dr;
    return dr = Math.floor(_r * scale);
  };
  // remap real -> Three
  remap = function remap(_q) {
    var dq, i, k, ref;
    dq = [];
    for (i = k = 0, ref = dim - 1; 0 <= ref ? k <= ref : k >= ref; i = 0 <= ref ? ++k : --k) {
      dq[i] = Math.floor(dMax[i] / canvas[i] * _q[i]);
    }
    return dq;
  };
  particle = [];
  particleThree = [];
  label = [];
  origin = $('div#canvas').offset();
  margin = 3;
  sqrtN = Math.sqrt(particleNumber) + 1;
  for (i = k = 0, ref = particleNumber - 1; 0 <= ref ? k <= ref : k >= ref; i = 0 <= ref ? ++k : --k) {
    position = [Math.floor(i % sqrtN) * canvas[0] / sqrtN + sgm, Math.floor(i / sqrtN) * canvas[1] / sqrtN + sgm];
    particle[i] = new molecules.Molecules(elementID, dim, position, v0);
    geometry = new THREE.CircleGeometry(resize(particle[i].radius), 32);
    material = new THREE.MeshPhongMaterial();
    material.color.setHex(parseInt(particle[i].color, 16));
    particleThree[i] = new THREE.Mesh(geometry, material);
    positionThree = remap(particle[i].position);
    if (dim === 2) {
      positionThree.push(0);
    }
    particleThree[i].position.set(positionThree[0], positionThree[1], positionThree[2]);
    scene.add(particleThree[i]);
  }
  //        label[i] = $('<span id="label#'+i+'">'+i+'</span>').appendTo('div#canvas')
  //        label[i].offset( (j,r) -> {top: origin["top"]+height-positionThree[1], left: origin["left"]+positionThree[0]} )
  i = particleNumber;
  halfN = Math.floor(particleNumber / 2);
  position = [particle[halfN].position[0] + 5e-1 * (canvas[0] / sqrtN), particle[halfN].position[0] + 5e-1 * (canvas[1] / sqrtN)];
  particle[i] = new molecules.Molecules(9, dim, position, v0);
  geometry = new THREE.CircleGeometry(resize(particle[i].radius), 32);
  material = new THREE.MeshPhongMaterial();
  material.color.setHex(parseInt(particle[i].color, 16));
  particleThree[i] = new THREE.Mesh(geometry, material);
  positionThree = remap(particle[i].position);
  if (dim === 2) {
    positionThree.push(0);
  }
  particleThree[i].position.set(positionThree[0], positionThree[1], positionThree[2]);
  scene.add(particleThree[i]);
  //    label[i] = $('<span id="label#'+i+'">'+i+'</span>').appendTo('div#canvas')
  //    label[i].offset( (j,r) -> {top: origin["top"]+height-positionThree[1], left: origin["left"]+positionThree[0]} )

  // }}}
  getTemperature = function getTemperature() {
    var KE, l, ref1;
    KE = 0;
    for (i = l = 0, ref1 = particleNumber; 0 <= ref1 ? l <= ref1 : l >= ref1; i = 0 <= ref1 ? ++l : --l) {
      KE += particle[i].getEnergy();
    }
    return KE = KE / particleNumber / molecules.KB;
  };
  t = 0e0;
  _animate = function animate() {
    // {{{
    var T, Tr, j, l, m, o, p, q, r, ref1, ref2, ref3, ref4, ref5, ref6, s, temperature;
    $(function () {
      return $('#time').text("t = " + (t * 1e9).toFixed(3) + " ns");
    });
    temperature = getTemperature();
    $(function () {
      return $('#energy').text("KE = " + temperature.toFixed(1) + " K");
    });
    for (p = l = 0; l <= 10; p = ++l) {
      t += dt;
      for (i = m = 0, ref1 = particleNumber; 0 <= ref1 ? m <= ref1 : m >= ref1; i = 0 <= ref1 ? ++m : --m) {
        particle[i].force.fill(0);
      }
      for (i = o = 0, ref2 = particleNumber; 0 <= ref2 ? o <= ref2 : o >= ref2; i = 0 <= ref2 ? ++o : --o) {
        for (j = q = ref3 = i + 1, ref4 = particleNumber; ref3 <= ref4 ? q <= ref4 : q >= ref4; j = ref3 <= ref4 ? ++q : --q) {
          if (j > particleNumber) {
            break;
          }
          particle[j].getForce(particle[i]);
        }
      }
      T = getTemperature();
      Tr = Math.sqrt(bathT / T);
      if (Tr < 5e-1) {
        Tr = 5e-1;
      } else if (Tr > 1.2e0) {
        Tr = 1.2e0;
      }
      for (i = r = 0, ref5 = particleNumber; 0 <= ref5 ? r <= ref5 : r >= ref5; i = 0 <= ref5 ? ++r : --r) {
        particle[i].move(dt, canvas, Tr);
      }
    }
    for (i = s = 0, ref6 = particleNumber; 0 <= ref6 ? s <= ref6 : s >= ref6; i = 0 <= ref6 ? ++s : --s) {
      positionThree = remap(particle[i].position);
      if (dim === 2) {
        positionThree.push(0);
      }
      particleThree[i].position.set(positionThree[0], positionThree[1], positionThree[2]);
    }
    //            label[i].offset( (j,r) -> {
    //                top: origin["top"]+height+margin-positionThree[1]
    //                left: origin["left"]+margin+positionThree[0]
    //            } )
    requestAnimationFrame(_animate);
    return renderer.render(scene, camera);
  };
  //   }}}
  return _animate();
};

main();

/***/ }),
/* 1 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

// parameters {{{
// Physical parameters {{{
// proton mass (kg)
var AA, AU, EE, FS, KB, Molecules, NM, Particle, colorMap, parameters;

AU = 1.67262189e-27;

// proton charge (C)
EE = 1.60217662e-19;

// Boltzmann constant (J/K)
KB = 1.38064852e-23;

// angstrom (m)
AA = 1.00000000e-10;

// nano metor
NM = 1.00000000e-9;

// femto second (s)
FS = 1.00000000e-15;

exports.AU = AU;

exports.EE = EE;

exports.KB = KB;

exports.AA = AA;

exports.FS = FS;

exports.NM = NM;

parameters = [[
//          mass(kg),     charge(C), epsilon(T), sigma(A),    dt(*FS)
"He", 4.003e0 * AU, 0e0 * EE, 10.2e0 * KB, 2.576e0 * AA, 5e0 * FS // 0
], ["Ne", 20.183e0 * AU, 0e0 * EE, 36.2e0 * KB, 2.976e0 * AA, 10e0 * FS // 1
], ["Ar", 39.948e0 * AU, 0e0 * EE, 124.0e0 * KB, 3.418e0 * AA, 25e0 * FS // 2
], ["Kr", 83.500e0 * AU, 0e0 * EE, 190.0e0 * KB, 3.610e0 * AA, 25e0 * FS // 3
], ["Xe", 131.300e0 * AU, 0e0 * EE, 229.0e0 * KB, 4.055e0 * AA, 25e0 * FS // 4
], ["Hg", 200.590e0 * AU, 0e0 * EE, 851.0e0 * KB, 2.898e0 * AA, 25e0 * FS // 5
], ["H2", 2.016e0 * AU, 0e0 * EE, 33.3e0 * KB, 2.968e0 * AA, 5e0 * FS // 6
], ["N2", 28.013e0 * AU, 0e0 * EE, 91.5e0 * KB, 3.681e0 * AA, 20e0 * FS // 7
], ["O2", 31.999e0 * AU, 0e0 * EE, 113.0e0 * KB, 3.433e0 * AA, 20e0 * FS // 8
], ["BP", 200.00e0 * AU, 0.0 * EE, 124.0e0 * KB, 10.0e0 * AA, 25e0 * FS // 9
]];

exports.parameters = parameters;

// }}}

// color pallette {{{
colorMap = ["0xFB45A3", // He
"0x38CE97", // Ne
"0xD32F2F", // Ar
"0xFF5722", // Kr
"0x3F51B5", // Xe
"0x8BC34A", // Hg
"0xFF9800", // H2
"0x673AB7", // N2
"0x7D6C46", // O2
"0x7D6C46" // BP
];

exports.colorMap = colorMap;

// }}}

// }}}
Particle = function () {
  // {{{
  function Particle() {
    var _dimension = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : 2;

    var color1 = arguments[1];
    var radius1 = arguments[2];
    var position = arguments[3];
    var velocity1 = arguments[4];

    _classCallCheck(this, Particle);

    this.color = color1;
    this.radius = radius1;
    this.position = position;
    this.velocity = velocity1;
    // position[0..@size], velocity[0..@size]
    this.size = _dimension - 1;
  }

  _createClass(Particle, [{
    key: "move",
    value: function move() {
      var _dt = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : 1;

      var i, j, ref, results;
      results = [];
      for (i = j = 0, ref = this.size; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
        results.push(this.position[i] += this.velocity[i] * _dt);
      }
      return results;
    }
  }]);

  return Particle;
}();

// }}}

Molecules = function (_Particle) {
  _inherits(Molecules, _Particle);

  // {{{
  function Molecules() {
    var _key = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : 0;

    var _dimension = arguments[1];
    var _position = arguments[2];
    var _velocity = arguments[3];

    _classCallCheck(this, Molecules);

    var color, i, j, k, radius, randomize, ref, ref1, results, velocity;
    randomize = function randomize(average) {
      return (Math.random(1) - 5e-1) * average;
    };
    color = colorMap[_key];
    radius = parameters[_key][4];
    velocity = [];
    for (i = j = 0, ref = _dimension - 1; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
      velocity[i] = randomize(_velocity);
    }
    //    velocity[1] = 0

    var _this = _possibleConstructorReturn(this, (Molecules.__proto__ || Object.getPrototypeOf(Molecules)).call(this, _dimension, color, radius, _position, velocity));

    _this.key = _key;
    _this.mass = parameters[_key][1];
    _this.sigma = parameters[_key][4];
    _this.epsi = parameters[_key][3];
    _this.force = function () {
      results = [];
      for (var k = 0, ref1 = this.size; 0 <= ref1 ? k <= ref1 : k >= ref1; 0 <= ref1 ? k++ : k--) {
        results.push(k);
      }
      return results;
    }.apply(_this).fill(0e0);
    return _this;
  }

  _createClass(Molecules, [{
    key: "move",
    value: function move(_dt, _canvas, _ratio) {
      var flag, i, j, k, nextPosition, ref, ref1, results;
      for (i = j = 0, ref = this.size; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
        this.velocity[i] += this.force[i] / this.mass * _dt;
        nextPosition = this.position[i] + this.velocity[i] * _dt;
        flag = false;
        if (nextPosition < this.radius) {
          flag = true;
          this.velocity[i] = -this.velocity[i];
          this.position[i] = this.radius;
        } else if (nextPosition > _canvas[i] - this.radius) {
          flag = true;
          this.velocity[i] = -this.velocity[i];
          this.position[i] = _canvas[i] - this.radius;
        } else {
          this.position[i] = nextPosition;
        }
      }
      if (flag === true) {
        results = [];
        for (i = k = 0, ref1 = this.size; 0 <= ref1 ? k <= ref1 : k >= ref1; i = 0 <= ref1 ? ++k : --k) {
          results.push(this.velocity[i] = this.velocity[i] * _ratio);
        }
        return results;
      }
    }
  }, {
    key: "getEnergy",
    value: function getEnergy() {
      var energy, i, j, ref;
      energy = 0e0;
      for (i = j = 0, ref = this.size; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
        energy += 5e-1 * this.mass * Math.pow(this.velocity[i], 2);
      }
      return energy;
    }
  }, {
    key: "getForce",
    value: function getForce(_Molecules) {
      var R, ep, f, i, j, k, r, r3, r6, ref, ref1, results, rij, s;
      R = [];
      rij = 0e0;
      for (i = j = 0, ref = this.size; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
        R[i] = this.position[i] - _Molecules.position[i];
        rij += Math.pow(R[i], 2);
      }
      rij = Math.sqrt(rij);
      s = 5e-1 * (this.sigma + _Molecules.sigma);
      ep = 5e-1 * (this.epsi + _Molecules.epsi);
      r = s / rij;
      r3 = r * r * r;
      r6 = r3 * r3;
      f = 24e0 * ep * r6 * (2e0 * r6 - 1e0) / rij;
      results = [];
      for (i = k = 0, ref1 = this.size; 0 <= ref1 ? k <= ref1 : k >= ref1; i = 0 <= ref1 ? ++k : --k) {
        this.force[i] += f * R[i] / rij;
        results.push(_Molecules.force[i] += -f * R[i] / rij);
      }
      return results;
    }
  }]);

  return Molecules;
}(Particle);

// }}}
exports.Molecules = Molecules;

/***/ }),
/* 2 */
/***/ (function(module, exports) {

module.exports = jQuery;

/***/ })
/******/ ]);