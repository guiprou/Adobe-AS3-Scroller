package
{
     import flash.events.Event;
     public class ElementRemovedEvent extends Event
     {
          private var elementId:String;

          public function ElementRemovedEvent(type:String, id:String, bubbles:Boolean=false, cancelable:Boolean=false):void
          {
               //we call the super class Event
               super(type, bubbles, cancelable);
			   this.elementId = id;
          }
		  
	  public function getId():String
          {
               return elementId;
	  }
     }
}
