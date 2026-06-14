class ShazdehUtils {

    public static var i18nCache:Object = new Object();

    public static function randomNumber( minVal, maxVal ) {
        return minVal + Math.floor(Math.random( ) * (maxVal + 1 - minVal));
    }

    public static function ShuffleArray( input:Array ) {
        for (var i:Number = input.length-1; i >=0; i--) {
            var randomIndex:Number = Math.floor(Math.random()*(i+1));
            var itemAtIndex:Object = input[randomIndex];
            input[randomIndex] = input[i];
            input[i] = itemAtIndex;
        }
    }

    static function get_i18n( lookup:String ) {
        if ( ShazdehUtils.i18nCache[ lookup ] === undefined ) {
            var tf = _root.createTextField( 'temp', _root.getNextHighestDepth(), -100, -100, 0, 0 );
            tf.text = lookup;
            ShazdehUtils.i18nCache[ lookup ] = tf.text;
            tf.removeTextField();
        }

        return ShazdehUtils.i18nCache[ lookup ];
    }

    public static function str_replace( search, replace, subject ) {
        var temp = '';
        var searchIndex = -1;
        var startIndex = 0;

        while ((searchIndex = subject.indexOf(search, startIndex)) != -1) {
            temp += subject.substring(startIndex, searchIndex);
            temp += replace;
            startIndex = searchIndex + search.length;
        }

        return temp + subject.substring(startIndex);
    }

    public static function setText( input:TextField, text:String ) {
        var textFormat:TextFormat = input.getTextFormat();
        textFormat.font = '$EverywhereMediumFont';
        input.text = text;
        input.setTextFormat( textFormat );
    }

    public static function clampValue(a_val: Number, a_min: Number, a_max: Number): Number {
        return Math.min(a_max, Math.max(a_min, a_val));
    }

    /**
     * custom decimal to Hex
     * unlike toString(16) handles big numbers
     */
    public static function toHex( num:Number ) : String {
        if (num === 0) return "0";

        var hexDigits:String = "0123456789ABCDEF";
        var hexString:String = "";
        var isNegative:Boolean = num < 0;

        // Handle negative numbers by converting to two's complement for 32-bit integers
        if (isNegative) {
            num = 0xFFFFFFFF + num + 1;
        }

        while (num > 0) {
            var remainder = num % 16;  // Get the remainder when dividing by 16
            hexString = hexDigits.charAt(remainder) + hexString;  // Prepend the corresponding hex digit
            num = Math.floor(num / 16);  // Divide the number by 16 and continue
        }

        return '0x' + hexString;
    }

    public static function hexToNum( hexStr ) : Number {
        var hexDigits:String = "0123456789ABCDEF";
        var num:Number = 0;
        var isNegative:Boolean = false;

        // If the hex string starts with a negative two's complement, treat it as negative
        if (hexStr.length === 8 && hexStr[0].toUpperCase() === "F") {
            isNegative = true;
        }

        hexStr = hexStr.toUpperCase();  // Convert to uppercase to handle both 'a-f' and 'A-F'

        for (var i = 0; i < hexStr.length; i++) {
            var currentChar = hexStr.charAt(i);
            var currentVal = hexDigits.indexOf(currentChar);  // Get the numeric value for each hex digit

            if (currentVal === -1) {
                return 0;
            }

            num = num * 16 + currentVal;  // Shift previous value and add current hex digit value
        }

        // If it's a negative number (two's complement), convert it back
        if ( isNegative ) {
            num = num - 0x100000000;
        }

        return num;
    }

    /**
     * Search haystack for needle, returns the index of found item, otherwise -1
     */
    public static function array_search( needle, haystack:Array ) : Number {
        for ( var i = 0; i < haystack.length; i++ ) {
            if ( haystack[ i ] === needle ) {
                return i;
            }
        }

        return -1;
    }

    public static function setScale(mc:MovieClip) {
        // Default Stage height for 16:9 aspect ratio
        var defaultHeight:Number = 720;

        // Check if the visible height is less than the default
        if (Stage.visibleRect.height < defaultHeight) {
            // Calculate the scaling factor based on height to maintain aspect ratio
            var heightScale:Number = (Stage.visibleRect.height / mc._height) * 100;

            // Apply the scale to the MovieClip
            mc._xscale = heightScale;
            mc._yscale = heightScale;
        }
    }

    public static function setPosition(mc:MovieClip) {
        var minXY: Object = {x: Stage.visibleRect.x + Stage.safeRect.x, y: Stage.visibleRect.y + Stage.safeRect.y};
        var maxXY: Object = {x: Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x, y: Stage.visibleRect.y + Stage.visibleRect.height - Stage.safeRect.y};
        mc._parent.globalToLocal(minXY);
        mc._parent.globalToLocal(maxXY);
        mc._y = ( ( ( maxXY.y - minXY.y ) / 2 ) + minXY.y ) - ( mc._height / 2 );
        mc._x = ( ( ( maxXY.x - minXY.x ) / 2 ) + minXY.x ) - ( mc._width / 2 );
    }

    function LogObject( obj ) {
        var s = '';
        for ( var i in obj ) {
            s += i + ': ' + obj[i] + ';\n';
        }
        skse.Log(s);
    }
}