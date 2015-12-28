package;
import TwoLines;
class HeartTest {

    public inline static function outline( dx: Float, dy: Float, scale: Float ): Void {
        var pp: Array<Point> = [
            { x: dx - 27*scale, y: dy - 20*scale }, 
            { x: dx - 15*scale, y: dy - 30*scale }, 
            { x: dx + 1, y: dy - 15*scale -1 },
            { x: dx + 15*scale, y: dy - 30*scale },
            { x: dx + 27*scale, y: dy - 20*scale },
            { x: dx + 34*scale, y: dy - 5*scale },
            { x: dx + 20*scale, y: dy + 6*scale },
            { x: dx + 25*scale, y: dy + 1 },
            { x: dx - 1, y: dy + 30*scale },
            { x: dx - 25*scale, y: dy + 1},
            { x: dx - 20*scale, y: dy + 6*scale },
            { x: dx - 34*scale, y: dy - 5*scale },
            { x: dx - 28*scale, y: dy - 20*scale },
            { x: dx - 27*scale, y: dy - 20*scale }];
            pp.reverse();
        var curvePoints:Array<Point>;
        var curveLen: Int;
        for( i in 0...(pp.length-1) ){
            if( (i-1)%2 == 0 ){
                curvePoints = TwoLines.quadCurve( pp[i], pp[i+1], pp[i+2] );
                curveLen = curvePoints.length;
                TwoLines.drawBeginLine( curvePoints[ 0 ], curvePoints[ 1 ], 25 );
                TwoLines.drawEndLine( curvePoints[ curveLen - 2 ], curvePoints[ curveLen - 1 ], 25 );
                TwoLines.createTriangles( curvePoints );
            }
        }
    
    }


}