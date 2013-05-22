Adobe-AS3-Scroller
==================

An Adobe ActionScript3 class to manage scrolling objects. Can be used for scrolling tweets in a twitter scroller for example.

Please look at the demo class and flash project to see how it works.

stop() can be called at any time and any elements currently on screen will continue to scroll off. This can be overrided with stop(true) which will immediately remove all elements off the screen.
addElement() also has 2 extra parameters meaning you can specify if the element that's being added should be removed if it would be shown first, and you can also specify if the element must be shown on screen (after the previous element) before the scroller can stop (unless it's stopped immediately). These are useful if you are creating scrolling text and want a placeholder between each item.

There are still a few bugs that I've found:
- If the left point of the contents of an object that is added to the scroller doesn't touch the registration point.

If you find any other bugs or have a solution to the ones above please let me know!

Tom
