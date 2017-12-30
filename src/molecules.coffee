# parameters {{{
# Physical parameters {{{
# proton mass (kg)
AU = 1.67262189e-27
# proton charge (C)
EE = 1.60217662e-19
# Boltzmann constant (J/K)
KB = 1.38064852e-23
# angstrom (m)
AA = 1.00000000e-10
# nano metor
NM = 1.00000000e-9
# femto second (s)
FS = 1.00000000e-15
#
exports.AU = AU
exports.EE = EE
exports.KB = KB
exports.AA = AA
exports.FS = FS
exports.NM = NM
#
#
parameters = [
#          mass(kg),     charge(C), epsilon(T), sigma(A),    dt(*FS)
   [ "He",   4.003e0*AU,  0e0*EE,    10.2e0*KB,  2.576e0*AA,   5e0*FS ] # 0
   [ "Ne",  20.183e0*AU,  0e0*EE,    36.2e0*KB,  2.976e0*AA,  10e0*FS ] # 1
   [ "Ar",  39.948e0*AU,  0e0*EE,   124.0e0*KB,  3.418e0*AA,  25e0*FS ] # 2
   [ "Kr",  83.500e0*AU,  0e0*EE,   190.0e0*KB,  3.610e0*AA,  25e0*FS ] # 3
   [ "Xe", 131.300e0*AU,  0e0*EE,   229.0e0*KB,  4.055e0*AA,  25e0*FS ] # 4
   [ "Hg", 200.590e0*AU,  0e0*EE,   851.0e0*KB,  2.898e0*AA,  25e0*FS ] # 5
   [ "H2",   2.016e0*AU,  0e0*EE,    33.3e0*KB,  2.968e0*AA,   5e0*FS ] # 6
   [ "N2",  28.013e0*AU,  0e0*EE,    91.5e0*KB,  3.681e0*AA,  20e0*FS ] # 7
   [ "O2",  31.999e0*AU,  0e0*EE,   113.0e0*KB,  3.433e0*AA,  20e0*FS ] # 9
]
exports.parameters = parameters
# }}}

# color pallette {{{
colorMap = [
  "0xFB45A3" # He
  "0x38CE97" # Ne
  "0xD32F2F" # Ar
  "0xFF5722" # Kr
  "0x3F51B5" # Xe
  "0x8BC34A" # Hg
  "0xFF9800" # H2
  "0x673AB7" # N2
  "0x7D6C46" # O2
]
exports.colorMap = colorMap
# }}}

# }}}

class Particle # {{{
  constructor: (_dimension = 2, @color, @radius, @position, @velocity) ->
    # position[0..@size], velocity[0..@size]
    @size     = _dimension - 1

  move: (_dt = 1) ->
    for i in [0..@size]
        @position[i] += @velocity[i] * _dt
# }}}
#
class Molecules extends Particle # {{{
  constructor: (_key = 0, _dimension, _position, _velocity) ->
    randomize = (average) ->
        (Math.random(1)-5e-1) * average
    color  = colorMap[_key]
    radius = parameters[_key][4]
    velocity = []
    for i in [0.._dimension-1]
      velocity[i] = randomize(_velocity)
#    velocity[1] = 0
    super(_dimension, color, radius, _position, velocity)
    @key = _key
    @mass = parameters[_key][1]
    @sigma = parameters[_key][4]
    @epsi  = parameters[_key][3]
    @force = ([0..@size]).fill(0e0)

  move: (_dt, _canvas) ->
    distance = ["min": 0e0, "max": 0e0]
    for i in [0..@size]
      @velocity[i] += @force[i] / @mass * _dt
      nextPosition = @position[i] + @velocity[i] * _dt

      distance["min"] = nextPosition - @radius
      distance["max"] = nextPosition + @radius - _canvas[i]
      if distance["min"] <= 0e0
        @velocity[i] = - @velocity[i]
#        @position[i] = - _canvas[i] - distance["min"]
      else if distance["max"] >= 0e0
        @velocity[i] = - @velocity[i]
#        @position[i] = _canvas[i] - distance["max"]
      else
        @position[i] = nextPosition

  getEnergy: () ->
    energy = 0e0
    for i in [0..@size]
      energy += 5e-1 * @mass * @velocity[i]**2
    return energy

  getForce: (_Molecules) ->
    R   = []
    rij = 0e0
    for i in [0..@size]
      R[i] = (@position[i] - _Molecules.position[i])
      rij += R[i]**2
    rij = Math.sqrt(rij)
    s  = 5e-1*(@sigma + _Molecules.sigma)
    ep = 5e-1*(@epsi  + _Molecules.epsi )
    r  = s/rij
    r3 = r*r*r
    r6 = r3*r3
    f = 24e0*ep*r6*(2e0*r6-1e0)/rij
    for i in [0..@size]
      @force[i]           +=  f*R[i]/rij
      _Molecules.force[i] += -f*R[i]/rij
# }}}

exports.Molecules = Molecules
