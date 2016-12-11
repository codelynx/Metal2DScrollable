## Overview

This sample project aims to demonstrate how to implement Metal 2D based scrollable application.  The idea is place `MTKView` behind `UIScrollView`, and place dummy content view as a subview of `UIScrollView`.  Make sure `UIScrollView` and content view to be transparent.  Then when you pinch and swipe to zoom and scroll, dummy content view is the one actually zoom or scroll, but since it is transparent, you don't see the dummy content view actually on screen.  Note `MTKView` will not be zoomed or scrolled, it just stay there.

On the other hand, `MTKView`'s delegate does some calculation of transform coordinate between contentView to `MTKView`.  So when rendering occur, pass that transform matrix to uniform buffer, then when you pinch and swipe on the screen, the contents will be zoomed or scrolled just like you are using `UIScrollView`.  Yes!!

## How this project is made?

This project is created by Xcode 8.1 with Game (Metal) template.  Here is the list of some changes.

1. Rename `GameViewController` to `Metal2DViewController`
2. Rename shaders
3. Add `Uniforms` structure to Vertex shader
4. Add some code to prepare uniform buffer in `Metal2DViewController`
5. Add `UIScrollView`, `OvalView` into storyboard
6. Reorganize structure of view hierarchy of storyboard
7. Update uniform buffer according to zooming and scrolling state
8. Assign uniform buffer to render encoder


## View Hierarchy 

<pre>
+ Metal2DViewController
    + View
        - MTKView
        - OvalView
        + UIScrollView
            - contentView (UIView)
</pre>

I originally come up with this idea is for displaying PDF page within UIScrollView.  The subview of UIScrollView gets blurred when zoomed, but updating `contentScaleFactor` according to the zoomScale will cause crash due to run out of memory.  So I came up with this dummy view strategy for zoomable vector graphics view.  Now I thought this idea should work for Metal 2D scrollable contents.

Here is the post of the article about zooming PDF like vector image within UIScrollView. [in Japanese]

http://qiita.com/codelynx/items/a2a87b053f8225782a9c


## What is OvalView?

`OvalView` sits in front of `MTKView`, and it is Core Graphics version using the same technique.  `OvalView` itself is not actually zoomed or scrolled, but use the coordinate of dummy content view to make it look like zoomed and scrolled.  It actually draws couple of ovals on the screen.  When you pinched and swiped, it should looks like zoomed and scrolled. Woa!?  When necessary you may remove the view with necessary cares, or just set hidden flag from storyboard to make it invisible.


## Status

There are some math problem and `MTKView` and `OvalView` are not synchronized.  If you are good at liner algebra, please help me out from this swamp.


## Environment

```.log
Version 8.1 (8B62)
Apple Swift version 3.0.1 (swiftlang-800.0.58.6 clang-800.0.42.1)
```


