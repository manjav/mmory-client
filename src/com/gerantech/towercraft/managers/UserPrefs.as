package com.gerantech.towercraft.managers
{
import com.gameanalytics.sdk.GAResourceFlowType;
import com.gameanalytics.sdk.GameAnalytics;
import com.gerantech.extensions.NativeAbilities;
import com.gerantech.mmory.core.constants.PrefsTypes;
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.mmory.core.constants.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.managers.oauth.OAuthManager;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.utils.Localizations;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.utils.setTimeout;

import starling.events.Event;
import starling.events.EventDispatcher;

public class UserPrefs extends EventDispatcher 
{
public function UserPrefs(){}
public function init() : void
{
	// tutorial first step
	setInt(PrefsTypes.TUTOR, PrefsTypes.T_000_FIRST_RUN);
	authenticateSocial();
	
	// select language with market index
	var loc:String = AppModel.instance.game.player.prefs.exists(PrefsTypes.SETTINGS_4_LOCALE) ? AppModel.instance.game.player.prefs.get(PrefsTypes.SETTINGS_4_LOCALE) : "0";
	if( loc == "0" )
		loc = Localizations.instance.getLocaleByTimezone(NativeAbilities.instance.getTimezone());
	changeLocale(loc, true);
}

public function changeLocale(locale:String, forced:Boolean=false) : void
{
	var prev:String = AppModel.instance.game.player.prefs.get(PrefsTypes.SETTINGS_4_LOCALE);
	if( !forced && prev == locale )
	{
		dispatchEventWith(Event.FATAL_ERROR);
		return;
	}
	
	Localizations.instance.addEventListener(Event.CHANGE, localizations_changeHandler);
	Localizations.instance.changeLocale(locale);
}

protected function localizations_changeHandler(event:Event) : void 
{
	Localizations.instance.removeEventListener(Event.CHANGE, localizations_changeHandler);
	
	var locale:String = event.data as String;
	setString(PrefsTypes.SETTINGS_4_LOCALE, locale);
	AppModel.instance.direction = Localizations.instance.getDir(locale);
	AppModel.instance.isLTR = AppModel.instance.direction == "ltr";
	AppModel.instance.align = AppModel.instance.isLTR ? "left" : "right";

	dispatchEventWith(Event.COMPLETE, false, locale);
}

public function setBool(key:int, value:Boolean):void
{
	setString(key, value.toString());
}
public function setInt(key:int, value:int):void
{
	if( key == PrefsTypes.TUTOR )
	{
		// prevent backward tutor steps
		if( AppModel.instance.game.player.getTutorStep() >= value )
			return;
		if( value == PrefsTypes.T_000_FIRST_RUN && GameAnalytics.isInitialized )

			GameAnalytics.addResourceEvent(GAResourceFlowType.SOURCE, ResourceType.getName(ResourceType.R4_CURRENCY_HARD), 
			AppModel.instance.game.player.getResource(ResourceType.R4_CURRENCY_HARD), "Initial", "Initial");

		if( GameAnalytics.isInitialized )
			GameAnalytics.addDesignEvent("tutorial:step-" + value);
	}
	
	setString(key, value.toString());
}
public function setFloat(key:int, value:Number):void
{
	setString(key, value.toString());
}
public function setString(key:int, value:String):void
{
	AppModel.instance.game.player.prefs.set(key, value);
	var params:SFSObject = new SFSObject();
	params.putInt("k", key);
	params.putText("v", value);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.PREFS, params);
}


/************************   AUTHENTICATE SOCIAL OR GAME SERVICES   ***************************/
public function authenticateSocial():void
{
	OAuthManager.instance.init( PrefsTypes.AUTH_41_GOOGLE , true);
	setTimeout(OAuthManager.instance.signin, 1000);
}
}
}