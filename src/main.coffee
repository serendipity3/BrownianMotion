# THREE = require "three"
molecules = require "./molecules.coffee"
$ = require "jQuery"

main = () ->
# init renderer {{{
    canvasID = 'canvas'
    canvasDOM = document.getElementById(canvasID)
    height = (canvasDOM.currentStyle || document.defaultView.getComputedStyle(canvasDOM, '')).height
    width  = (canvasDOM.currentStyle || document.defaultView.getComputedStyle(canvasDOM, '')).width
    height = parseInt(height, 10)
    width = parseInt(width, 10)
#    height = window.innerHeight
#    width = window.innerWidth

    renderer = new THREE.WebGLRenderer()
    renderer.setSize(width, height)
    renderer.setClearColor(0xcccccc, 1.0)

    canvasDOM.appendChild(renderer.domElement)
# }}}

# init camera {{{
    # display (x,y)-point of BrownianMotion
    d0     = ([0,1]).fill(0)
    dMax   = [width, height]
    center = [width/2, height/2]
    aspect = width / height
    camera = new THREE.OrthographicCamera(-width/2,width/2, -height/2,height/2, 0.01,100)
    camera.position.set(center[0], center[1], -10)
    camera.up.set(0, -1, 0)
    camera.lookAt(center[0], center[1], 0)
# }}}

# init scene {{{
    scene = new THREE.Scene()

    # add DirectionalLight {{{
    directionalLight = new THREE.DirectionalLight(0xffffff, 1)
    directionalLight.position.set(0, 0, 10)
    directionalLight.lookAt(new THREE.Vector3(0, 0, 0))
    scene.add(directionalLight)
    # }}}
    # add gridHelper {{{
    gridHelper = new THREE.GridHelper(2*width, 40) #  引数(size, divisions)
    scene.add(gridHelper)
    gridHelper.rotation.x = Math.PI / 2
    # }}}
#    # add axesHelper {{{
#    axesHelper = new THREE.AxesHelper()
#    scene.add(axesHelper)
#    # }}}
# }}}

    dim = 2
    n = width / 20
    displayLenght = 10*n
    sgm = molecules.parameters[1][4]
    realLength = 1e2 * sgm
    scale = displayLenght / realLength

    canvasThree = [displayLenght, Math.floor(displayLenght*aspect)]
    canvas = [realLength, realLength*aspect]

    # time division (s)
    dt = 15e0 * molecules.FS
    v0 = 4e2
    elementID = 2
    particleNumber = 100 - 1

    # add particle {{{
    # resize real -> Three
    resize = (_r) ->
        dr = Math.floor(_r * scale)
    # remap real -> Three
    remap = (_q) ->
        dq = []
        for i in [0..dim-1]
            dq[i] = Math.floor(dMax[i] / canvas[i] * _q[i])
        return dq

    particle = []
    particleThree = []

    sqrtN = Math.sqrt(particleNumber) + 1
    for i in [0..particleNumber]
        position = [
            Math.floor(i%sqrtN+1)*canvas[0]/sqrtN + sgm
            Math.floor(i/sqrtN+1)*canvas[1]/sqrtN + sgm
        ]
        particle[i] = new molecules.Molecules(elementID, dim, position, v0)

        geometry = new THREE.CircleGeometry( resize(particle[i].radius), 32 )
        material = new THREE.MeshPhongMaterial()
        material.color.setHex( parseInt(particle[i].color, 16) )

        particleThree[i] = new THREE.Mesh( geometry, material )

        positionThree = remap(particle[i].position)
        positionThree.push(0) if dim is 2
        particleThree[i].position.set(positionThree[0], positionThree[1], positionThree[2])
        scene.add( particleThree[i] )
    # }}}

    # add cube {{{
    geometry = new THREE.BoxGeometry( 20, 20, 20 )
    material = new THREE.MeshPhongMaterial({color: 0x00cc00})
    cube = new THREE.Mesh( geometry, material )
    cube.position.set(3*n,3*n,0)
    scene.add( cube )
    # }}}

    t = 0e0
    animate = () -> # {{{
        cube.rotation.x += 0.01

        $ -> $('#time').text("t = "+(t*1e9).toFixed(3)+" ns")

        KE = 0
        for i in [0..particleNumber]
            KE += particle[i].getEnergy()
        KE = KE / particleNumber / molecules.KB
        $ -> $('#energy').text("KE = "+KE.toFixed(3)+" K")

        for p in [0..20]
            t += dt
            for i in [0..particleNumber]
                particle[i].force.fill(0)

            for i in [0..particleNumber]
                for j in [i+1..particleNumber]
                    if j > particleNumber
                        break
                    particle[j].getForce(particle[i])
                particle[i].move(dt, canvas)

        for i in [0..particleNumber]
            positionThree = remap(particle[i].position)
            positionThree.push(0) if dim is 2
            particleThree[i].position.set(positionThree[0], positionThree[1], positionThree[2])

        requestAnimationFrame( animate )
        renderer.render( scene, camera )
#   }}}

    animate()

main()

$ ->
    $('h1').css('color', 'red')
    $('h1').css('background-color', 'blue')
    $('h1').css('width', '200px')
    $('.hoge').animate { width: '100px' }, 'fast'

$ 'fuga'
  .addClass 'active'
  .css
    'top': '20px'
    'left': '300px'
    'width': '320px'
    'height': '120px'
