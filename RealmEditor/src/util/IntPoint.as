package util
{
   import flash.geom.Matrix;
   import flash.geom.Point;
   
   public class IntPoint
   {
       
      
      public var x_:int;
      
      public var y_:int;
      
      public function IntPoint(x:int = 0, y:int = 0)
      {
         super();
         this.x_ = x;
         this.y_ = y;
      }

      public static function fromPoint(p:Point) : IntPoint
      {
         return new IntPoint(Math.round(p.x),Math.round(p.y));
      }
      
      public function x() : int
      {
         return this.x_;
      }
      
      public function y() : int
      {
         return this.y_;
      }
      
      public function setX(x:int) : void
      {
         this.x_ = x;
      }
      
      public function setY(y:int) : void
      {
         this.y_ = y;
      }
      
      public function clone() : IntPoint
      {
         return new IntPoint(this.x_,this.y_);
      }
      
      public function same(p:IntPoint) : Boolean
      {
         return this.x_ == p.x_ && this.y_ == p.y_;
      }
      
      public function distanceAsInt(p:IntPoint) : int
      {
         var dx:int = p.x_ - this.x_;
         var dy:int = p.y_ - this.y_;
         return Math.round(Math.sqrt(dx * dx + dy * dy));
      }
      
      public function distanceAsNumber(p:IntPoint) : Number
      {
         var dx:int = p.x_ - this.x_;
         var dy:int = p.y_ - this.y_;
         return Math.sqrt(dx * dx + dy * dy);
      }
      
      public function distanceToPoint(p:Point) : Number
      {
         var dx:int = p.x - this.x_;
         var dy:int = p.y - this.y_;
         return Math.sqrt(dx * dx + dy * dy);
      }
      
      public function trunc1000() : IntPoint
      {
         return new IntPoint(int(this.x_ / 1000) * 1000,int(this.y_ / 1000) * 1000);
      }
      
      public function round1000() : IntPoint
      {
         return new IntPoint(Math.round(this.x_ / 1000) * 1000,Math.round(this.y_ / 1000) * 1000);
      }
      
      public function distanceSquared(p:IntPoint) : int
      {
         var dx:int = p.x() - this.x_;
         var dy:int = p.y() - this.y_;
         return dx * dx + dy * dy;
      }
      
      public function toPoint() : Point
      {
         return new Point(this.x_,this.y_);
      }
      
      public function transform(m:Matrix) : IntPoint
      {
         var p:Point = m.transformPoint(this.toPoint());
         return new IntPoint(Math.round(p.x),Math.round(p.y));
      }
      
      public function toString() : String
      {
         return "(" + this.x_ + ", " + this.y_ + ")";
      }
   }
}
