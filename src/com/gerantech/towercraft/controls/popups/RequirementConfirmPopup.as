package com.gerantech.towercraft.controls.popups
{
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.mmory.core.exchanges.Exchanger;
import com.gerantech.mmory.core.utils.maps.IntIntMap;
import com.gerantech.towercraft.controls.buttons.MMOryButton;
import com.gerantech.towercraft.utils.StrUtils;

import feathers.events.FeathersEventType;

import starling.events.Event;

public class RequirementConfirmPopup extends ConfirmPopup
{
public var requirements:IntIntMap;
public var numHards:int;

public function RequirementConfirmPopup(message:String, requirements:IntIntMap)
{
	this.requirements = requirements;
	numHards =  Exchanger.toHard(player.deductions(requirements));
	super(message, numHards.toString(), loc("popup_decline_label"));
	this.numHards = numHards;
}

override protected function initialize():void
{
	super.initialize();
	acceptButton.label = StrUtils.getNumber(numHards);
	acceptButton.iconSize = MMOryButton.DEFAULT_ICON_SIZE;
	acceptButton.iconTexture = appModel.assets.getTexture("res-" + ResourceType.R4_CURRENCY_HARD);
}

override protected function acceptButton_triggeredHandler(event:Event):void
{
	if( numHards > player.get_hards() )
		dispatchEventWith(FeathersEventType.ERROR);
	else			
		dispatchEventWith(Event.SELECT);
	close();
}
}
}