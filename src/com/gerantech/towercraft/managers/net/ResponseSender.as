package com.gerantech.towercraft.managers.net
{
import com.gerantech.mmory.core.constants.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.vo.BattleData;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

public class ResponseSender
{
	private var actived:Boolean = true;
	private var battleData:BattleData ;
	public function ResponseSender(battleData:BattleData)
	{
		this.battleData = battleData;
	}

	public function summonUnit(type:int, x:Number, y:Number, time:Number):void
	{
		var params:ISFSObject = new SFSObject();
		params.putInt("t", type);
		params.putDouble("x", x);
		params.putDouble("y", y);
		params.putDouble("time", time);
		send(SFSCommands.BATTLE_SUMMON, params);
	}

	public function start():void
	{
		send(SFSCommands.BATTLE_START, new SFSObject(), false);			
	}

	public function leave(retryMode:Boolean=false):void
	{
		var params:SFSObject = new SFSObject();
		if( retryMode )
			params.putBool("retryMode", true);
		send(SFSCommands.BATTLE_LEAVE, params, false);			
		this.actived = false;
	}

	public function sendSticker(stickerType:int):void
	{
		var params:SFSObject = new SFSObject();
		params.putInt("t", stickerType);
		send(SFSCommands.BATTLE_SEND_STICKER, params);			
	}

	private function send (extCmd:String, params:ISFSObject, dislabledForSpectators:Boolean = true) : Boolean
	{
		if( !actived )
			return false;
		if( dislabledForSpectators && this.battleData.userType > 0 )
			return false;
		if( this.battleData.roomId > -1 )
			params.putInt("r", this.battleData.roomId);
		SFSConnection.instance.sendExtensionRequest(extCmd, params);
		return true;
	}
}
}