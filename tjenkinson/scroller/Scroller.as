package tjenkinson.scroller
{
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.display.DisplayObject;
	
	public class Scroller extends Sprite
	{
		private var theWidth:Number;
		private var elements:Array = [];
		private var speed:Number; // pixels per second
		private var moveAmount:Number; //speed / framerate
		private var lastElementId:int; // this will always increase so there will always be unique ids
		private var noElements:int = 0; // count of no of elements that have ever been. always increasing
		private var onScreen:Boolean = false; // true if there is anything on screen (even if leaving)
		private var running:Boolean = false; // true after start called, false after stopped called
		private var stopImmediatey:Boolean = false;
		private var spacing:Number; // spacing between clips (pixels)
		private var theMask:Shape;
		private var nextElementMustShow:Boolean = false;
		private var justStarted:Boolean = false;
		
		// events
		public static const NO_MORE_ELEMENTS:String = "NO_MORE_ELEMENTS"; // stopped automatically bevause ran out of elements
		public static const LAST_OFF_SCREEN:String = "LAST_OFF_SCREEN"; // last element scrolled off screen
		public static const ELEMENT_REMOVED:String = "ELEMENT_REMOVED"; // element removed from list
		
		public function Scroller(theWidth:Number, speed:Number, spacing:Number=10)
		{
			this.theWidth = theWidth;
			// create the mask around object
			this.theMask = new Shape();
			updateMask(0, true);
			this.theMask.visible = false;
			addChild(this.theMask);
			this.mask = this.theMask;
			
			addEventListener(Event.ADDED_TO_STAGE, function(e:Event){init(e, speed, spacing);});
		}
		
		private function init(e:Event, speed:Number, spacing:Number)
		{
			setSpeed(speed);
			setSpacing(spacing);
			this.stage.addEventListener(Event.ENTER_FRAME , timerTick); // run on every frame
		}
		
		private function updateMask(theMskHeight:Number, firstRun:Boolean=false)
		{
			if (!firstRun && theMskHeight <= theMask.height)
			{
				return; // only redraw the mask if necessary
			}
			theMask.graphics.beginFill(0x0);
			theMask.graphics.drawRect(0, 0, theWidth, theMskHeight);
			theMask.graphics.endFill();
		}
	
		public function addElement(element:DisplayObject, mustShow:Boolean=false, ignoreIfFirst:Boolean=false):int
		{
			var id:int = (getNoElements() !== 0) ? getLastElementId()+1 : 0;
			elements.push({id: id, element:element, onScreen: false, mustShow: mustShow, ignoreIfFirst: ignoreIfFirst});
			this.noElements++;
			this.lastElementId = id;
			return id;
		}
		
		public function removeElement(id:int):void
		{
			var index:int = getArrayIndex(id);
			if (index == -1)
			{
				throw new Error("No elements exists with that id.");
			}
			removeElementIndex(index);
		}
		
		private function removeElementIndex(index:int)
		{
			if (this.elements[index].onScreen)
			{
				throw new Error("Cannot remove element because it's on screen.");
			}
			var id:int = this.elements[index].id;
			elements.splice(index, 1);
			dispatchEvent(new ElementRemovedEvent(Scroller.ELEMENT_REMOVED, id, false, false));
		}
		
		public function setSpeed(speed:Number):void
		{
			this.speed = speed;
			this.moveAmount = speed/this.stage.frameRate;
		}
		
		public function getSpeed():Number
		{
			return this.speed;
		}
		
		// not sure whether shouold be changeable after initialisation. maybe only when nothing on screen
		private function setSpacing(val:Number)
		{
			this.spacing = val;
		}
		
		public function start():void
		{
			if (getIsRunning())
			{
				return;
			}
			justStarted = true;
			this.running = true;
		}
		
		public function stop(immediately:Boolean=false):void
		{
			this.running = false;
			if (immediately)
			{
				this.stopImmediatey = true;
			}
		}
		
		public function clearAll():void
		{
			if (getIsRunning())
			{
				throw new Error("Can't remove all elements because I'm still running.");
			}
			elements = [];
		}
		
		private function getLastElementId():int
		{
			if (getNoElements() === 0)
			{
				throw new Error("No elements.");
			}
			return this.lastElementId;
		}
		
		public function getNoElements():int
		{
			return this.noElements;
		}
		
		public function getRemainingElements():int
		{
			var count:int = elements.length;
			if (!getIsRunning())
			{
				// any elements that are meant to be ignored will be so deduct them from remaining elements
				for (var i:int=0; i<elements.length; i++)
				{
					if (elements[i].ignoreIfFirst)
					{
						count--;
					}
					else
					{
						break;
					}
				}
			}
			return count;
		}
		
		public function getOnScreen():Boolean
		{
			return this.onScreen;
		}
		
		public function getNoElementsOnScreen():int
		{
			var count:int = 0;
			for (var i:int=0; i<elements.length; i++)
			{
				if (elements[i].onScreen)
				{
					count++;
				}
				else {
					break;
				}
			}
			return count;
		}
		
		public function getIsRunning():Boolean
		{
			return this.running;
		}
		
		public function getActualWidth():Number
		{
			var lastElement:DisplayObject = null;
			for (var i:int=0; i<elements.length; i++)
			{
				if (elements[i].onScreen)
				{
					lastElement = elements[i].element;
				}
			}
			if (lastElement == null) {
				return 0;
			}
			else {
				var val:Number = lastElement.x + lastElement.width + spacing;
				return val > theWidth ? theWidth : val;
			}
		}
	
		// runs on each frame
		private function timerTick(e:Event):void
		{
			
			if (this.stopImmediatey)
			{
				// remove any elements that are on screen or any subsequent elements that has mustShow set
				this.stopImmediatey = false;
				nextElementMustShow = false;
				var elementsToRemove:Array = [];
				for (var i:int=0; i<elements.length; i++)
				{
					if (elements[i].onScreen || elements[i].mustShow)
					{
						if (elements[i].onScreen)
						{
							removeChild(elements[i].element);
						}
						elements[i].onScreen = false; // removeElement() will only remove off screen
						elementsToRemove.push(i);
					}
					else
					{
						break;
					}
				}
				for(var i:int=elementsToRemove.length-1; i>=0; i--)
				{
					removeElementIndex(elementsToRemove[i]);
				}
			}
			else
			{
				if (getIsRunning() || nextElementMustShow)
				{
					// determine if next element needs to be added
					var lastElement:Object; // last element on screen
					var nextElement:Object;
					var found:Boolean = false;
					var foundNextElement:Boolean = false;
					var elementsToRemove:Array = [];
					nextElementMustShow = false;
					
					for (var i:int=0; i<elements.length; i++)
					{
						if (elements[i].onScreen)
						{
							found = true;
							lastElement = elements[i];
						}
						else if (justStarted && elements[i].ignoreIfFirst)
						{
							elementsToRemove.push(i);
						}
						else
						{
							nextElement = elements[i];
							nextElementMustShow = elements[i].mustShow;
							foundNextElement = true;
							break;
						}
					}
					// elements must be removed here and not in loop bacause it changes indexing. must be in reverse
					for (var i:int=elementsToRemove.length-1; i>=0; i--)
					{
						removeElementIndex(elementsToRemove[i]);
					}
					// if not found an element on screen OR the last element on screen is now completley on screen
					if (!found || lastElement.element.x+lastElement.element.width+this.spacing < this.theWidth) // ready to add one
					{
						if (foundNextElement)
						{
							// set the position off screen to start
							nextElement.element.x = this.theWidth;
							nextElement.element.cacheAsBitmap=true;
							nextElement.onScreen = true;
							this.addChildAt(nextElement.element,0);
							this.onScreen = true; // update global on screen status
						}
						else // there are no more elements to add
						{
							stop();
							dispatchEvent(new Event(Scroller.NO_MORE_ELEMENTS));
						}
					}
					justStarted = false;
				}
				// shift everything on screen across to left and remove if results in off screen
				for (var i:int=0; i<elements.length; i++)
				{
					if (elements[i].onScreen)
					{
						elements[i].element.x -= this.moveAmount; // move it
						if (elements[i].element.x + elements[i].element.width < 0)
						{
							elements[i].onScreen = false; // removeElement() will only remove offscreen
							removeChild(this.elements[i].element); // remove element
							removeElementIndex(i);
						}
					}
				}
				updateMask(this.height);
			}
			// update global onScreen
			var found:Boolean = false;
			for (var i:int=0; i<elements.length; i++)
			{
				if (elements[i].onScreen)
				{
					found = true;
					break;
				}
			}
			
			if (!found && onScreen)
			{
				dispatchEvent(new Event(Scroller.LAST_OFF_SCREEN));
			}
			this.onScreen = found;
		}
		
		private function getArrayIndex(id:int):int
		{
			for (var i:int=0; i<elements.length; i++)
			{
				if (elements[i].id == id)
				{
					return i;
				}
			}
			return -1;
		}
		
	}
}
