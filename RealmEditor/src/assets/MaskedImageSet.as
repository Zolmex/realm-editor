package assets
{
   import flash.display.BitmapData;
   
   public class MaskedImageSet
   {
       
      
      public var images_:Vector.<MaskedImage>;
      
      public function MaskedImageSet()
      {
         this.images_ = new Vector.<MaskedImage>();
         super();
      }
      
      public function addFromBitmapData(images:BitmapData, masks:BitmapData, width:int, height:int) : void
      {
         var imagesSet:ImageSet = new ImageSet();
         imagesSet.addFromBitmapData(images,width,height);
         var masksSet:ImageSet = null;
         if(masks != null)
         {
            masksSet = new ImageSet();
            masksSet.addFromBitmapData(masks,width,height);
         }
         for(var i:int = 0; i < imagesSet.images_.length; i++)
         {
            this.images_.push(new MaskedImage(imagesSet.images_[i],masksSet == null?null:masksSet.images_[i]));
         }
      }
      
      public function addFromMaskedImage(maskedImage:MaskedImage, width:int, height:int) : void
      {
         this.addFromBitmapData(maskedImage.image_,maskedImage.mask_,width,height);
      }
   }
}
