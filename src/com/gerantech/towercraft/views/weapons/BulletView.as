package com.gerantech.towercraft.views.weapons 
{
import com.gerantech.mmory.core.battle.BattleField;
import com.gerantech.mmory.core.battle.GameObject;
import com.gerantech.mmory.core.battle.bullets.Bullet;
import com.gerantech.mmory.core.battle.units.Card;
import com.gerantech.mmory.core.battle.units.Unit;
import com.gerantech.mmory.core.constants.CardTypes;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.views.ArtRules;
import com.gerantech.towercraft.views.BattleFieldView;
import com.gerantech.towercraft.views.units.UnitView;

import flash.geom.Point;

import starling.core.Starling;
import starling.display.Image;
import starling.display.MovieClip;
import starling.events.Event;
import starling.utils.MathUtil;

/**
* ...
* @author Mansour Djawadi
*/
public class BulletView extends Bullet
{
static public const _WIDTH:int = 512;
static public const _HEIGHT:int = 512;
public var bulletDisplayFactory:Function;
public var hitDisplayFactory:Function;
private var bulletDisplay:MovieClip;
private var shadowDisplay:Image;
private var rotation:Number;

public function BulletView(battleField:BattleField, unit:Unit, target:Unit, id:int, card:Card, side:int, x:Number, y:Number, z:Number, fx:Number, fy:Number, fz:Number) 
{
	super(battleField, unit, target, id, card, side, x, y, z, fx, fy, fz);
	rotation = MathUtil.normalizeAngle( -Math.atan2( -dx, -dy -dz * BattleField.CAMERA_ANGLE));
	
	if( bulletDisplayFactory == null )
		bulletDisplayFactory = defaultBulletDisplayFactory;
		
	if( hitDisplayFactory == null )
		hitDisplayFactory = defaultHitDisplayFactory;
}
override public	function set_state(value:int) : int
{
	if( this.state == value )
		return this.state;
	super.set_state(value);

	if( value == GameObject.STATE_1_DIPLOYED )
	{
		appModel.sounds.addAndPlayRandom(appModel.artRules.getArray(card.type, ArtRules.ATTACK_SFX));
		// fire effect
		if( unit != null )
		{
			var _x:Number = getSide_X(unit.x);
			var _y:Number = getSide_Y(unit.y);
			var rad:Number = Math.atan2(_x - getSide_X(target.x), _y - getSide_Y(target.y));
			var fireOffset:Point = appModel.artRules.getFlamePosition(card.type, rad);
			UnitView(unit).fireDisplayFactory(_x + fireOffset.x, _y + fireOffset.y, rad);
		}
		// bullet animation
		bulletDisplayFactory();
	}
	else if( value == GameObject.STATE_5_SHOOTING )
	{
		hitDisplayFactory();
		if( battleField.debugMode )
		{
			var damageAreaDisplay:Image = new Image(appModel.assets.getTexture("map/damage-range"));
			damageAreaDisplay.pivotX = damageAreaDisplay.width * 0.5;
			damageAreaDisplay.pivotY = damageAreaDisplay.height * 0.5;
			damageAreaDisplay.width = card.bulletDamageArea * 2;
			damageAreaDisplay.height = card.bulletDamageArea * 2 * BattleField.CAMERA_ANGLE;
			damageAreaDisplay.x = getSideX();
			damageAreaDisplay.y = getSideY();
			fieldView.effectsContainer.addChild(damageAreaDisplay);
			Starling.juggler.tween(damageAreaDisplay, 0.5, {scale:0, onComplete:damageAreaDisplay.removeFromParent, onCompleteArgs:[true]});
		}
	}
	return this.state;
}

override public function setPosition(x:Number, y:Number, z:Number, forced:Boolean = false) : Boolean
{
	if( disposed() )
		return false;

	if( !super.setPosition(x, y, z, forced) )
		return false;

	var _x:Number = this.getSideX();
	var _y:Number = this.getSideY();
	//if( card.type == 151 )
		//trace(id, "side:" + side," x:" + this.x, " y:" + this.y, " z:" + this.z, " _y:" + _y);
	
	if( bulletDisplay != null )
	{
		bulletDisplay.x = _x;
		bulletDisplay.y = _y + this.z * BattleField.CAMERA_ANGLE;
	}
	
	if( shadowDisplay != null )
	{
		shadowDisplay.x = _x;
		shadowDisplay.y = _y;
	} 

	return true;
}

private function defaultBulletDisplayFactory() : void 
{
	var bullet:String = appModel.artRules.get(card.type, ArtRules.BULLET);
	if( bullet == "" || bullet.substr(0,3) == "ps-" )
		return;
	bulletDisplay = new MovieClip(appModel.assets.getTextures("bullets/" + bullet + "/"));
	bulletDisplay.pivotX = bulletDisplay.width * 0.5;
	bulletDisplay.pivotY = bulletDisplay.height * 0.5;
	bulletDisplay.width = _WIDTH;
	bulletDisplay.height = _HEIGHT;
	bulletDisplay.rotation = rotation;
	fieldView.effectsContainer.addChild(bulletDisplay);
	if( bulletDisplay.numFrames > 1 )
	{
		bulletDisplay.loop = true;
		Starling.juggler.add(bulletDisplay);
		bulletDisplay.play();
	}
	
	if( CardTypes.isSpell(card.type) )
		return;
	
	shadowDisplay = new Image(appModel.assets.getTexture("bullets/shadow"));
	shadowDisplay.pivotY = shadowDisplay.height * 0.5;
	shadowDisplay.pivotX = shadowDisplay.width * 0.5;
	shadowDisplay.width = bulletDisplay.width;
	shadowDisplay.height = bulletDisplay.width * BattleField.CAMERA_ANGLE;
	shadowDisplay.alpha = 0.2;
	fieldView.shadowsContainer.addChild(shadowDisplay);
}

protected function defaultHitDisplayFactory() : void
{
	var hit:String = appModel.artRules.get(card.type, ArtRules.HIT);
	if( hit == "" )
		return;
		
	/*if( hit.substr(0,3) == "ps-" )
	{//"hits/" + hit + "/" +
		var hitParticle:BattleParticleSystem = new BattleParticleSystem(hit, hit, 1, true, true);
		hitParticle.x = getSideX();
		hitParticle.y = getSideY();
		fieldView.effectsContainer.addChild(hitParticle);
		return;
	}*/
	
	fieldView.shake(appModel.artRules.getNumber(card.type, ArtRules.HIT_SHAKE));
	
	var hitDisplay:MovieClip = new MovieClip(appModel.assets.getTextures("hits/" + hit), 45);
	hitDisplay.pivotX = hitDisplay.width * 0.5;
	hitDisplay.pivotY = hitDisplay.height * 0.5;
	hitDisplay.width = card.bulletDamageArea * 2.8;
	hitDisplay.scaleY = hitDisplay.scaleX;
	hitDisplay.x = getSideX();
	hitDisplay.y = getSideY();
	fieldView.effectsContainer.addChild(hitDisplay);
	hitDisplay.play();
	Starling.juggler.add(hitDisplay);
	hitDisplay.addEventListener(Event.COMPLETE, function() : void { Starling.juggler.remove(hitDisplay); hitDisplay.removeFromParent(true); });

	appModel.sounds.addAndPlayRandom(appModel.artRules.getArray(card.type, ArtRules.HIT_SFX));
}

override public function dispose():void
{
	if( shadowDisplay != null )
		shadowDisplay.removeFromParent(true);
	
	if( bulletDisplay != null )
	{
		Starling.juggler.remove(bulletDisplay);
		bulletDisplay.removeFromParent(true);
	}
	
	super.dispose();
}

protected function get appModel():		AppModel		{	return AppModel.instance;			}
protected function get fieldView():		BattleFieldView {	return appModel.battleFieldView;	}
}
}