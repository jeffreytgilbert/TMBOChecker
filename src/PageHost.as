package
{
	import flash.display.Loader;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowSystemChrome;
	import flash.display.NativeWindowType;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.NativeWindowBoundsEvent;
	import flash.geom.Rectangle;
	import flash.html.*;
	import flash.html.HTMLHost;
	import flash.html.HTMLLoader;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.setInterval;
	
	import mx.controls.Image;
	import mx.utils.StringUtil;
	
	public class PageHost extends HTMLHost{
		
		public function PageHost(defaultBehaviors:Boolean=true){
			super(defaultBehaviors);
		}
		
		override public function windowClose():void{
//			htmlLoader.stage.nativeWindow.close();
		}
		
		private var html:HTMLLoader = new HTMLLoader();
		private var window:NativeWindow;
		
		override public function createWindow(windowCreateOptions:HTMLWindowCreateOptions):HTMLLoader{
			checkForLogin();
			// check the page contents to see if we need to prompt the login
			
			return html;
		}
		
		public function checkForLogin(evt:Event=null):void{
			if(window && window.stage.contains(html)){ window.stage.removeChild(html); }
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loadingCompleteHandler);
			loader.load(new URLRequest("https://thismight.be/offensive/logn.php"));
		}
		
		public function loadingCompleteHandler(evt:Event):void{
			var pageText:String = String(evt.target.data);
			var title:Array = pageText.match( /<title>.*<\/title>/i );
			trace(title[0]);
			if(title[0]=='<title>thismight.be : do we know you?</title>'){
				trace('needs login');
				var initOptions:NativeWindowInitOptions = new NativeWindowInitOptions();
				initOptions.systemChrome = NativeWindowSystemChrome.STANDARD;
				initOptions.transparent = false;
				initOptions.resizable = true;
				initOptions.maximizable = false;
				initOptions.minimizable = false;
				initOptions.type = NativeWindowType.UTILITY;
				
				window = new NativeWindow(initOptions);
				window.visible = true;
				window.alwaysInFront = true;
				window.height = 400;
				window.width = 400;
				window.stage.scaleMode = StageScaleMode.NO_SCALE;
				window.stage.align = StageAlign.TOP_LEFT;
				
				html.width = window.width;
				html.height = window.height;
				html.x = 0;
				html.y = 0;
				
				html.load(new URLRequest("https://thismight.be/offensive/logn.php"));
				window.stage.addChild(html);
				html.addEventListener(Event.LOCATION_CHANGE,checkForLogin);
			} else {
				if(window){ window.close(); }
				trace('good to go');
				launchViewer();
				setInterval(launchViewer, 30000);
//				launchViewer();
			}
		}
		
		public var contentWindow:NativeWindow;
		
		public function launchViewer():void{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, contentCheckCompleteHandler);
			loader.load(new URLRequest('https://thismight.be/offensive/?c=thumbs'));
		}
		
		public function contentCheckCompleteHandler(evt:Event):void{
			var pageText:String = String(evt.target.data);
			
			// <img name="th327819" src="/offensive/uploads/2012/01/14/image/thumbs/th327819.jpg" title="uploaded by gibson84">
			// <img name="th327704"\n\t\t\t\t\t\t\t\tsrc="/offensive/uploads/2012/01/11/image/thumbs/th327704.jpg"\n\t\t\t\t\t\t\t\ttitle="uploaded by DrFaustus"\n\t\t\t\t\t\t>
			var images:Array = pageText.match( /<img name=".*"\n\t\t\t\t\t\t\t\tsrc=".*"\n\t\t\t\t\t\t\t\ttitle=".*"\n\t\t\t\t\t\t>/mgi );
			
			var i:uint;
			var l:uint = images.length > 2 ? 2 : images.length;
			var image:String = '';
			for(i = 0 ; i<l ; i++){
				image = images[i];
				image = image.replace(/\n/g,' ');
				image = image.replace(/\t/g,'');
				image = StringUtil.trim(image);
				
				var parts:Array = image.split( /\s+/ );
				var imageId:String = parts[1].substr(8,parts[1].length-9); // 8, -1
				var imageUrl:String = parts[2].substr(5,parts[2].length-6); // 5, -1
				
				if(cache.indexOf(imageId) > -1){
					trace('found content in cache, don\'t show');
				} else {
					trace('show content. new content');
					showContent(imageId);
					cache[cache.length] = imageId;
				}
			}
		}
		
		private var cache:Array = [];
		
		public function showContent(contentId:String):void{
			var initOptions:NativeWindowInitOptions = new NativeWindowInitOptions();
			initOptions.systemChrome = NativeWindowSystemChrome.STANDARD;
			initOptions.transparent = false;
			initOptions.resizable = true;
			initOptions.maximizable = false;
			initOptions.minimizable = false;
			initOptions.type = NativeWindowType.UTILITY;
			
			var contentWindow:NativeWindow = new NativeWindow(initOptions);
			contentWindow.visible = true;
			contentWindow.alwaysInFront = true;
			contentWindow.height = 400;
			contentWindow.width = 400;
			contentWindow.x = 0;
			contentWindow.y = 0;
			contentWindow.stage.scaleMode = StageScaleMode.NO_SCALE;
			contentWindow.stage.align = StageAlign.TOP_LEFT;
			
			trace(contentId);
			
			var htmlLoader2:HTMLLoader = new HTMLLoader();
			htmlLoader2.load(new URLRequest('https://thismight.be/offensive/pages/pic.php?id='+contentId));
			htmlLoader2.width = contentWindow.width;
			htmlLoader2.height = contentWindow.height;
			htmlLoader2.x = 0;
			htmlLoader2.y = 0;
			
			contentWindow.addEventListener(NativeWindowBoundsEvent.RESIZE,function(evt:NativeWindowBoundsEvent):void{
				htmlLoader2.width = contentWindow.width;
				htmlLoader2.height = contentWindow.height;
			});
			
			contentWindow.stage.addChild(htmlLoader2);
		}
		
		public function checkForContent():void{
			
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, loadingCompleteHandler);
			loader.load(new URLRequest('https://thismight.be/offensive/?c=thumbs'));
		}
		
		
		override public function updateLocation(locationURL:String):void{
			trace(locationURL);
		}
		
		override public function set windowRect(value:Rectangle):void{
			html.stage.nativeWindow.bounds = value;
		}
		
		override public function windowBlur():void{
//			html.alpha = 0.5;
		}
		
		override public function windowFocus():void{
//			html.alpha = 1;
		}
		
	}
}

