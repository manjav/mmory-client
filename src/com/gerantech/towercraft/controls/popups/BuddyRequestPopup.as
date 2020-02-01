package com.gerantech.towercraft.controls.popups
{


    import com.gerantech.extensions.NativeAbilities;
    import com.gerantech.towercraft.controls.buttons.CustomButton;
    import com.gerantech.towercraft.controls.buttons.MMOryButton;
    import com.gerantech.towercraft.controls.texts.ShadowLabel;
    import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
    import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
    import com.gerantech.towercraft.models.AppModel;
    import com.gerantech.towercraft.themes.MainTheme;
    import com.gerantech.towercraft.utils.Localizations;
    import com.gerantech.towercraft.utils.Utils;
    import com.smartfoxserver.v2.core.SFSEvent;
    import com.smartfoxserver.v2.entities.data.SFSObject;

    import feathers.controls.LayoutGroup;
    import feathers.controls.TextInput;
    import feathers.layout.AnchorLayoutData;
    import feathers.layout.HorizontalAlign;
    import feathers.layout.VerticalAlign;
    import feathers.layout.VerticalLayout;

    import flash.geom.Rectangle;

    import starling.events.Event;

    public class BuddyRequestPopup extends SimplePopup
    {
        private var inviteCode:String;
        protected var closeButton:MMOryButton;
        private var addRequestInput:TextInput;
        
        public function BuddyRequestPopup(inviteCode:String)
        {
            super();
            this.inviteCode = inviteCode;
        }

        override protected function initialize():void
        {
            super.initialize();
            var _p:int = 100;
            var _h:int = 1000;
            var pad:int = 20;

            var container:LayoutGroup = new LayoutGroup();
            container.width = stageWidth-(_p*2);
            container.height = _h;
            var containerLayout:VerticalLayout = new VerticalLayout();
            containerLayout.horizontalAlign = HorizontalAlign.CENTER;
	        containerLayout.verticalAlign = VerticalAlign.MIDDLE;
            containerLayout.gap = pad;

            // Send invitation code layout
            var sendRequestGroup:LayoutGroup = new LayoutGroup();
            sendRequestGroup.width =  stageWidth-(_p*2);
            sendRequestGroup.height = ( _h * 0.5 ) - pad*0.5;
            var sendRequestGroupLayout:VerticalLayout = new VerticalLayout();
            sendRequestGroupLayout.horizontalAlign = HorizontalAlign.CENTER;
            sendRequestGroupLayout.verticalAlign = VerticalAlign.MIDDLE;
            sendRequestGroup.layout = sendRequestGroupLayout;
            
            var codeLabel:ShadowLabel = new ShadowLabel(loc("invitation_code") + ": " + this.inviteCode, 1, 0);
            /* codeLabel.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0); */
            sendRequestGroup.addChild(codeLabel);
            
            var sendRequestButton:CustomButton = new CustomButton();
            sendRequestButton.addEventListener(Event.TRIGGERED, sendRequestButton_triggeredHandler);
            sendRequestButton.label = loc("invite_friend");
            sendRequestButton.fontsize = 48;

            sendRequestButton.setSize(600, sendRequestButton.height);
            sendRequestGroup.addChild(sendRequestButton);

            // Add invitation code layout
            var addRequestGroup:LayoutGroup = new LayoutGroup();
            addRequestGroup.y = addRequestGroup.y + (( _h * 0.5 ) + pad);
            addRequestGroup.width = stageWidth-(_p*2);
            addRequestGroup.height = ( _h * 0.5 ) - pad*0.5;
            var addRequestGroupLayout:VerticalLayout = new VerticalLayout();
            addRequestGroupLayout.gap = pad;
            addRequestGroupLayout.horizontalAlign = HorizontalAlign.CENTER;
            addRequestGroupLayout.verticalAlign = VerticalAlign.MIDDLE;
            addRequestGroup.layout = addRequestGroupLayout;

            var addRequestInputLabel:ShadowLabel = new ShadowLabel(loc("invitation_enter_ask"), 1, 0);
            addRequestGroup.addChild(addRequestInputLabel);
            
            addRequestInput = new TextInput();
            addRequestInput.setSize(500, 90);
            addRequestGroup.addChild(addRequestInput);
            
            var addRequestButton:CustomButton = new CustomButton();
            addRequestButton.label = loc("invitation_send");
            addRequestGroup.addChild(addRequestButton);
            
            addRequestButton.addEventListener(Event.TRIGGERED, addRequestButton_triggeredHandler);
            
            container.addChild(sendRequestGroup);
            container.addChild(addRequestGroup);

            this.addChild(container);
            container.validate();

            // -=-=-=-=-=-=-=-=-=-=-=-=-=-[Close Button]-=-=-=-=-=-=-=-=-=-=-=-=-=-
            this.closeButton = new MMOryButton();
            this.closeButton.styleName = MainTheme.STYLE_BUTTON_SMALL_DANGER;;
            this.closeButton.iconTexture = appModel.assets.getTexture("theme/icon-cross");
            this.closeButton.width = 70;
            this.closeButton.height = 70;
            this.closeButton.layoutData = new AnchorLayoutData(15, 15);
            this.closeButton.addEventListener(Event.TRIGGERED, this.closeButton_triggeredHandler);
            
            this.addChild(closeButton);

            transitionIn.sourceBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.4,	stageWidth - _p * 2,	_h * 0.8);
            transitionIn.destinationBound = new Rectangle(_p,	stageHeight* 0.5 - _h * 0.5,	stageWidth - _p * 2,	_h * 1.0);

            rejustLayoutByTransitionData();
        }

        protected function closeButton_triggeredHandler(event:Event):void
        {
            dispatchEventWith(Event.CLOSE);
            close();
        }

        protected function sendRequestButton_triggeredHandler(e:Event):void
        {
            var subject:String = loc("invite_friend");
            var text:String = loc("invite_friend_message") + "\n" + Localizations.instance.get("buddy_invite_url", [player.invitationCode]);
            NativeAbilities.instance.shareText(subject, text);
            trace(subject, text);
        }

        protected function addRequestButton_triggeredHandler(e:Event):void
        {
            var sfs:SFSObject = new SFSObject();
            sfs.putText("invitationCode", this.addRequestInput.text);
            sfs.putText("udid", appModel.platform == AppModel.PLATFORM_ANDROID ? NativeAbilities.instance.deviceInfo.id : Utils.getPCUniqueCode());
            SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responseHandler);
            SFSConnection.instance.sendExtensionRequest(SFSCommands.BUDDY_ADD, sfs);
            function sfsConnection_responseHandler(event:SFSEvent):void
            {
                if (event.params.cmd != SFSCommands.BUDDY_ADD)
                    return SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responseHandler);
                appModel.navigator.addPopup(new InvitationPopup(event.params.params));
            }
        }

        override public function dispose():void
        {
            this.closeButton.removeEventListener(Event.TRIGGERED, this.closeButton_triggeredHandler);
            super.dispose();
        }
    }
}