package
{
	import flash.display.Sprite;
	import flash.html.HTMLWindowCreateOptions;
	
	import mx.core.UIComponent;
	
	public class SimpleHTMLBox extends UIComponent
	{
		import flash.html.HTMLHost;
		import flash.html.HTMLLoader;
		import flash.text.TextField;
		import flash.net.URLRequest;
		import PageHost;
		private var host:PageHost;
		private var statusField:TextField;
		private var html:HTMLLoader;
		
		public function SimpleHTMLBox(){
			
			host = new PageHost();
			host.createWindow(new HTMLWindowCreateOptions());
			
		}
		
	}
}