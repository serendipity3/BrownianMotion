# THREE = require "three"
molecules = require "./molecules.coffee"
$ = require "jQuery"

bathT = 300e0
dt = 15e0 * molecules.FS
v0 = 4e2
elementID = 2
particleNumber = 100
origin = $('div#canvas').offset()
margin = 3
flagDisplayParticles = true
flagDisplayTrajectory = false
flagDisplayLabel = false

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

    renderer = new THREE.WebGLRenderer(alpha:true,antialias:true)
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

    stats = new Stats()
    stats.showPanel( 0 ) # 0: fps, 1: ms, 2: mb, 3+: custom
    $("#stats").append( stats.dom );
    $('#time').offset( (i,r) -> {
        top: origin["top"]
        left: origin["left"]+width
    } )
    $('#energy').offset( (i,r) -> {
        top: origin["top"]+20
        left: origin["left"]+width
    } )
# configure dat.GUI {{{
    config =
        bathTemperature: bathT
        displayParticles: flagDisplayParticles
        displayTrajectory: flagDisplayTrajectory
        displayLabel: flagDisplayLabel

    gui = new dat.GUI({ autoPlace: false })
    $("#datGUI").append(gui.domElement)
    $("#datGUI").offset( (i,r) -> {
        top: origin["top"]+50
        left: origin["left"]+width
    } )
    bathFolder = gui.addFolder("bath temperature")
    bathFolder.add(config, 'bathTemperature', 10, 400).onChange( () -> bathT = config.bathTemperature )
    bathFolder.open()
    displayFolder = gui.addFolder("Display")
    displayFolder.add(config, 'displayParticles').onChange( () -> flagDisplayParticles = config.displayParticles )
    displayFolder.add(config, 'displayTrajectory').onChange( () -> flagDisplayTrajectory = config.displayTrajectory )
    displayFolder.add(config, 'displayLabel').onChange( () -> flagDisplayLabel = config.displayLabel)

    displayFolder.open()
# }}}

    dim = 2
    n = width / 20
    displayLenght = 10*n
    sgm = molecules.parameters[1][4]
    realLength = 3e1 * sgm
    scale = displayLenght / realLength

    canvasThree = [displayLenght, Math.floor(displayLenght*aspect)]
    canvas = [realLength, realLength*aspect]

    # resize real -> Three
    resize = (_r) ->
        dr = Math.floor(_r * scale)
    # remap real -> Three
    remap = (_q) ->
        dq = []
        for i in [0..dim-1]
            dq[i] = Math.floor(dMax[i] / canvas[i] * _q[i])
        return dq

    # add particle {{{
    particle = []
    particleThree = []
    label = []
    labelContainer = $('<div id="particleLabel"></div>').appendTo('div#canvas')

    sqrtN = Math.sqrt(particleNumber) + 1
    for i in [0..particleNumber-1]
        position = [
            Math.floor(i%sqrtN)*canvas[0]/sqrtN + sgm
            Math.floor(i/sqrtN)*canvas[1]/sqrtN + sgm
        ]
        particle[i] = new molecules.Molecules(elementID, dim, position, v0)

        geometry = new THREE.CircleGeometry( resize(particle[i].radius), 32 )
        material = new THREE.MeshPhongMaterial({transparent: true, opacity: 1.0})
        if flagDisplayParticles is true
            material.color.setHex( parseInt(particle[i].color, 16) )
        else
            material.opacity = 1.0

        particleThree[i] = new THREE.Mesh( geometry, material )

        positionThree = remap(particle[i].position)
        positionThree.push(0) if dim is 2
        particleThree[i].position.set(positionThree[0], positionThree[1], positionThree[2])
        scene.add( particleThree[i] )

        label[i] = $('<span id="label'+i+'">'+i+'</span>').appendTo('div#particleLabel')
        if flagDisplayLabel is true
            label[i].offset( (j,r) -> {
                top: origin["top"]+height-positionThree[1]
                left: origin["left"]+positionThree[0]
            } )
        else
            labelContainer.remove()

    i = particleNumber
    halfN = Math.floor(particleNumber/2)
    position = [
        particle[halfN].position[0] + 5e-1 * (canvas[0] / sqrtN);
        particle[halfN].position[0] + 5e-1 * (canvas[1] / sqrtN);
    ]
    particle[i] = new molecules.Molecules(9, dim, position, v0)

    geometry = new THREE.CircleGeometry( resize(particle[i].radius), 32 )
    material = new THREE.MeshPhongMaterial({transparent: true, opacity: 1.0})
    material.color.setHex( parseInt(particle[i].color, 16) )

    particleThree[i] = new THREE.Mesh( geometry, material )

    positionThree = remap(particle[i].position)
    positionThree.push(0) if dim is 2
    particleThree[i].position.set(positionThree[0], positionThree[1], positionThree[2])
    scene.add( particleThree[i] )
    # }}}

    # trajectory {{{
    trajectory = []
    pointTrajectory = []
    pointTrajectory.push(particleThree[i].position.clone())

    trajectoryMaterial = new THREE.LineBasicMaterial({
        color: 0x000000
        transparent: true
        opacity: 1.0
    })
    # }}}

    getTemperature = () ->
        KE = 0
        for i in [0..particleNumber]
            KE += particle[i].getEnergy()
        KE = KE / particleNumber / molecules.KB

    t = 0e0
    flame = 0
    animate = () -> # {{{
        flame += 1
        stats.begin()
        $('#time').text("t = "+(t*1e9).toFixed(3)+" ns")

        temperature = getTemperature()
        $('#energy').text("kinetic energy = "+temperature.toFixed(1)+" K")

        if flagDisplayParticles is true
            for i in [0..particleNumber-1]
                particleThree[i].material.opacity = 1.0
        else
            for i in [0..particleNumber-1]
                particleThree[i].material.opacity = 0.0

        if flagDisplayLabel is true
            if $('div#canvas').children("div#particleLabel").length is 0
                $('div#canvas').append('<div id="particleLabel"></div>')
                for i in [0..particleNumber]
                    label[i] = $('<span id="label'+i+'">'+i+'</span>').appendTo('div#particleLabel')
        else
            $('div#canvas').children("div#particleLabel").remove()
            if $('div#canvas').children("div#particleLabel").length is not 0
                $('div#canvas').children("div#particleLabel").remove()

        if flagDisplayTrajectory is false
            for j in [0..trajectory.length-1]
                scene.remove(trajectory[j])

        for p in [0..5]
            t += dt
            for i in [0..particleNumber]
                particle[i].force.fill(0)

            for i in [0..particleNumber]
                for j in [i+1..particleNumber]
                    if j > particleNumber
                        break
                    particle[j].getForce(particle[i])

            T = getTemperature()
            Tr = Math.sqrt(bathT/T)
            if Tr < 5e-1
                Tr = 5e-1
            else if Tr > 1.2e0
                Tr = 1.2e0
            for i in [0..particleNumber]
                particle[i].move(dt, canvas, Tr)

        for i in [0..particleNumber]
            positionThree = remap(particle[i].position)
            positionThree.push(0) if dim is 2
            particleThree[i].position.set(positionThree[0], positionThree[1], positionThree[2])

            if flagDisplayLabel is true
                label[i].offset( (j,r) -> {
                    top: origin["top"]+height+margin-positionThree[1]
                    left: origin["left"]+margin+positionThree[0]
                } )


            if flame%10 is 0
                i = particleNumber
                pointTrajectory.push(particleThree[i].position.clone())

                if flagDisplayTrajectory is true
                    trajectoryGeometry = new THREE.Geometry()
                    trajectoryGeometry.vertices.push(pointTrajectory[pointTrajectory.length-2])
                    trajectoryGeometry.vertices.push(pointTrajectory[pointTrajectory.length-1])
                    trajectory.push(new THREE.Line(trajectoryGeometry, trajectoryMaterial))
                    scene.add(trajectory[trajectory.length-1])

        stats.end()

        requestAnimationFrame( animate )
        renderer.render( scene, camera )
#   }}}

    animate()

main()
