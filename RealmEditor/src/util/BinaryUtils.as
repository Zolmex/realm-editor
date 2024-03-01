package util {
import flash.utils.ByteArray;

public class BinaryUtils {
    private static const MaxBytesWithoutOverflow:int = 4;

    public static function Read7BitEncodedInt(data:ByteArray):int {
        // Unlike writing, we can't delegate to the 64-bit read on
        // 64-bit platforms. The reason for this is that we want to
        // stop consuming bytes if we encounter an integer overflow.

        var result:uint = 0;
        var byteReadJustNow:int;

        // Read the integer 7 bits at a time. The high bit
        // of the byte when on means to continue reading more bytes.
        //
        // There are two failure cases: we've read more than 5 bytes,
        // or the fifth byte is about to cause integer overflow.
        // This means that we can read the first 4 bytes without
        // worrying about integer overflow.

        for (var shift:int = 0; shift < MaxBytesWithoutOverflow * 7; shift += 7) {
            // ReadByte handles end of stream cases for us.
            byteReadJustNow = data.readByte();
            result |= (byteReadJustNow & uint(0x7F)) << shift;

            if (byteReadJustNow <= uint(0x7F)) {
                return int(result); // early exit
            }
        }

        // Read the 5th byte. Since we already read 28 bits,
        // the value of this byte must fit within 4 bits (32 - 28),
        // and it must not have the high bit set.

        byteReadJustNow = data.readByte();
        if (byteReadJustNow > uint(15)) {
            throw new Error("Bad 7-bit encoded integer bit");
        }

        result |= uint(byteReadJustNow) << (MaxBytesWithoutOverflow * 7);
        return int(result);
    }

    public static function Write7BitEncodedInt(data:ByteArray, value:int):void {
        //Write out an int 7 bits at a time.  The high bit of the byte, when on, tells reader to continue reading more bytes.
        var v:int = value;

        while (v >= 0x80) {
            data.writeByte(v | 0x80);
            v >>= 7;
        }

        data.writeByte(v);
    }
}
}
