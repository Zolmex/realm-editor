package assets
{
import assets.embed.EmbeddedData_AbyssOfDemonsCXML;
import assets.embed.EmbeddedData_CandyLandCXML;
import assets.embed.EmbeddedData_CaveOfAThousandTreasuresCXML;
import assets.embed.EmbeddedData_DyesCXML;
import assets.embed.EmbeddedData_EncountersCXML;
import assets.embed.EmbeddedData_EquipCXML;
import assets.embed.EmbeddedData_ForbiddenJungleCXML;
import assets.embed.EmbeddedData_GhostShipCXML;
import assets.embed.EmbeddedData_GroundCXML;
import assets.embed.EmbeddedData_HauntedCemeteryCXML;
import assets.embed.EmbeddedData_HighCXML;
import assets.embed.EmbeddedData_LowCXML;
import assets.embed.EmbeddedData_MadLabCXML;
import assets.embed.EmbeddedData_ManorOfTheImmortalsCXML;
import assets.embed.EmbeddedData_MidCXML;
import assets.embed.EmbeddedData_MonstersCXML;
import assets.embed.EmbeddedData_MountainsCXML;
import assets.embed.EmbeddedData_ObjectsCXML;
import assets.embed.EmbeddedData_OceanTrenchCXML;
import assets.embed.EmbeddedData_OryxCastleCXML;
import assets.embed.EmbeddedData_OryxChamberCXML;
import assets.embed.EmbeddedData_OryxWineCellarCXML;
import assets.embed.EmbeddedData_PermapetsCXML;
import assets.embed.EmbeddedData_PetsCXML;
import assets.embed.EmbeddedData_PirateCaveCXML;
import assets.embed.EmbeddedData_PlayersCXML;
import assets.embed.EmbeddedData_ProjectilesCXML;
import assets.embed.EmbeddedData_RegionsCXML;
import assets.embed.EmbeddedData_ShoreCXML;
import assets.embed.EmbeddedData_SkinsCXML;
import assets.embed.EmbeddedData_SnakePitCXML;
import assets.embed.EmbeddedData_SpriteWorldCXML;
import assets.embed.EmbeddedData_StaticObjectsCXML;
import assets.embed.EmbeddedData_TempObjectsCXML;
import assets.embed.EmbeddedData_TestingObjectsCXML;
import assets.embed.EmbeddedData_TextilesCXML;
import assets.embed.EmbeddedData_TombOfTheAncientsCXML;
import assets.embed.EmbeddedData_TutorialObjectsCXML;
import assets.embed.EmbeddedData_TutorialScriptCXML;
import assets.embed.EmbeddedData_UndeadLairCXML;

public class EmbeddedData
   {
      public static const PlayersCXML:Class = EmbeddedData_PlayersCXML;
      private static const GroundCXML:Class = EmbeddedData_GroundCXML;
      public static var groundFiles:Array = [new GroundCXML()];
      private static const ProjectilesCXML:Class = EmbeddedData_ProjectilesCXML;
      private static const EquipCXML:Class = EmbeddedData_EquipCXML;
      private static const SkinsCXML:Class = EmbeddedData_SkinsCXML;
      private static const DyesCXML:Class = EmbeddedData_DyesCXML;
      private static const TextilesCXML:Class = EmbeddedData_TextilesCXML;
      private static const PermapetsCXML:Class = EmbeddedData_PermapetsCXML;
      private static const ObjectsCXML:Class = EmbeddedData_ObjectsCXML;
      private static const TestingObjectsCXML:Class = EmbeddedData_TestingObjectsCXML;
      private static const StaticObjectsCXML:Class = EmbeddedData_StaticObjectsCXML;
      private static const TutorialObjectsCXML:Class = EmbeddedData_TutorialObjectsCXML;
      private static const MonstersCXML:Class = EmbeddedData_MonstersCXML;
      private static const PetsCXML:Class = EmbeddedData_PetsCXML;
      private static const TempObjectsCXML:Class = EmbeddedData_TempObjectsCXML;
      private static const ShoreCXML:Class = EmbeddedData_ShoreCXML;
      private static const LowCXML:Class = EmbeddedData_LowCXML;
      private static const MidCXML:Class = EmbeddedData_MidCXML;
      private static const HighCXML:Class = EmbeddedData_HighCXML;
      private static const MountainsCXML:Class = EmbeddedData_MountainsCXML;
      private static const EncountersCXML:Class = EmbeddedData_EncountersCXML;
      private static const OryxCastleCXML:Class = EmbeddedData_OryxCastleCXML;
      private static const TombOfTheAncientsCXML:Class = EmbeddedData_TombOfTheAncientsCXML;
      private static const SpriteWorldCXML:Class = EmbeddedData_SpriteWorldCXML;
      private static const UndeadLairCXML:Class = EmbeddedData_UndeadLairCXML;
      private static const OceanTrenchCXML:Class = EmbeddedData_OceanTrenchCXML;
      private static const ForbiddenJungleCXML:Class = EmbeddedData_ForbiddenJungleCXML;
      private static const OryxChamberCXML:Class = EmbeddedData_OryxChamberCXML;
      private static const OryxWineCellarCXML:Class = EmbeddedData_OryxWineCellarCXML;
      private static const ManorOfTheImmortalsCXML:Class = EmbeddedData_ManorOfTheImmortalsCXML;
      private static const PirateCaveCXML:Class = EmbeddedData_PirateCaveCXML;
      private static const SnakePitCXML:Class = EmbeddedData_SnakePitCXML;
      private static const AbyssOfDemonsCXML:Class = EmbeddedData_AbyssOfDemonsCXML;
      private static const GhostShipCXML:Class = EmbeddedData_GhostShipCXML;
      private static const MadLabCXML:Class = EmbeddedData_MadLabCXML;
      private static const CaveOfAThousandTreasuresCXML:Class = EmbeddedData_CaveOfAThousandTreasuresCXML;
      private static const CandyLandCXML:Class = EmbeddedData_CandyLandCXML;
      private static const HauntedCemeteryCXML:Class = EmbeddedData_HauntedCemeteryCXML;

      public static const skinsXML:XML = XML(new SkinsCXML());
      public static var objectFiles:Array = [new ProjectilesCXML(),new EquipCXML(),new DyesCXML(),new TextilesCXML(),new PermapetsCXML(),new PlayersCXML(),new ObjectsCXML(),new TestingObjectsCXML(),new StaticObjectsCXML(),new TutorialObjectsCXML(),new MonstersCXML(),new PetsCXML(),new TempObjectsCXML(),new ShoreCXML(),new LowCXML(),new MidCXML(),new HighCXML(),new MountainsCXML(),new EncountersCXML(),new OryxCastleCXML(),new TombOfTheAncientsCXML(),new SpriteWorldCXML(),new UndeadLairCXML(),new OceanTrenchCXML(),new ForbiddenJungleCXML(),new OryxChamberCXML(),new OryxWineCellarCXML(),new ManorOfTheImmortalsCXML(),new PirateCaveCXML(),new SnakePitCXML(),new AbyssOfDemonsCXML(),new GhostShipCXML(),new MadLabCXML(),new CaveOfAThousandTreasuresCXML(),new CandyLandCXML(),new HauntedCemeteryCXML()];
      private static const RegionsCXML:Class = EmbeddedData_RegionsCXML;
      public static var regionFiles:Array = [new RegionsCXML()];
      private static const TutorialScriptCXML:Class = EmbeddedData_TutorialScriptCXML;
      public static const tutorialXML:XML = XML(new TutorialScriptCXML());
       
      
      public function EmbeddedData()
      {
         super();
      }
   }
}
