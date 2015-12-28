package;

// References
// http://luboslenco.com/kha3d/ see example 6.
// https://github.com/RafaelOliveira/BasicKha
// polyk.ivank.net

import kha.Color;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexBuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.FragmentShader;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexData;
import kha.graphics4.Usage;
import kha.graphics4.ConstantLocation;
import kha.graphics4.CompareMode;
import kha.graphics2.ImageScaleQuality;
import kha.graphics2.Graphics;
import kha.graphics4.TextureFormat;
import kha.math.Matrix4;
import kha.math.Vector3;
import TwoLines;    
import kha.graphics4.PipelineState;
import kha.Shaders;
import kha.Assets;
import kha.Framebuffer;
import kha.Image;
import kha.input.Keyboard;
import kha.input.Mouse;
import kha.Key;
import kha.Scaler;
import kha.System;
import PolyK;

class GraphicsKha {
    var pixelLayer: Image;
    var vectorLayer: Image;
    var initialized: Bool = false;
    var ball: Image;
    var xPos: Float;
    var yPos: Float;
    var keys: Array<Bool> = [for(i in 0...4) false];
    
    public function new(){
        
        pixelLayer = Image.createRenderTarget(1280, 720);
        vectorLayer = Image.createRenderTarget(1280, 720, TextureFormat.RGBA32, true, 4 );
        
        var keyboard = Keyboard.get();
        keyboard.notify(keyDown, keyUp);
        var mouse = Mouse.get();
        mouse.notify(null, null, mouseMove, null);
        Assets.loadEverything( loadingFinished );
    }

    // An array of vertices to form a cube
    static var vertices:Array<Float> = [];
    // Array of colors for each cube vertex
    static var colors:Array<Float> = [];
    var pipeline:PipelineState;
    var vertexBuffer:VertexBuffer;
    var indexBuffer:IndexBuffer;
    var mvp:Matrix4;
    var mvpID:ConstantLocation;
    var z: Float = -1;
    var structureLength = 6;
    
    public function setup3d():Void {
        // Define vertex structure
        var structure = new VertexStructure();
        structure.add( "pos", VertexData.Float3 );
        structure.add( "col", VertexData.Float3 );
        // Save length - we store position and color data
        

        // Compile pipeline state
        // Shaders are located in 'Sources/Shaders' directory
        // and Kha includes them automatically
        pipeline = new PipelineState();
        pipeline.inputLayout = [structure];
        pipeline.fragmentShader = Shaders.simple_frag;
        pipeline.vertexShader = Shaders.simple_vert;
        // Set depth mode
        pipeline.depthWrite = false;
        pipeline.depthMode = CompareMode.Less;
        pipeline.compile();
        
        // Get a handle for our "MVP" uniform
        mvpID = pipeline.getConstantLocation("MVP");

        // Projection matrix: 45° Field of View, 4:3 ratio, display range : 0.1 unit <-> 100 units
        var projection = Matrix4.perspectiveProjection(45.0, 16.0 / 9.0, 0.1, 100.0);
        // Or, for an ortho camera
        //var projection = Matrix4.orthogonalProjection(-10.0, 10.0, -10.0, 10.0, 0.0, 100.0); // In world coordinates
        
        // Camera matrix
        var view = Matrix4.lookAt(new Vector3(0, 0, 10), // Camera is at (4, 3, 3), in World Space
                                  new Vector3(0, 0, 0), // and looks at the origin
                                  new Vector3(0, 1, 0) // Head is up (set to (0, -1, 0) to look upside-down)
        );

        // Model matrix: an identity matrix (model will be at the origin)
        var model = Matrix4.identity();
        // Our ModelViewProjection: multiplication of our 3 matrices
        // Remember, matrix multiplication is the other way around
        mvp = Matrix4.identity();
        mvp = mvp.multmat(projection);
        mvp = mvp.multmat(view);
        mvp = mvp.multmat(model);
        
        var verticesLocal = vertices;
        var colorsLocal = colors;
        //TwoLines.testColors = true; // sets some default colors.
        TwoLines.setupSingleColors( 0xff0000, 1, 0xff0000, 1 );
        
        TwoLines.thickness = 50;
        var twoLines = TwoLines;
        var toRGBs = toRGB;
        var adjScale: Float = 87.1;//200
        var offX: Float = -7.35;
        var offY: Float = -4.13;
        
        // create the triangle drawing command.
        TwoLines.drawTri = function(   p0: Point, p1: Point, p2: Point
                                   ,   col: Int, alpha: Float
                                   ,   lineCol: Int, lineAlpha: Float ):Void {
            verticesLocal.push( p0.x/adjScale + offX );
            verticesLocal.push( p0.y/adjScale + offY );
            verticesLocal.push( -z );
            verticesLocal.push( p1.x/adjScale + offX );
            verticesLocal.push( p1.y/adjScale + offY);
            verticesLocal.push( -z );
            verticesLocal.push( p2.x/adjScale + offX );
            verticesLocal.push( p2.y/adjScale + offY );
            verticesLocal.push( -z );
            var rgb = toRGBs( col );
            colors.push( rgb.r );
            colors.push( rgb.g );
            colors.push( rgb.b );
            colors.push( rgb.r );
            colors.push( rgb.g );
            colors.push( rgb.b );
            colors.push( rgb.r );
            colors.push( rgb.g );
            colors.push( rgb.b );
            //twoLines.thickness -= 0.05;
        }
        // vertexBufferLen = Std.int(vertices.length / 3)
        // Create vertex buffer
        vertexBuffer = new VertexBuffer(
            300000, // Vertex count - 3 floats per vertex
            structure, // Vertex structure
            Usage.DynamicUsage // Vertex data will stay the same
        );
        // indicesLen = indices.length;
        // Create index buffer
        indexBuffer = new IndexBuffer(
            300000  , // Number of indices for our cube
            Usage.DynamicUsage // Index data will stay the same
        );
    }
    
    public function updateVectors():Void {
     // Copy vertices and colors to vertex buffer
        var vbData = vertexBuffer.lock();
        for (i in 0...Std.int(vbData.length / structureLength)) {
            vbData.set( i * structureLength, vertices[i * 3] );
            vbData.set( i * structureLength + 1, vertices[i * 3 + 1] );
            vbData.set( i * structureLength + 2, vertices[i * 3 + 2] );
            vbData.set( i * structureLength + 3, colors[i * 3] );
            vbData.set( i * structureLength + 4, colors[i * 3 + 1] );
            vbData.set( i * structureLength + 5, colors[i * 3 + 2] );
        }
        vertexBuffer.unlock();
        // A 'trick' to create indices for a non-indexed vertex data
        var indices:Array<Int> = [];
        for (i in 0...Std.int(vertices.length / 3)) {
            indices.push(i);
        }
        // Copy indices to index buffer
        var iData = indexBuffer.lock();
        for (i in 0...iData.length) {
            iData[i] = indices[i];
        }
        indexBuffer.unlock();
    }
    
    public function drawBorder():Void {
        // add borders
        z = 0;
        TwoLines.thickness = 2;
        TwoLines.opaqueColor( 0x0C2542 );//0x7AA9DE
        TwoLines.rectangleOutline( 0, 0, 1280, 720 );
        TwoLines.opaqueColor( 0x5387C2 );
        TwoLines.rectangleOutline( 2, 2, 1276, 716 );
    }
    
    var timeSlice: Float = 0;
    
    public function polykTest(){
        z = 0;
        var poly = [ 93., 195., 129., 92., 280., 81., 402., 134., 477., 70., 619., 61., 759., 97., 758., 247., 662., 347., 665., 230., 721., 140., 607., 117., 472., 171., 580., 178., 603., 257., 605., 377., 690., 404., 787., 328., 786., 480., 617., 510., 611., 439., 544., 400., 529., 291., 509., 218., 400., 358., 489., 402., 425., 479., 268., 464., 341., 338., 393., 427., 373., 284., 429., 197., 301., 150., 296., 245., 252., 384., 118., 360., 190., 272., 244., 165., 81., 259., 40., 216.];
        var polyPairs = new ArrayPairs( poly );
        var polySin = new Array<Float>();
        for( pair in polyPairs ){
            polySin.push( pair.x );//+ 2*Math.sin( timeSlice*(Math.PI/180 ) ));
            polySin.push( pair.y + 30*Math.sin( timeSlice*(Math.PI/180 ) ));
        }
        timeSlice += 3;
        poly = polySin;
        var tgs = PolyK.triangulate( poly ); 
        var triples = new ArrayTriple( tgs );
        var a: Point;
        var b: Point;
        var c: Point;
        var i: Int;
        for( tri in triples ){
            i = Std.int( tri.a*2 );
            a = { x: poly[ i ], y: poly[ i + 1 ] };
            i = Std.int( tri.b*2 );
            b = { x: poly[ i ], y: poly[ i + 1 ] };
            i = Std.int( tri.c*2 );
            c = { x: poly[ i ], y: poly[ i + 1 ] };
            TwoLines.drawTri( a, b, c, 0xff0000, 0xffffff, 0, 0 );
        }
    }
    private function graphicsTests(){
        // wavy line
        z = -0.5;
        // alpha and outline are not used only first color parameter.
        //TwoLines.setupSingleColors( 0xff0000, 1, 0xff0000, 1 );
        TwoLines.testColors = true; 
        TwoLines.createTriangles( TwoLines.horizontalWavePoints( 10, 5, 100, 50, 60, 3 ) );
        
        // circles
        z = 0.5;
        TwoLines.opaqueColor( 0xffff00 );
        TwoLines.circleOutline( 350, 600, 100 );
        TwoLines.opaqueColor( 0x0000ff );
        TwoLines.circleOutline( 650, 600, 100 );
        TwoLines.opaqueColor( 0x00ff00 );
        TwoLines.circleOutline( 950, 600, 100 );
        
        // polygons
        z = 1.1;
        TwoLines.thickness = 80;
        TwoLines.opaqueColor( 0xffcc00 );
        TwoLines.hexagonOutline( 950, 180, 100 );
        TwoLines.thickness = 30;
        TwoLines.opaqueColor( 0xff00ff );
        TwoLines.rectangleOutline( 100, 100, 200, 200 );
        TwoLines.thickness = 10;
        TwoLines.opaqueColor( 0x00ffff );
        TwoLines.equilateralTriangleOutline( 570, 240, 100, 0 );
        
        // quad curve
        z = -0.7;
        TwoLines.opaqueColor( 0xF84525 );
        TwoLines.thickness = 25;
        HeartTest.outline( 520, 350, 7 );
        
        // assorted lines
        z = 0.8;
        TwoLines.thickness = 80;
        var rndColors = [ 0xff0000, 0x00ff00, 0x0000ff, 0xffff00,0x00ffff,0xff00ff,0xffffff ];
        var rndEnds = [ true, false ];
        for( i in 0...12 ){
            var aCol = rndColors[ Math.round( Math.random()*(rndColors.length-1))];
            var roundEnd = rndEnds[ Math.round( Math.random() ) ];
            TwoLines.setupSingleColors( aCol, 1, aCol, 1 );
            z = -1 + Math.random()*2;
            TwoLines.drawIsolatedLine( { x: 300 + Math.random()*800, y: -200 + Math.random()*800 }, { x: 300 + Math.random()*800,y: -200 + Math.random()*800 }, 10+Math.random()*20, roundEnd  );
        }
        // pie
        z = 0.5;
        TwoLines.opaqueColor( 0x0000ff );
        TwoLines.packMan( 1000, 400, 100, 0, Math.PI/4 );
        //TwoLines.createPolyTriangles( TwoLines.polyPoints( 150, 100, 100, 60 ) );
        // packman
        TwoLines.opaqueColor( 0xffff00 );
        z = 0.501;
        TwoLines.packMan( 600, 600, 100, 0, -2*Math.PI + Math.PI/20 );
        
        // rounded corner rectangle
        TwoLines.opaqueColor( 0xaaff00 );
        TwoLines.roundedRectangleOutline( 260, 400, 150, 60, 10, 25 );//300
        
        // vertical wave
        z = 0;
        TwoLines.testColors = true; 
        TwoLines.createTriangles( TwoLines.verticalWavePoints( 100, 10, 5, 50, 60, 3 ) );
    
    }
    
    public static inline function toRGB( int: Int ) : { r: Float, g: Float, b: Float } {
        return {
            r: ((int >> 16) & 255) / 255,
            g: ((int >> 8) & 255) / 255,
            b: (int & 255) / 255,
        }
    }
    
    private function loadingFinished():Void
    {
        setup3d();
        initialized = true;
        
        ball = Assets.images.ball;
        xPos = (System.pixelWidth / 2) - (ball.width / 2);
        yPos = (System.pixelHeight / 2) - (ball.width / 2);
    }
    
    function keyDown(key:Key, char:String):Void
    {
        switch(key)
        {
            case Key.LEFT:  keys[0] = true;
            case Key.RIGHT: keys[1] = true;
            case Key.UP:    keys[2] = true;
            case Key.DOWN:  keys[3] = true;
            default: return;
        }
    }
    
    function keyUp(key:Key, char:String):Void
    {
        switch(key)
        {
            case Key.LEFT:  keys[0] = false;
            case Key.RIGHT: keys[1] = false;
            case Key.UP:    keys[2] = false;
            case Key.DOWN:  keys[3] = false;
            default: return;
        }
    }
    
    function mouseMove(x:Int, y:Int, movementX:Int, movementY:Int):Void
    {
        xPos = x - (ball.width / 2);
        yPos = y - (ball.height / 2);
    }
    
    public function update():Void
    {
        if (!initialized)
            return;
            
        if (keys[0])
            xPos -= 3;
        else if (keys[1])
            xPos += 3;
            
        if (keys[2])
            yPos -= 3;
        else if (keys[3])
            yPos += 3;
    }
    
    public function render(framebuffer:Framebuffer):Void {
        if (!initialized)return;
        var lv = vertices.length;
        for( i in 0...lv ) vertices.pop();
        var lc = colors.length;
        for( i in 0...lc ) colors.pop();
        graphicsTests();
        polykTest();
        drawBorder();
        updateVectors();
        
        var g2 = pixelLayer.g2;
        g2.imageScaleQuality = ImageScaleQuality.High;
        g2.begin(false);
        g2.clear(Color.fromValue(0x00000000));
        g2.drawImage(ball, xPos, yPos);
        g2.end();
        
        //vectorLayer = Image.createRenderTarget(1280, 720);
        var g4 = vectorLayer.g4;
        var g2 = vectorLayer.g2;
        g2.imageScaleQuality = ImageScaleQuality.High;
        g4.begin();
        g4.clear(Color.fromValue(0xff000000));
        g4.setVertexBuffer(vertexBuffer);
        g4.setIndexBuffer(indexBuffer);
        g4.setPipeline(pipeline);
        g4.setMatrix(mvpID, mvp);
        g4.drawIndexedVertices();
        g4.end();
        
        var g2 = framebuffer.g2;
        g2.begin();
        g2.imageScaleQuality = ImageScaleQuality.High;
        g2.drawImage( vectorLayer, 0, 0 );
        g2.drawImage( pixelLayer, 0, 0 );
        g2.end();
    }    
}