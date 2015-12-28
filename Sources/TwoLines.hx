package;
typedef Point = { x: Float, y: Float }
class TwoLines {
    var p0: Point;
    var p1: Point;
    var p2: Point;
    public var p3: Point;
    public var p4: Point;
    var angleA: Float; // smallest angle between lines
    var cosA: Float;
    var b2: Float;
    var c2: Float;
    var a2: Float;
    var b: Float; // first line length
    var c: Float; // second line length
    var a: Float;
    var angleD: Float;
    public var halfA: Float;
    public var beta: Float;
    var r: Float;
    public var _theta: Float;
    public var angle1: Float;
    var angle2: Float;
    var _thick: Float;
    
    public function new(){}
    
    public static inline var circleSides: Int = 60;
    public static function opaqueColor( col: Int ): Void {
        TwoLines.setupSingleColors( col, 1, col, 1 );
    }
    
    public static function packMan( dx: Float, dy: Float, radius: Float, start: Float, dA: Float ){
        TwoLines.createOuterPolyTriangles( { x: dx, y: dy }, TwoLines.arcPoints( dx, dy, radius, start, dA, circleSides ) );
    }
    
    public static function roundedRectangleOutline( dx: Float, dy: Float, hi: Float, wid: Float, radiusSmall: Float, radius: Float ): Void {
        var dia = radius*2; // radiusSmall = 10 radius = 25
        var circleSides2 = circleSides*2;
        var lb = TwoLines.arcPoints( dx, dy + hi, radiusSmall, -Math.PI - Math.PI/2, Math.PI/2, circleSides2 );
        var rb = TwoLines.arcPoints( dx + wid, dy + hi, radiusSmall, 0, Math.PI/2, circleSides2 );
        var rt = TwoLines.arcPoints( dx + wid , dy, radiusSmall, -Math.PI/2, Math.PI/2, circleSides2 );
        var lt = TwoLines.arcPoints( dx, dy, radiusSmall, -Math.PI, Math.PI/2, circleSides2 );
        TwoLines.drawIsolatedLine( {x: dx, y: dy - radius }, { x: dx + wid, y: dy - radius }, dia, false );
        TwoLines.drawIsolatedLine( {x: dx + radius + wid, y: dy }, { x: dx + radius + wid, y: dy + hi }, dia, false );
        TwoLines.drawIsolatedLine( {x: dx, y: dy + radius + hi }, { x: dx + wid, y: dy + radius + hi }, dia, false );
        TwoLines.drawIsolatedLine( {x: dx - radius, y: dy }, { x: dx - radius, y: dy + hi }, dia, false );
        TwoLines.createOuterPolyTriangles( { x: dx, y: dy + hi }, lb );// left bottom
        TwoLines.createOuterPolyTriangles( { x: dx + wid, y: dy + hi }, rb );// right bottom
        TwoLines.createOuterPolyTriangles( { x: dx + wid, y: dy }, rt );// right top
        TwoLines.createOuterPolyTriangles( { x: dx, y: dy }, lt );// left top
    }

    public static function equilateralTriangleOutline( dx: Float, dy: Float, radius: Float, ?rotation: Float = 0 ):Void {
        TwoLines.createPolyTriangles( TwoLines.equalTriPoints( dx, dy, radius, rotation ) );
    }
    public static function rectangleOutline( dx: Float, dy: Float, dw: Float, dh: Float): Void {
        TwoLines.createPolyTriangles( TwoLines.boxPoints( dx, dy, dw, dh ) );
    }
    public static function pentagonOutline( dx: Float, dy: Float, radius: Float ):Void {
        TwoLines.createPolyTriangles( TwoLines.polyPoints( dx, dy, radius, 5 ) );
    }
    public static function hexagonOutline( dx: Float, dy: Float, radius: Float ):Void {
        TwoLines.createPolyTriangles( TwoLines.polyPoints( dx, dy, radius, 6 ) );
    }
    public static function heptagonOutline( dx: Float, dy: Float, radius: Float ):Void {
        TwoLines.createPolyTriangles( TwoLines.polyPoints( dx, dy, radius, 7 ) );
    }
    public static function octagonOutline( dx: Float, dy: Float, radius: Float ):Void {
        TwoLines.createPolyTriangles( TwoLines.polyPoints( dx, dy, radius, 8 ) );
    }    
    public static function circleOutline( dx: Float, dy: Float, radius: Float ):Void {
        TwoLines.createPolyTriangles( TwoLines.polyPoints( dx, dy, radius, circleSides ) );
    }
    
    
    public static inline function drawBeginLine( p0_: Point, p1_: Point, thick: Float ){
        var twoLines = new TwoLines();        
        twoLines.p0 = p1_;
        twoLines.p1 = p0_;
        twoLines.halfA = Math.PI/2;
        twoLines.setThickness( thick );
        twoLines.calculateP3p4();
        var q0 = { x: twoLines.p3.x, y: twoLines.p3.y };
        var q1 = { x: twoLines.p4.x, y: twoLines.p4.y };
        //switch lines round to get other side but make sure you finish on p1 so that p3 and p4 are useful
        twoLines.p0 = p0_;
        twoLines.p1 = p1_;
        twoLines.calculateP3p4();
        var oldThickness = thickness;
        thickness = thick/2;
        var temp = twoLines.angle1;
        TwoLines.createOuterPolyTriangles( p0_, TwoLines.arcPoints( p0_.x, p0_.y, thick/4, temp, Math.PI, 24 ) );
        thickness = oldThickness;
        var q3 = { x: twoLines.p3.x, y: twoLines.p3.y };
        var q4 = { x: twoLines.p4.x, y: twoLines.p4.y };
        drawTri( q0, q3, q1, col, alpha, lineCol, lineAlpha );
        drawTri( q0, q3, q4, col2, alpha2, lineCol2, lineAlpha2 );
        return twoLines;
    }
    
    public static inline function drawEndLine( p0_: Point, p1_: Point, thick: Float ){
        var twoLines = new TwoLines();        
        twoLines.p0 = p1_;
        twoLines.p1 = p0_;
        twoLines.halfA = Math.PI/2;
        twoLines.setThickness( thick );
        twoLines.calculateP3p4();
        var q0 = { x: twoLines.p3.x, y: twoLines.p3.y };
        var q1 = { x: twoLines.p4.x, y: twoLines.p4.y };
        //switch lines round to get other side but make sure you finish on p1 so that p3 and p4 are useful
        twoLines.p0 = p0_;
        twoLines.p1 = p1_;
        twoLines.calculateP3p4();
        var oldThickness = thickness;
        thickness = thick/2;
        var temp = twoLines.angle1 + Math.PI;
        TwoLines.createOuterPolyTriangles( p1_, TwoLines.arcPoints( p1_.x, p1_.y, thick/4, temp, Math.PI, 24 ) );
        thickness = oldThickness;
        var q3 = { x: twoLines.p3.x, y: twoLines.p3.y };
        var q4 = { x: twoLines.p4.x, y: twoLines.p4.y };
        drawTri( q0, q3, q1, col, alpha, lineCol, lineAlpha );
        drawTri( q0, q3, q4, col2, alpha2, lineCol2, lineAlpha2 );
        return twoLines;
    }
    
    public static inline function drawIsolatedLine( p0_: Point, p1_: Point, thick: Float, curveEnds: Bool = false ){
        /*
        if( curveEnds ){
            var oldThickness = thickness;
            thickness = thick/2;
            createPolyTriangles( polyPoints( p0_.x, p0_.y, thick/4, 24 ) );
            createPolyTriangles( polyPoints( p1_.x, p1_.y, thick/4, 24 ) );
            thickness = oldThickness;
        }
        */
        var twoLines = new TwoLines();        
        twoLines.p0 = p1_;
        twoLines.p1 = p0_;
        twoLines.halfA = Math.PI/2;
        twoLines.setThickness( thick );
        twoLines.calculateP3p4();
        var q0 = { x: twoLines.p3.x, y: twoLines.p3.y };
        var q1 = { x: twoLines.p4.x, y: twoLines.p4.y };
        //switch lines round to get other side but make sure you finish on p1 so that p3 and p4 are useful
        twoLines.p0 = p0_;
        twoLines.p1 = p1_;
        twoLines.calculateP3p4();
        
        if( curveEnds ){
            var oldThickness = thickness;
            thickness = thick/2;
            var temp = twoLines.angle1;
            TwoLines.createOuterPolyTriangles( p0_, TwoLines.arcPoints( p0_.x, p0_.y, thick/4, temp, Math.PI, 24 ) );
            temp = temp + Math.PI;
            TwoLines.createOuterPolyTriangles( p1_, TwoLines.arcPoints( p1_.x, p1_.y, thick/4, temp, Math.PI, 24 ) );
            thickness = oldThickness;
        }
        var q3 = { x: twoLines.p3.x, y: twoLines.p3.y };
        var q4 = { x: twoLines.p4.x, y: twoLines.p4.y };
        drawTri( q0, q3, q1, col, alpha, lineCol, lineAlpha );
        drawTri( q0, q3, q4, col2, alpha2, lineCol2, lineAlpha2 );
        return twoLines;
    }
    
    public function create2Lines( p0_: Point, p1_: Point, p2_: Point, thick: Float ){
        p0 = p0_;
        p1 = p1_;
        p2 = p2_;
        b2 = dist2( p0, p1 ); 
        c2 = dist2( p1, p2 );
        a2 = dist2( p0, p2 );
        b = Math.sqrt( b2 );
        c = Math.sqrt( c2 );
        a = Math.sqrt( a2 );
        cosA = ( b2 + c2 - a2 )/ ( 2*b*c );
        angleA = Math.acos( cosA );
        angleD = Math.PI - angleA;
        halfA = angleA/2;
        setThickness( thick );
        calculateP3p4();
    }
    
    public inline function setThickness( val: Float ){
        _thick = val;
        beta = Math.PI/2 - halfA;
        r = ( _thick/2 )/Math.cos( beta );
    }
    
    public inline function calculateP3p4(){
        _theta = theta( p0, p1 );
        if( _theta > 0 ){
            if( halfA < 0 ){
                angle2 = _theta + halfA + Math.PI/2;
                angle1 =  _theta - halfA; 
            }else {
                angle1 =  _theta + halfA - Math.PI;
                angle2 =  _theta + halfA; 
            }
        } else {
            if( halfA > 0 ){
                angle1 =  _theta + halfA - Math.PI;
                angle2 =  _theta + halfA; 
            } else {
                angle2 = _theta + halfA + Math.PI/2;
                angle1 =  _theta - halfA; 
            }
        }
        p3 = { x: p1.x + r * Math.cos( angle1 ), y: p1.y + r * Math.sin( angle1 ) };
        p4 = { x: p1.x + r * Math.cos( angle2 ), y: p1.y + r * Math.sin( angle2 ) };
    }
    public function rebuildAsPoly( p2_: Point ){
        p0 = p1;
        p1 = p2;
        p2 = p2_;
        calculateP3p4();
    }    
    private function theta( p0: Point, p1: Point ): Float {
        var dx: Float = p0.x - p1.x;
        var dy: Float = p0.y - p1.y;
        return Math.atan2( dy, dx );
    }
    private function dist2( p0: Point, p1: Point  ): Float {
        var dx: Float = p0.x - p1.x;
        var dy: Float = p0.y - p1.y;
        return dx*dx + dy*dy; 
    }
    public static var thickness: Float;
    private static var q0: Point;
    private static var q1: Point;
    public static var col: Int;
    public static var alpha: Float;
    public static var lineCol: Int;
    public static var lineAlpha: Float;
    public static var col2: Int;
    public static var alpha2: Float;
    public static var lineCol2: Int;
    public static var lineAlpha2: Float;
    public static function setupSingleColors( col_: Int, alpha_: Float, lineCol_: Int, lineAlpha_: Float ){
        col = col_;
        col2 = col_;
        alpha = alpha_;
        alpha2 = alpha_;
        lineCol = lineCol_;
        lineCol2 = lineCol_;
        lineAlpha = lineAlpha_;
        lineAlpha2 = lineAlpha_;
    }
    public static var testColors( null, set ):Bool;
    public static function set_testColors( val: Bool ): Bool{
        col = 0xffff00;
        col2 = 0xff00ff;
        lineCol = col;
        lineCol2 = col2;
        alpha = 0.5;
        alpha2 = alpha;
        lineAlpha = 0.7;
        lineAlpha2 = lineAlpha;   
        return val;
    }
    // p1, p2, p3
    // , colour, alpha default 1, optional line color depending on support, optional line alpha depending on support
    public static var drawTri: Point -> Point -> Point -> Int -> Float -> Int -> Float -> Void;
    public static inline function createPolyTriangles( p: Array<Point> ){
         q0 = p[0]; 
         q1 = p[0];
         var twoLines: TwoLines = firstQuad( p, 0 );
         
         for( i in 1...( p.length - 2 ) ) drawOtherQuad( p, twoLines, i );
    }
    
    public static inline function createOuterPolyTriangles( centre: Point, p: Array<Point> ){
         q0 = p[0]; 
         q1 = p[0];
         var twoLines: TwoLines = firstQuad( p, 0 );
         for( i in 1...( p.length - 2 ) ) drawOuterFilledTriangles( centre, p, twoLines, i );
    }
    
    public static inline function createInnerPolyTriangles( centre: Point, p: Array<Point> ){
         q0 = p[0]; 
         q1 = p[0];
         var twoLines: TwoLines = firstQuad( p, 0 );
         for( i in 1...( p.length - 2 ) ) drawInnerFilledTriangles( centre, p, twoLines, i );
    }
    
    public static inline function createTriangles( p: Array<Point> ){
         q0 = p[0]; 
         q1 = p[0];
         for( i in 0...( p.length - 2 ) ) drawQuad( p, i );
    }
    private static inline function firstQuad( p: Array<Point>, i: Int ): TwoLines {
        var twoLines = new TwoLines();
        twoLines.create2Lines( p[ i ], p[ i + 1 ], p[ i + 2 ], thickness );
        var q3 = twoLines.p3;
        var q4 = twoLines.p4;
        q0 = q3;
        q1 = q4;
        return twoLines;
    }
    // assumes that firstQuad is drawn.
    private static inline function drawOtherQuad( p: Array<Point>, twoLines: TwoLines, i: Int ){
        twoLines.rebuildAsPoly( p[ i + 2 ]);
        var q3 = twoLines.p3;
        var q4 = twoLines.p4;
        drawTri( q0, q3, q1, col, alpha, lineCol, lineAlpha );
        drawTri( q1, q3, q4, col2, alpha2, lineCol2, lineAlpha2 );
        q0 = q3;
        q1 = q4;
        return twoLines;
    }
    
    private static inline function drawOuterFilledTriangles( centre: Point, p: Array<Point>, twoLines: TwoLines, i: Int ){
        twoLines.rebuildAsPoly( p[ i + 2 ]);
        var q3 = twoLines.p3;
        drawTri( q0, q3, centre, col, alpha, lineCol, lineAlpha );
        q0 = q3;
        return twoLines;
    }
    
    // suitable for fill.
    private static inline function drawInnerFilledTriangles( centre: Point, p: Array<Point>, twoLines: TwoLines, i: Int ){
        twoLines.rebuildAsPoly( p[ i + 2 ]);
        var q4 = twoLines.p4;
        drawTri( q1, q4, centre, col, alpha, lineCol, lineAlpha );
        q1 = q4;
        return twoLines;
    }
    
    private static inline function drawQuad( p: Array<Point>, i: Int ){
        var twoLines = new TwoLines();
        twoLines.create2Lines( p[ i ], p[ i + 1 ], p[ i + 2 ], thickness );
        var q3 = twoLines.p3;
        var q4 = twoLines.p4;
        if( i != 0 ){
            drawTri( q0, q3, q1, col, alpha, lineCol, lineAlpha );
            drawTri( q1, q3, q4, col2, alpha2, lineCol2, lineAlpha2 );
        }
        q0 = q3;
        q1 = q4;
        return twoLines;
    }
    public static inline function boxPoints( x: Float,y: Float, wid: Float, hi: Float ): Array<Point>{
        var p: Array<Point> = [     { x: x, y: y }
                                ,   { x: x+wid, y: y }
                                ,   { x: x+wid, y: y+hi }
                                ,   { x: x, y: y+hi }
                                ,   { x: x, y: y }
                                ,   { x: x+wid, y: y }
                                ,   { x: x+wid, y: y+hi }
                                ];
        p.reverse();
        return p;
    }
    public static inline function equalTriPoints( dx: Float, dy: Float, radius: Float, ?rotation: Float = 0 ):Array<Point>{
        var p: Array<Point> = new Array<Point>();         
        var angle: Float = 0;
        var offset: Float = - 2.5*Math.PI*2/6 - Math.PI + rotation;
        for( i in 0...6 ){
            angle = i*(Math.PI*2)/3 - offset; 
            p.push( { x: dx + radius * Math.cos( angle ), y: dy + radius * Math.sin( angle ) });
        } 
        p.reverse();
        return p;
    }
    
    public static inline function polyPoints( dx: Float, dy: Float, radius: Float, sides: Int ):Array<Point>{
        var p: Array<Point> = new Array<Point>();         
        var angle: Float = 0;
        var angleInc: Float = (Math.PI*2)/sides;
        for( i in 0...( sides + 3 ) ){
            angle = i*angleInc; 
            p.push( { x: dx + radius * Math.cos( angle ), y: dy + radius * Math.sin( angle ) });
        } 
        p.reverse();
        return p;
    }
    
    public static inline function arcPoints( dx: Float, dy: Float, radius: Float, start: Float, dA: Float, sides: Int ):Array<Point>{
        var p: Array<Point> = new Array<Point>();         
        var angle: Float = 0;
        var angleInc: Float = (Math.PI*2)/sides;
        var sides = Math.round( sides );
        var nextAngle: Float;
        if( dA < 0 ){
            var i = -1;
            while( true ){
                angle = i*angleInc;
                nextAngle = angle + start; 
                i--;
                if( angle <= dA ) break; 
                p.push( { x: dx + radius * Math.cos( nextAngle ), y: dy + radius * Math.sin( nextAngle ) });
            } 
        } else {
            var i = -1;
            while( true ){
                angle = i*angleInc;
                i++;
                nextAngle = angle + start; 
                if( angle >= ( dA + angleInc ) ) break; 
                p.push( { x: dx + radius * Math.cos( nextAngle ), y: dy + radius * Math.sin( nextAngle ) });
            } 
        }
        p.reverse();
        return p;
    }
    
    public static inline function horizontalWavePoints( x_: Float, dx_: Float, y_: Float, amplitude: Float, sides: Int, repeats: Float ):Array<Point>{         
        var p: Array<Point> = new Array<Point>(); 
        var dx: Float = 0;
        var angleInc: Float = (Math.PI*2)/sides;
        var len: Int = Std.int( sides*repeats );
        for( i in 0...len ) p.push( { x: x_ + (dx+=dx_), y: y_ + amplitude * Math.sin( i*angleInc ) });
        return p;
    }
    
    public static inline function verticalWavePoints( x_: Float, y_: Float, dy_: Float, amplitude: Float, sides: Int, repeats: Float ):Array<Point>{         
        var p: Array<Point> = new Array<Point>(); 
        var dy: Float = 0;
        var angleInc: Float = (Math.PI*2)/sides;
        var len: Int = Std.int( sides*repeats );
        for( i in 0...len ) p.push( { y: y_ + (dy+=dy_), x: x_ + amplitude * Math.sin( i*angleInc ) });
        return p;
    }
    
	public static inline function quadCurve( p0, p1, p2 ): Array<Point> {
        var p: Array<Point> = new Array<Point>(); 
		var approxDistance = distance( p0, p1 ) + distance( p1, p2 );
		var factor = 2;
		var v: { x: Float, y: Float };
		if( approxDistance == 0 ) approxDistance = 0.000001;
		var step = Math.min( 1/( approxDistance*0.707 ), 0.2 );
		var arr = [ p0, p1, p2 ];
		var t = 0.0;
		v = quadraticBezier( 0.0, arr );
		p.push( { x: v.x, y: v.y } );
		t += step;
		while( t < 1 ){
			v = quadraticBezier( t, arr );
			p.push( { x: v.x, y: v.y } );
			t += step;
		}
		v = quadraticBezier( 1.0, arr );
		p.push( { x: v.x, y: v.y } );
        //p.reverse();
        return p;
	}
    public static inline function distance(     p0: { x: Float, y: Float }
                                            ,   p1: { x: Float, y: Float }
                                            ): Float {
        var x = p0.x - p1.x;
        var y = p0.y - p1.y;
        return Math.sqrt( x*x + y*y );
    }
    // from divtastic3 and hxDeadalus wings.data.MathPoints
    public inline static function quadraticBezier(  t: Float
                                                ,   arr: Array<{ x: Float, y: Float }>
                                                ): { x: Float,y: Float } {
                                                    return {  x: _quadraticBezier( t, arr[0].x, arr[1].x, arr[2].x )
                                                            , y: _quadraticBezier( t, arr[0].y, arr[1].y, arr[2].y ) };
    }

    private inline static function _quadraticBezier ( t: Float
                                                    , startPoint: Float
                                                    , controlPoint: Float
                                                    , endPoint: Float
                                                    ): Float {
        var u = 1 - t;
        return Math.pow( u, 2) * startPoint + 2 * u * t * controlPoint + Math.pow( t, 2 ) * endPoint;
    }

    public static inline function generateMidPoints( arr: Array<{ x: Float, y: Float }>
                                                    ): Array<{ x: Float, y: Float }>{
        var out: Array<{ x: Float, y: Float }> = [];
        var a: { x: Float, y: Float };
        var b: { x: Float, y: Float };
        var len = arr.length - 2;
        for( i in 0...len ){
            a = arr[ i ];
            b = arr[ i + 1 ];
            out.push( { x: ( b.x + a.x )/2, y: ( b.y + a.y )/2 });
            out.push( { x: b.x, y: b.y } );
        }
        a = arr[0];
        out.unshift( { x: a.x, y: a.y } );
        out.unshift( { x: a.x, y: a.y } );
        b = arr[ arr.length - 1 ];
        out.push( { x: b.x, y: b.y } );
        out.push( { x: b.x, y: b.y } );
        out.push( { x: b.x, y: b.y } );
        return out;
    }
    
    
}