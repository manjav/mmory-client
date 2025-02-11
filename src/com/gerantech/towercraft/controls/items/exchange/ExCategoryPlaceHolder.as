package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.mmory.core.constants.ExchangeType;
import com.gerantech.mmory.core.exchanges.ExchangeItem;
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.buttons.IndicatorButton;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.controls.tooltips.BaseTooltip;
import com.gerantech.towercraft.models.vo.ShopLine;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;

import feathers.controls.List;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalAlign;

import flash.geom.Rectangle;

import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Image;
import starling.events.Event;

public class ExCategoryPlaceHolder extends TowersLayout
{
  static public const HEADER_SIZE:int = 110;
  static public const BACKGROUND_SCALEGRID:Rectangle = new Rectangle(16, 104, 1, 1);

  static private const BGS:Object = {-1:"shop/cate-blue", 0:"shop/cate-purple", 10:"shop/cate-yellow", 70:"shop/cate-red"};
  static public function GET_BG(category:int) : String
  {
    return BGS.hasOwnProperty(category) ? BGS[category] : BGS[-1];
  }
  
  static private const HEIGHTS:Object = {-1:400, 0:420, 10:420, 20:420, 30:600};
  static public function GET_HEIGHT(category:int) : int
  {
    return HEIGHTS.hasOwnProperty(category) ? HEIGHTS[category] : HEIGHTS[-1];
  }

  private var list:List;
  private var owner:List;
  private var line:ShopLine;
  private var showInfo:Boolean;
  private var listCollection:ListCollection;
  private var countdownDisplay:CountdownLabel;

  public function ExCategoryPlaceHolder(line:ShopLine, owner:List, showInfo:Boolean = true)
  {
    super();
    this.line = line;
    this.owner = owner;
    this.showInfo = showInfo;
    this.layout = new AnchorLayout();
    this.listCollection = new ListCollection();
  }
  
  override protected function initialize():void
  {
    super.initialize();
    this.backgroundSkin = new Image(appModel.assets.getTexture(GET_BG(this.line.category)));
    Image(this.backgroundSkin).scale9Grid = BACKGROUND_SCALEGRID;

    var listLayout:TiledRowsLayout = new TiledRowsLayout();
    listLayout.verticalGap = 32;
    listLayout.horizontalGap = 42;
    listLayout.useSquareTiles = false;
    listLayout.useVirtualLayout = false;
    listLayout.requestedColumnCount = 3;
    listLayout.paddingLeft = listLayout.paddingRight = 28;
    listLayout.paddingBottom = listLayout.paddingTop = 46;
    listLayout.typicalItemHeight = GET_HEIGHT(this.line.category);
    listLayout.tileVerticalAlign = listLayout.verticalAlign = VerticalAlign.TOP;
    listLayout.tileHorizontalAlign = listLayout.horizontalAlign = HorizontalAlign.LEFT;
    listLayout.typicalItemWidth = Math.floor((this.width - listLayout.paddingLeft - listLayout.paddingRight - listLayout.horizontalGap * 2) / 3);
    
    this.list = new List();
    this.list.layout = listLayout;
    this.list.layoutData = new AnchorLayoutData(HEADER_SIZE, 0, 0, 0);
    this.list.horizontalScrollPolicy = list.verticalScrollPolicy = ScrollPolicy.OFF;
    this.list.addEventListener(Event.CHANGE, list_changeHandler);
    this.list.dataProvider = this.listCollection;
    this.addChild(this.list as DisplayObject);

    switch( this.line.category )
    {
      case ExchangeType.C20_SPECIALS:
        // headerDisplay.showCountdown(line.items[0]);
        this.list.itemRendererFactory = function ():IListItemRenderer{ return new ExSpecialItemRenderer(line.category);}
        break;
      
      case ExchangeType.C30_BUNDLES:
        listLayout.typicalItemWidth = Math.floor((width - listLayout.paddingLeft - listLayout.paddingRight)) ;
        // headerDisplay.showCountdown(line.items[0]);
        this.list.itemRendererFactory = function ():IListItemRenderer{ return new ExBundleItemRenderer(line.category);}
        break;
        
        case ExchangeType.C80_EMOTES:
        // headerDisplay.showCountdown(line.items[0]);
        this.list.itemRendererFactory = function ():IListItemRenderer{ return new ExEmotItemRenderer(line.category);}
        break;
      
      default:
        this.list.itemRendererFactory = function ():IListItemRenderer{ return new ExDefaultItemRenderer(line.category);}
        break;
    }
    
    var numLines:int = Math.ceil(this.line.items.length / listLayout.requestedColumnCount);
    this.height = listLayout.typicalItemHeight * numLines + listLayout.verticalGap * (numLines - 1) + listLayout.paddingTop + listLayout.paddingBottom + HEADER_SIZE;
    this.listCollection.data = this.line.items;
    
    // info button
    if( showInfo )
    {
      var infoButton:IndicatorButton = new IndicatorButton();
      infoButton.label = StrUtils.getNumber("?");
      infoButton.width = 64;
      infoButton.height = 68;
      infoButton.fixed = false;
      infoButton.styleName = MainTheme.STYLE_BUTTON_SMALL_HILIGHT;
      infoButton.addEventListener(Event.TRIGGERED, this.infoButton_trigeredHandler);
      infoButton.layoutData = new AnchorLayoutData(20, 20);
      this.addChild(infoButton as DisplayObject);
    }

    // countdown display
    if( this.line.category == ExchangeType.C20_SPECIALS || this.line.category == ExchangeType.C30_BUNDLES  || this.line.category == ExchangeType.C80_EMOTES )
    {
      this.countdownDisplay = new CountdownLabel();
      this.countdownDisplay.width = 250;
      this.countdownDisplay.layoutData = new AnchorLayoutData(10, NaN, NaN, 16);
      this.countdownDisplay.time = this.exchanger.items.get(this.line.category + 1).expiredAt - this.timeManager.now;
      this.addChild(this.countdownDisplay);

      this.timeManager.addEventListener(Event.CHANGE, this.timeManager_changeHandler);
      this.exchangeManager.addEventListener(FeathersEventType.END_INTERACTION, this.exchangeManager_endInteractionHandler);
    }

    // title display
    var labelDisplay:ShadowLabel = new ShadowLabel(loc("exchange_title_" + this.line.category), 1, 0, null, null, false, null, 0.8, null, "bold");
    labelDisplay.layoutData = new AnchorLayoutData(20, NaN, NaN, NaN, 0);
    this.addChild(labelDisplay as DisplayObject);
  }

  protected function list_changeHandler(event:Event) : void
  {
    var ei:ExchangeItem = exchanger.items.get(list.selectedItem as int);
    if( !ei.enabled )
      return;
    ei.enabled = false;
    if( this.owner != null )
      this.owner.dispatchEventWith(Event.SELECT, false, ei);
    this.list.removeEventListener(Event.CHANGE, this.list_changeHandler);
    this.list.selectedIndex = -1;
    this.list.addEventListener(Event.CHANGE, this.list_changeHandler);
  }

  protected function infoButton_trigeredHandler(event:Event) : void
  {
    appModel.navigator.addChild(new BaseTooltip(loc("tooltip_exchange_" + this.line.category), IndicatorButton(event.currentTarget).getBounds(stage)));
  }


  protected function timeManager_changeHandler(event:Event) : void 
  {
    this.countdownDisplay.time = this.exchanger.items.get(this.line.category + 1).expiredAt - this.timeManager.now;
  }
  
  protected function exchangeManager_endInteractionHandler(event:Object):void
  {
    if( this.line.category != ExchangeType.C30_BUNDLES )
      return;

    if( event.data == null )
      return;

    var item:ExchangeItem = event.data as ExchangeItem;
    if( item.category != ExchangeType.C30_BUNDLES )
      return;
    this.removeChildren();
    Starling.juggler.tween(this, 0.5, {height:0})
  }

  override public function dispose():void 
  {
    this.exchangeManager.removeEventListener(FeathersEventType.END_INTERACTION, this.exchangeManager_endInteractionHandler);
    this.timeManager.removeEventListener(Event.CHANGE, this.timeManager_changeHandler);
    super.dispose();
  }  
}
}