package util
{
   public class Trig
   {
      
      public static const toDegrees:Number = 180 / Math.PI;
      
      public static const toRadians:Number = Math.PI / 180;
       
      
      public function Trig(se:StaticEnforcer)
      {
         super();
      }
      
      public static function slerp(fromAngle:Number, toAngle:Number, f:Number) : Number
      {
         var angle:Number = Number.MAX_VALUE;
         if(fromAngle > toAngle)
         {
            if(fromAngle - toAngle > Math.PI)
            {
               angle = fromAngle * (1 - f) + (toAngle + 2 * Math.PI) * f;
            }
            else
            {
               angle = fromAngle * (1 - f) + toAngle * f;
            }
         }
         else if(toAngle - fromAngle > Math.PI)
         {
            angle = (fromAngle + 2 * Math.PI) * (1 - f) + toAngle * f;
         }
         else
         {
            angle = fromAngle * (1 - f) + toAngle * f;
         }
         if(angle < -Math.PI || angle > Math.PI)
         {
            angle = boundToPI(angle);
         }
         return angle;
      }
      
      public static function angleDiff(fromAngle:Number, toAngle:Number) : Number
      {
         if(fromAngle > toAngle)
         {
            if(fromAngle - toAngle > Math.PI)
            {
               return toAngle + 2 * Math.PI - fromAngle;
            }
            return fromAngle - toAngle;
         }
         if(toAngle - fromAngle > Math.PI)
         {
            return fromAngle + 2 * Math.PI - toAngle;
         }
         return toAngle - fromAngle;
      }
      
      public static function sin(x:Number) : Number
      {
         var sin:Number = NaN;
         if(x < -Math.PI || x > Math.PI)
         {
            x = boundToPI(x);
         }
         if(x < 0)
         {
            sin = 1.27323954 * x + 0.405284735 * x * x;
            if(sin < 0)
            {
               sin = 0.225 * (sin * -sin - sin) + sin;
            }
            else
            {
               sin = 0.225 * (sin * sin - sin) + sin;
            }
         }
         else
         {
            sin = 1.27323954 * x - 0.405284735 * x * x;
            if(sin < 0)
            {
               sin = 0.225 * (sin * -sin - sin) + sin;
            }
            else
            {
               sin = 0.225 * (sin * sin - sin) + sin;
            }
         }
         return sin;
      }
      
      public static function cos(x:Number) : Number
      {
         return sin(x + Math.PI / 2);
      }
      
      public static function atan2(y:Number, x:Number) : Number
      {
         var atan:Number = NaN;
         if(x == 0)
         {
            if(y < 0)
            {
               return -Math.PI / 2;
            }
            if(y > 0)
            {
               return Math.PI / 2;
            }
            return undefined;
         }
         if(y == 0)
         {
            if(x < 0)
            {
               return Math.PI;
            }
            return 0;
         }
         if((x > 0?x:-x) > (y > 0?y:-y))
         {
            atan = (x < 0?-Math.PI:0) + atan2Helper(y,x);
         }
         else
         {
            atan = (y > 0?Math.PI / 2:-Math.PI / 2) - atan2Helper(x,y);
         }
         if(atan < -Math.PI || atan > Math.PI)
         {
            atan = boundToPI(atan);
         }
         return atan;
      }
      
      public static function atan2Helper(y:Number, x:Number) : Number
      {
         var v:Number = y / x;
         var total:Number = v;
         var nom:Number = v;
         var i:Number = 1;
         var sign:int = 1;
         do
         {
            i = i + 2;
            sign = sign > 0?int(-1):int(1);
            nom = nom * v * v;
            total = total + sign * nom / i;
         }
         while((nom > 0.01 || nom < -0.01) && i <= 11);
         
         return total;
      }
      
      public static function boundToPI(x:Number) : Number
      {
         var v:int = 0;
         if(x < -Math.PI)
         {
            v = (int(x / -Math.PI) + 1) / 2;
            x = x + v * 2 * Math.PI;
         }
         else if(x > Math.PI)
         {
            v = (int(x / Math.PI) + 1) / 2;
            x = x - v * 2 * Math.PI;
         }
         return x;
      }
      
      public static function boundTo180(x:Number) : Number
      {
         var v:int = 0;
         if(x < -180)
         {
            v = (int(x / -180) + 1) / 2;
            x = x + v * 360;
         }
         else if(x > 180)
         {
            v = (int(x / 180) + 1) / 2;
            x = x - v * 360;
         }
         return x;
      }
   }
}

class StaticEnforcer
{
    
   
   function StaticEnforcer()
   {
      super();
   }
}
