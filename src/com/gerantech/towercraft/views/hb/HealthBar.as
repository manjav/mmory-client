package com.gerantech.towercraft.views.hb
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.views.BattleFieldView;

import flash.geom.Rectangle;

import starling.display.Image;

public class HealthBar implements IHealthBar
{
static protected var SCALE_RECT:Rectangle = new Rectangle(3, 3, 1, 1);
protected var _side:int = -2;
protected var _value:Number = 0.0;
protected var _alpha:Number = 1.0;
protected var _width:Number = 48;
protected var _height:Number = 15;
protected var _maximum:Number = 1.0;
protected var sliderFillDisplay:Image;
protected var sliderBackDisplay:Image;
protected var filedView:BattleFieldView;

public function HealthBar(filedView:BattleFieldView, side:int, maximum:Number = 1)
{
	super();
	this.filedView = filedView;
	this.maximum = maximum;
	this.side = side;

	sliderBackDisplay = new Image(AppModel.instance.assets.getTexture("sliders/" + side + "/back"));
	sliderBackDisplay.scale9Grid = SCALE_RECT;
	sliderBackDisplay.touchable = false;
	sliderBackDisplay.width = width;
	sliderBackDisplay.height = height;
	sliderBackDisplay.visible = false;//value < maximum;
	filedView.guiImagesContainer.addChild(sliderBackDisplay);
	
	sliderFillDisplay = new Image(AppModel.instance.assets.getTexture("sliders/" + side + "/fill"));
	sliderFillDisplay.scale9Grid = SCALE_RECT;
	sliderFillDisplay.touchable = false;
	sliderFillDisplay.height = height;
	sliderFillDisplay.visible = false;//value < maximum;
	filedView.guiImagesContainer.addChild(sliderFillDisplay);
}

public function setPosition(x:Number, y:Number) : void
{
	if( sliderBackDisplay != null )
	{
		sliderBackDisplay.x = x - width * 0.5;
		sliderBackDisplay.y = y;
	}
	if( sliderFillDisplay != null )
	{
		sliderFillDisplay.x = x - width * 0.5;
		sliderFillDisplay.y = y;
	}
}

public function get value() : Number
{
	return _value;
}
public function set value(v:Number) : void
{
	if( _value == v )
		return;
	if( v > maximum )
		v = maximum;
	if( v < 0 )
		v = 0;
	_value = v;

	if( sliderFillDisplay != null )
	{
		sliderFillDisplay.visible = _value < maximum;
		if( sliderFillDisplay.visible )
			sliderFillDisplay.width =  width * (_value / maximum);
	}
	if( sliderBackDisplay != null )
		sliderBackDisplay.visible = _value < maximum;
}

public function get side():int
{
	return _side;
}
public function set side(value:int):void
{
	if( _side == value )
		return;
	_side = value;
	
	if( sliderBackDisplay != null )
		sliderBackDisplay.texture = AppModel.instance.assets.getTexture("sliders/" + _side + "/back");
	if( sliderFillDisplay != null )
		sliderFillDisplay.texture = AppModel.instance.assets.getTexture("sliders/" + _side + "/fill");
}

public function get maximum():Number
{
	return _maximum;
}
public function set maximum(value:Number):void
{
	_maximum = value;
}

public function get alpha():Number
{
	return _alpha;
}
public function set alpha(value:Number):void
{
	if( this._alpha == value )
		return;
	this._alpha = value;
	if( sliderBackDisplay != null )
		sliderBackDisplay.alpha = value;
	if( sliderFillDisplay != null )
		sliderFillDisplay.alpha = value;
}

public function dispose() : void 
{
	if( sliderBackDisplay != null )
		sliderBackDisplay.removeFromParent(true);
	if( sliderFillDisplay != null )
		sliderFillDisplay.removeFromParent(true);
}

public function get width():Number
{
	return this._width;
}
public function set width(value:Number):void
{
	if( this._width == value )
		return;
	this._width = value;
	if( sliderBackDisplay != null )
		sliderBackDisplay.width = width;

}

public function get height():Number
{
	return this._height;
}
public function set height(value:Number):void
{
	if( this._height == value )
		return;
	this._height = value;
}
}
}