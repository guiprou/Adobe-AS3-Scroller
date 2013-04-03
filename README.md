Adobe-AS3-Scroller
==================

An Adobe ActionScript3 class to manage scrolling objects. Can be used for scrolling tweets in a twitter scroller for example.

Please look at the demo class and flash project to see how it works.

stop() can be called at any time and any elements currently on screen will continue to scroll off. This can be overrided with stop(true) which will immediately remove all elements off the screen.

There are still a few bugs that I've found:
- If the top left point of the contents of an object that is added to the scroller doesn't touch the registration point.
- With text the mask that is generated sometimes seems to chop off the bottom. It seems to be calculating the height wrong.
- Occasionaly two elements are loaded on screen at the same time and scroll accross overlapping each other.

If you find any other bugs or have a solution to the ones above please let me know!

Tom
