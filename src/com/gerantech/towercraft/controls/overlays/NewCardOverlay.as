package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.mmory.core.scripts.ScriptEngine;
import com.gerantech.mmory.core.utils.maps.IntIntMap;
import com.gerantech.towercraft.controls.TileBackground;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.utils.StrUtils;
import com.gerantech.towercraft.views.effects.UIParticleSystem;

import dragonBones.events.EventObject;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingEvent;
import dragonBones.starling.StarlingTextureAtlasData;
import dragonBones.starling.StarlingTextureData;

import feathers.controls.AutoSizeMode;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import flash.geom.Rectangle;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.events.Event;
import starling.textures.SubTexture;
import starling.textures.Texture;

public class NewCardOverlay extends EarnOverlay
{
private var cardArmature:StarlingArmatureDisplay;
private var titleDisplay:ShadowLabel;
private var descriptionDisplay:RTLLabel;
public function NewCardOverlay(type:int)
{
	super(type);
	autoSizeMode = AutoSizeMode.STAGE;
	
}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	appModel.navigator.activeScreen.visible = false;// hide back items for better performance
}
override protected function defaultOverlayFactory(color:uint = 0, alpha:Number = 0.4) : DisplayObject
{
	var overlay:TileBackground = new TileBackground("home/pistole-tile", 0.8, true, 0x88);
	overlay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	overlay.touchable = true;
	return overlay;
}

override protected function addedToStageHandler(event:Event) : void
{
	super.addedToStageHandler(event);
	closeOnStage = false;
	
	appModel.sounds.setVolume("main-theme", 0.3);
}

override public function set outcomes(value:IntIntMap):void 
{
	super.outcomes = value;
	
	cardArmature = OpenBookOverlay.factory.buildArmatureDisplay("collect");
	cardArmature.scale = 2;
	cardArmature.touchable = false;
	cardArmature.x = stageWidth * 0.5;
	cardArmature.y = stageHeight * 0.8;
	cardArmature.addEventListener(EventObject.SOUND_EVENT, armature_soundEventHandler);
	addChild(cardArmature as DisplayObject);
	
	var rarity:int = ScriptEngine.getInt(ScriptEngine.T00_RARITY, type);
	// change card
	var texture:Texture = appModel.assets.getTexture("cards/" + type);
	var subtexture:SubTexture = new SubTexture(texture, new Rectangle(0, 0, texture.width, texture.height));
	StarlingTextureData(cardArmature.armature.getSlot("template").skinSlotData.getDisplay("cards/template-card").texture).texture = subtexture;
	
	// change rarity color
	var atlas:StarlingTextureAtlasData = OpenBookOverlay.factory.getTextureAtlasData("packs")[0] as StarlingTextureAtlasData;

	var std:StarlingTextureData =  atlas.textures["cards/back-" + rarity];
	subtexture = new SubTexture(atlas.texture, std.region);
	StarlingTextureData(cardArmature.armature.getSlot("back").skinSlotData.getDisplay("back").texture).texture = subtexture

	std =  atlas.textures["cards/frame-" + rarity];
	subtexture = new SubTexture(atlas.texture, std.region);
	StarlingTextureData(cardArmature.armature.getSlot("frame").skinSlotData.getDisplay("cards/frame-0").texture).texture = subtexture;
	
	cardArmature.animation.gotoAndPlayByTime("open", 0, 1);
	
	if( ResourceType.isCard(type) && !player.cards.exists(type) )
	{
		var labelDisplay:RTLLabel = new RTLLabel(loc("new_card_label"), 1, null, null, false, null, 1.3)
		labelDisplay.layoutData = new AnchorLayoutData(stageHeight * 0.23, NaN, NaN, NaN, 0);
		addChild(labelDisplay);
	}
}

// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= EVENT HANDLERS =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
protected function armature_soundEventHandler(event:StarlingEvent) : void
{
	if( event.eventObject.name == "scoreboard-0" )
		showDetails();

	appModel.sounds.addAndPlay(event.eventObject.name);
}
protected function showDetails() : void
{
	closeOnStage = true;
	var bounds:Rectangle = cardArmature.armature.getSlot("template").display.getBounds(this);
	
	// explode under card
	var explode:UIParticleSystem = new UIParticleSystem("explode", 0.1);
	explode.startSize *= 4;
	explode.speed *= 4
	explode.x = bounds.x + bounds.width * 0.5;
	explode.y = bounds.y + bounds.height * 0.5;
	addChildAt(explode, 1);
	
	// scraps particles
	var scraps:UIParticleSystem = new UIParticleSystem("scrap", 5);
	scraps.startSize *= 4;
	scraps.x = stageWidth * 0.5;
	scraps.y = -stageHeight * 0.1;
	addChildAt(scraps, 1);

	var title:String = ResourceType.isCard(type) && !player.cards.exists(type) ? loc("card_title_" + type) : ("x" + StrUtils.getNumber(_outcomes.values()[0]));
	var titleDisplay:ShadowLabel = new ShadowLabel(title, 1, 0, null, null, false, null, 1.9);
	titleDisplay.layoutData = new AnchorLayoutData(stageHeight * 0.55, NaN, NaN, NaN, 0);
	titleDisplay.scaleX = 0;
	Starling.juggler.tween(titleDisplay, 0.4, {scaleX: 1, transition:Transitions.EASE_OUT_BACK});
	addChild(titleDisplay);
}

override public function dispose() : void
{
	appModel.navigator.activeScreen.visible = true;
	appModel.sounds.setVolume("main-theme", 1);
	cardArmature.removeEventListener(EventObject.SOUND_EVENT, armature_soundEventHandler);
	super.dispose();
}
}
}