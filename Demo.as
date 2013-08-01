package  {
	
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.events.Event;
	import tjenkinson.scroller.Scroller;
	import tjenkinson.scroller.ElementRemovedEvent;
	
	
	public class Demo extends MovieClip {
		
		private var scroller:Scroller;
		
		public function Demo() {
			
			// create the scroller object
			scroller = new Scroller(400, 100, 10);
			scroller.y = 100;
			// add the scroller object to the stage
			addChild(scroller);
			// add "Item1" and "Item2" to the scroller (from the library). this also returns the ids assigned to each one
			scroller.addElement(new Item1());
			scroller.addElement(new Item2());
			
			// create event handlers
			scroller.addEventListener(Scroller.NO_MORE_ELEMENTS, noMoreElements);
			scroller.addEventListener(Scroller.LAST_OFF_SCREEN, lastOffScreen);
			scroller.addEventListener(Scroller.ELEMENT_REMOVED, elementRemoved);
			
			// create a listener that will be called whenever the amount of content remaining in the scroller falls below 1 second
			// this is useful if you are grabbing the content from an external source such as a database
			// you would request the next item a bit before the elements run out.
			var bufferListenerId = scroller.addBufferListener(function() {
				trace("Adding item3 because less than 1 second of content left in buffer.");								
				scroller.addElement(new Item3());
			}, [], 1000);
			
			// a listener can be removed with scroller.removeBufferListener(bufferListenerId);
			
			// Start the scroller
			scroller.start();
		}
		
		public function noMoreElements(e:Event) {
			trace("No more elements.");
		}
		
		public function lastOffScreen(e:Event) {
			trace("Last element off screen.");
		}
		
		public function elementRemoved(e:ElementRemovedEvent) {
			// useful if keeping references to the elements that have been added. this would be the place to remove those references
			trace("The element with id "+e.getId()+" has just been removed.");
		}
	}
	
}
