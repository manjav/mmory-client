package
{
import com.gameanalytics.sdk.GAErrorSeverity;
import com.gameanalytics.sdk.GameAnalytics;
import com.gerantech.mmory.core.constants.ExchangeType;
import com.gerantech.mmory.core.constants.ResourceType;
import com.gerantech.towercraft.Game;
import com.gerantech.towercraft.controls.screens.BattleScreen;
import com.gerantech.towercraft.controls.screens.SplashScreen;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.vo.Descriptor;
import com.gerantech.towercraft.utils.Localizations;
import com.tuarua.FirebaseANE;
import com.tuarua.firebase.FirebaseOptions;
import com.tuarua.fre.ANEError;

import feathers.events.FeathersEventType;

import flash.desktop.NativeApplication;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.display3D.Context3DProfile;
import flash.display3D.Context3DRenderMode;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.events.UncaughtErrorEvent;
import flash.utils.getTimer;

import haxe.Log;

import starling.core.Starling;

public class Main extends Sprite
{
public static var t:int;
private var starling:Starling;
private var splash:SplashScreen;

public function Main()
{
	Log.trace = function(v : * , p : * = null) : void {trace(p.fileName.substr(0,p.fileName.length-3) + "|" + p.methodName+":" + p.lineNumber + " =>  " + v); }
	var desc:Descriptor = AppModel.instance.descriptor;
	Localizations.instance.changeLocale(Localizations.instance.getLocaleByMarket(desc.market));
	/*var str:String = "";
	var ret:Number = -0.05;
	for( var level:int=1; level<=13; level++ )
		str += level + "[" + ((			ret + (Math.log(level) * 0.585) * (ret/Math.abs(ret))			)).toFixed(3) + "]   " ;
	trace(str);
	NativeApplication.nativeApplication.exit();
	return;*/
	// GameAnalytic Configurations
	GameAnalytics.config/*.setUserId("test_id").setResourceCurrencies(new <String>["gems", "coins"]).setResourceItemTypes(new <String>["boost", "lives"]).setCustomDimensions01(new <String>["ninja", "samurai"])*/
		/*.setBuildiOS(desc.versionNumber).setGameKeyAndroid(desc.analyticskey).setGameSecretAndroid(desc.analyticssec) */
		.setBuildAndroid(desc.versionNumber).setGameKeyAndroid(desc.analyticskey).setGameSecretAndroid(desc.analyticssec)
		.setResourceCurrencies(new <String>[ResourceType.getName(ResourceType.R1_XP), ResourceType.getName(ResourceType.R2_POINT), ResourceType.getName(ResourceType.R3_CURRENCY_SOFT), ResourceType.getName(ResourceType.R4_CURRENCY_HARD), ResourceType.getName(ResourceType.R6_TICKET)])
		.setResourceItemTypes(new <String>[ExchangeType.getName(ExchangeType.C0_HARD), ExchangeType.getName(ExchangeType.C10_SOFT), ExchangeType.getName(ExchangeType.C20_SPECIALS), ExchangeType.getName(ExchangeType.C30_BUNDLES), ExchangeType.getName(ExchangeType.C40_OTHERS), ExchangeType.getName(ExchangeType.BOOKS_50), ExchangeType.getName(ExchangeType.C70_TICKETS), ExchangeType.getName(ExchangeType.C80_EMOTES), ExchangeType.getName(ExchangeType.C100_FREES), ExchangeType.getName(ExchangeType.C110_BATTLES), ExchangeType.getName(ExchangeType.C120_MAGICS)]);
	if( GameAnalytics.isSupported )
	{
		try {
			GameAnalytics.init();
		} catch (error:Error) { trace(error.message);	}
	}
	
	t = getTimer();
	stage.scaleMode = StageScaleMode.NO_SCALE;
	stage.align = StageAlign.TOP_LEFT;
	AppModel.instance.aspectratio = this.stage.fullScreenWidth / this.stage.fullScreenHeight;

	this.mouseEnabled = this.mouseChildren = false;
	splash = new SplashScreen(stage);
	splash.addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, loaderInfo_completeHandler);

	loaderInfo.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);
	loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, loaderInfo_uncaughtErrorHandler);
	NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE, nativeApplication_invokeHandler);

	if (AppModel.instance.platform == AppModel.PLATFORM_ANDROID)
	{
		try
		{
			/**
			 * Here we will initalize firebase native extension, required for 
			 * Firebase Cloud Messaging.
			 */
			FirebaseANE.init();
			if(!FirebaseANE.isGooglePlayServicesAvailable)
			{
				trace("Google Play Service is not installed on device");
				// TODO: Requires handle method.
			}
			var firebaseOptions:FirebaseOptions = FirebaseANE.options;
			if (firebaseOptions)
			{
				trace("apiKey", firebaseOptions.apiKey);
				trace("googleAppId", firebaseOptions.googleAppId);
			}
		}
		catch (e:ANEError)
		{
			trace(e.errorID, e.message, e.getStackTrace(), e.source);
		}
	}
}

private function loaderInfo_completeHandler(event:Event):void
{
	if( event.currentTarget == this.loaderInfo )
		this.loaderInfo.removeEventListener(Event.COMPLETE, loaderInfo_completeHandler);
	else
		this.splash.removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, loaderInfo_completeHandler);
	
	if( this.loaderInfo.bytesLoaded == this.loaderInfo.bytesTotal && this.splash.transitionInCompleted )
		starStarling();
}

private function starStarling():void
{
	//var _ratio:Number = 1080 / stage.fullScreenWidth;
	//var _height:Number = Math.min(stage.fullScreenWidth * 2, stage.fullScreenHeight);
	this.starling = new Starling(Game, stage, null, null, Context3DRenderMode.AUTO, Context3DProfile.BASELINE_EXTENDED);
	this.starling.addEventListener("rootCreated", starling_rootCreatedHandler);
	this.starling.supportHighResolutions = true;
	this.starling.skipUnchangedFrames = true;
	this.starling.start();
	this.starling.stage.stageWidth  = 1080;
	this.starling.stage.stageHeight = 1080 * (stage.fullScreenHeight / stage.fullScreenWidth);
	//NativeAbilities.instance.showToast(stage.fullScreenWidth + "," + stage.fullScreenHeight + "," + this.starling.stage.stageWidth + "," + this.starling.stage.stageHeight + "," + this.starling.contentScaleFactor, 2);
	//this.starling.showStatsAt("right", "top", 1 / this.starling.contentScaleFactor);
	trace(stage.fullScreenWidth, stage.fullScreenHeight, this.starling.stage.stageWidth, this.starling.stage.stageHeight, this.starling.contentScaleFactor);
}

private function starling_rootCreatedHandler(event:Object):void
{
	this.stage.addEventListener(Event.DEACTIVATE, stage_deactivateHandler, false, 0, true);
}

protected function stage_deactivateHandler(event:Event):void
{
	if( !BattleScreen.IN_BATTLE )
	{
		this.starling.stop(true);
		this.stage.frameRate = 0;
	}
	this.stage.addEventListener(Event.ACTIVATE, stage_activateHandler, false, 0, true);
	AppModel.instance.sounds.muteAll(true);
	AppModel.instance.notifier.reset();
}
protected function stage_activateHandler(event:Event):void
{
	this.stage.removeEventListener(Event.ACTIVATE, stage_activateHandler);
	this.stage.frameRate = 60;
	this.starling.start();
	AppModel.instance.sounds.muteAll(false);
	AppModel.instance.notifier.clear();
}

protected function nativeApplication_invokeHandler(event:InvokeEvent):void
{
	AppModel.instance.invokes = event.arguments;
	if(AppModel.instance.navigator)
		AppModel.instance.navigator.handleInvokes();
}

protected function loaderInfo_uncaughtErrorHandler(event:UncaughtErrorEvent):void 
{
	var text:String;
	var severity:int;

	if( event.error is Error )
	{
		text =  event.error.getStackTrace();
		severity = GAErrorSeverity.CRITICAL;
	}
	else if( event.error is ErrorEvent )
	{
		text = event.error.text;
		severity = GAErrorSeverity.ERROR;
	}
	else
	{
		text = event.error.toString();
		severity = GAErrorSeverity.WARNING;
	}
	if(GameAnalytics.isInitialized)
		GameAnalytics.addErrorEvent(severity, text);
	// new GTStreamer(File.applicationStorageDirectory.resolvePath("log.txt"), null, null, null, false, false).save(text);
}
}
}