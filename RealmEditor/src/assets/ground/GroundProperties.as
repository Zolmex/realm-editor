package assets.ground
{
import assets.*;
   import flash.display.BitmapData;

import util.BitmapUtil;

public class GroundProperties
   {
       
      
      public var type_:int;
      
      public var id_:String;
      
      public var noWalk_:Boolean = true;

      public var damage_:int = 0;
      
      public var animate_:AnimateProperties;
      
      public var blendPriority_:int = -1;
      
      public var compositePriority_:int = 0;
      
      public var speed_:Number = 1.0;
      
      public var xOffset_:Number = 0;
      
      public var yOffset_:Number = 0;
      
      public var push_:Boolean = false;
      
      public var sink_:Boolean = false;
      
      public var sinking_:Boolean = false;
      
      public var randomOffset_:Boolean = false;
      
      public var hasEdge_:Boolean = false;
      
      private var edgeTD_:TextureData = null;
      
      private var cornerTD_:TextureData = null;
      
      private var innerCornerTD_:TextureData = null;
      
      private var edges_:Vector.<BitmapData> = null;
      
      private var innerCorners_:Vector.<BitmapData> = null;
      
      public var sameTypeEdgeMode_:Boolean = false;
      
      public var topTD_:TextureData = null;
      
      public var topAnimate_:AnimateProperties = null;
      
      public function GroundProperties(groundXML:XML)
      {
         this.animate_ = new AnimateProperties();
         super();
         this.type_ = int(groundXML.@type);
         this.id_ = String(groundXML.@id);
         this.noWalk_ = groundXML.hasOwnProperty("NoWalk");
         if(groundXML.hasOwnProperty("Damage"))
         {
            this.damage_ = int(groundXML.Damage);
         }
         this.push_ = groundXML.hasOwnProperty("Push");
         if(groundXML.hasOwnProperty("Animate"))
         {
            this.animate_.parseXML(XML(groundXML.Animate));
         }
         if(groundXML.hasOwnProperty("BlendPriority"))
         {
            this.blendPriority_ = int(groundXML.BlendPriority);
         }
         if(groundXML.hasOwnProperty("CompositePriority"))
         {
            this.compositePriority_ = int(groundXML.CompositePriority);
         }
         if(groundXML.hasOwnProperty("Speed"))
         {
            this.speed_ = Number(groundXML.Speed);
         }
         this.xOffset_ = Boolean(groundXML.hasOwnProperty("XOffset"))?Number(Number(groundXML.XOffset)):Number(0);
         this.yOffset_ = Boolean(groundXML.hasOwnProperty("YOffset"))?Number(Number(groundXML.YOffset)):Number(0);
         this.push_ = groundXML.hasOwnProperty("Push");
         this.sink_ = groundXML.hasOwnProperty("Sink");
         this.sinking_ = groundXML.hasOwnProperty("Sinking");
         this.randomOffset_ = groundXML.hasOwnProperty("RandomOffset");
         if(groundXML.hasOwnProperty("Edge"))
         {
            this.hasEdge_ = true;
            this.edgeTD_ = new TextureData(XML(groundXML.Edge));
            if(groundXML.hasOwnProperty("Corner"))
            {
               this.cornerTD_ = new TextureData(XML(groundXML.Corner));
            }
            if(groundXML.hasOwnProperty("InnerCorner"))
            {
               this.innerCornerTD_ = new TextureData(XML(groundXML.InnerCorner));
            }
         }
         this.sameTypeEdgeMode_ = groundXML.hasOwnProperty("SameTypeEdgeMode");
         if(groundXML.hasOwnProperty("Top"))
         {
            this.topTD_ = new TextureData(XML(groundXML.Top));
            this.topAnimate_ = new AnimateProperties();
            if(groundXML.hasOwnProperty("TopAnimate"))
            {
               this.topAnimate_.parseXML(XML(groundXML.TopAnimate));
            }
         }
      }
      
      public function getEdges() : Vector.<BitmapData>
      {
         if(!this.hasEdge_ || this.edges_ != null)
         {
            return this.edges_;
         }
         this.edges_ = new Vector.<BitmapData>(9);
         this.edges_[3] = this.edgeTD_.getTexture(0);
         this.edges_[1] = BitmapUtil.rotateBitmapData(this.edges_[3],1);
         this.edges_[5] = BitmapUtil.rotateBitmapData(this.edges_[3],2);
         this.edges_[7] = BitmapUtil.rotateBitmapData(this.edges_[3],3);
         if(this.cornerTD_ != null)
         {
            this.edges_[0] = this.cornerTD_.getTexture(0);
            this.edges_[2] = BitmapUtil.rotateBitmapData(this.edges_[0],1);
            this.edges_[8] = BitmapUtil.rotateBitmapData(this.edges_[0],2);
            this.edges_[6] = BitmapUtil.rotateBitmapData(this.edges_[0],3);
         }
         return this.edges_;
      }
      
      public function getInnerCorners() : Vector.<BitmapData>
      {
         if(this.innerCornerTD_ == null || this.innerCorners_ != null)
         {
            return this.innerCorners_;
         }
         this.innerCorners_ = this.edges_.concat();
         this.innerCorners_[0] = this.innerCornerTD_.getTexture(0);
         this.innerCorners_[2] = BitmapUtil.rotateBitmapData(this.innerCorners_[0],1);
         this.innerCorners_[8] = BitmapUtil.rotateBitmapData(this.innerCorners_[0],2);
         this.innerCorners_[6] = BitmapUtil.rotateBitmapData(this.innerCorners_[0],3);
         return this.innerCorners_;
      }
   }
}
