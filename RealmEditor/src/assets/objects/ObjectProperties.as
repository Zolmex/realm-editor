package assets.objects
{
import assets.*;
   import flash.utils.Dictionary;
   
   public class ObjectProperties
   {
       
      
      public var type_:int;
      
      public var id_:String;
      
      public var displayId_:String;
      
      public var shadowSize_:int;
      
      public var isPlayer_:Boolean = false;
      
      public var isEnemy_:Boolean = false;
      
      public var drawOnGround_:Boolean = false;
      
      public var drawUnder_:Boolean = false;
      
      public var occupySquare_:Boolean = false;
      
      public var fullOccupy_:Boolean = false;
      
      public var enemyOccupySquare_:Boolean = false;
      
      public var static_:Boolean = false;
      
      public var noMiniMap_:Boolean = false;
      
      public var protectFromGroundDamage_:Boolean = false;
      
      public var protectFromSink_:Boolean = false;
      
      public var z_:Number = 0;
      
      public var flying_:Boolean = false;
      
      public var color_:uint = 16777215;
      
      public var showName_:Boolean = false;
      
      public var dontFaceAttacks_:Boolean = false;
      
      public var bloodProb_:Number = 0.0;
      
      public var bloodColor_:uint = 16711680;
      
      public var shadowColor_:uint = 0;
      
      public var sounds_:Object = null;
      
      public var portrait_:TextureData = null;
      
      public var minSize_:int = 100;
      
      public var maxSize_:int = 100;
      
      public var sizeStep_:int = 5;
      
      public var whileMoving_:WhileMovingProperties = null;
      
      public var oldSound_:String = null;
      
      public var projectiles_:Dictionary;
      
      public var angleCorrection_:Number = 0;
      
      public var rotation_:Number = 0;
      
      public function ObjectProperties(objectXML:XML)
      {
         var projectileXML:XML = null;
         var soundXML:XML = null;
         var bulletType:int = 0;
         this.projectiles_ = new Dictionary();
         super();
         if(objectXML == null)
         {
            return;
         }
         this.type_ = int(objectXML.@type);
         this.id_ = String(objectXML.@id);
         this.displayId_ = this.id_;
         if(objectXML.hasOwnProperty("DisplayId"))
         {
            this.displayId_ = objectXML.DisplayId;
         }
         this.shadowSize_ = Boolean(objectXML.hasOwnProperty("ShadowSize"))?int(objectXML.ShadowSize):int(100);
         this.isPlayer_ = objectXML.hasOwnProperty("Player");
         this.isEnemy_ = objectXML.hasOwnProperty("Enemy");
         this.drawOnGround_ = objectXML.hasOwnProperty("DrawOnGround");
         if(this.drawOnGround_ || objectXML.hasOwnProperty("DrawUnder"))
         {
            this.drawUnder_ = true;
         }
         this.occupySquare_ = objectXML.hasOwnProperty("OccupySquare");
         this.fullOccupy_ = objectXML.hasOwnProperty("FullOccupy");
         this.enemyOccupySquare_ = objectXML.hasOwnProperty("EnemyOccupySquare");
         this.static_ = objectXML.hasOwnProperty("Static");
         this.noMiniMap_ = objectXML.hasOwnProperty("NoMiniMap");
         this.protectFromGroundDamage_ = objectXML.hasOwnProperty("ProtectFromGroundDamage");
         this.protectFromSink_ = objectXML.hasOwnProperty("ProtectFromSink");
         this.flying_ = objectXML.hasOwnProperty("Flying");
         this.showName_ = objectXML.hasOwnProperty("ShowName");
         this.dontFaceAttacks_ = objectXML.hasOwnProperty("DontFaceAttacks");
         if(objectXML.hasOwnProperty("Z"))
         {
            this.z_ = Number(objectXML.Z);
         }
         if(objectXML.hasOwnProperty("Color"))
         {
            this.color_ = uint(objectXML.Color);
         }
         if(objectXML.hasOwnProperty("Size"))
         {
            this.minSize_ = this.maxSize_ = objectXML.Size;
         }
         else
         {
            if(objectXML.hasOwnProperty("MinSize"))
            {
               this.minSize_ = objectXML.MinSize;
            }
            if(objectXML.hasOwnProperty("MaxSize"))
            {
               this.maxSize_ = objectXML.MaxSize;
            }
            if(objectXML.hasOwnProperty("SizeStep"))
            {
               this.sizeStep_ = objectXML.SizeStep;
            }
         }
         this.oldSound_ = Boolean(objectXML.hasOwnProperty("OldSound"))?String(objectXML.OldSound):null;
         this.angleCorrection_ = Boolean(objectXML.hasOwnProperty("AngleCorrection"))?Number(Number(objectXML.AngleCorrection) * Math.PI / 4):Number(0);
         this.rotation_ = Boolean(objectXML.hasOwnProperty("Rotation"))?Number(objectXML.Rotation):Number(0);
         if(objectXML.hasOwnProperty("BloodProb"))
         {
            this.bloodProb_ = Number(objectXML.BloodProb);
         }
         if(objectXML.hasOwnProperty("BloodColor"))
         {
            this.bloodColor_ = uint(objectXML.BloodColor);
         }
         if(objectXML.hasOwnProperty("ShadowColor"))
         {
            this.shadowColor_ = uint(objectXML.ShadowColor);
         }
         for each(soundXML in objectXML.Sound)
         {
            if(this.sounds_ == null)
            {
               this.sounds_ = {};
            }
            this.sounds_[int(soundXML.@id)] = soundXML.toString();
         }
         if(objectXML.hasOwnProperty("Portrait"))
         {
            this.portrait_ = new TextureData(XML(objectXML.Portrait));
         }
         if(objectXML.hasOwnProperty("WhileMoving"))
         {
            this.whileMoving_ = new WhileMovingProperties(XML(objectXML.WhileMoving));
         }
      }

      public function getSize() : int
      {
         if(this.minSize_ == this.maxSize_)
         {
            return this.minSize_;
         }
         var maxSteps:int = (this.maxSize_ - this.minSize_) / this.sizeStep_;
         return this.minSize_ + int(Math.random() * maxSteps) * this.sizeStep_;
      }
   }
}

class WhileMovingProperties
{
    
   
   public var z_:Number = 0.0;
   
   public var flying_:Boolean = false;
   
   function WhileMovingProperties(whileMovingXML:XML)
   {
      super();
      if(whileMovingXML.hasOwnProperty("Z"))
      {
         this.z_ = Number(whileMovingXML.Z);
      }
      this.flying_ = whileMovingXML.hasOwnProperty("Flying");
   }
}
