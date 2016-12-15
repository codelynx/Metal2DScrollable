# Overview

Have you ever thought about building a Metal based 2D programming?  Learning Metal is still pretty high learning curve, but what I found most difficult part is make it scrollable just like another application using UIScrollView.  If you are working on 2D game programming, your users will have different user experiences and the things I write here many not be applicable, but if you working on productivity type of apps like painting and drawing, then probably you would agree what I mean here.

As you know MTKView cannot be placed in UIScrollView's subview, it just won't work.  But simulating UIScrollView like experiences with gesture recognizer is pretty hard. 

I recently come up with ~~crazy~~ idea about this. Placing MTKView behind UIScrollView and placing dummy contents view as a subview of UIScrollView.  Make sure UIScrollView and dummy content view's background color to be transparent.

Ok then, when you pinch and zoom on UIScrollView, you are zooming and scrolling transparent dummy content view.  Then transparent content view signals to MTKView to render content based on its dummy contents view's bounds.  So, from user's eye, although MTKView is not zooming or scrolling, instead just sitting the same place behind the UIScrollView, but metal based contents actually look zooming and scrolling.

I figured out this technique for rending zoomed PDF. For more information please refer following article [in Japanese].

* UIScrollView内でPDFなどのベクター表示をうまく拡大表示する方法
http://qiita.com/codelynx/items/a2a87b053f8225782a9c

<img width="400" src="https://qiita-image-store.s3.amazonaws.com/0/65634/cf02bd41-39cf-9eb8-fd67-67140d92954b.png" />

Also this sample code provides some way to blending multiple shaders much easier way.  When you simply implementing multiple shaders to render a content, your code start getting messier and messier, and hard to organize render pipe line descriptors, vertex descriptors and goes on and on.  But this project provides a some mechanism to split each shader related codes to separate components.

Also I tried to aim this Metal sample code to be like more Core Graphics like API. It may be still far away from the goal, but each shader related code can draw on context to build a complex visual representation on the screen.

# Architecture

Here are the main players.  Application specific subclasses are not listed here.

* RenderView
* UIScrollView
* RenderContentView
* RenderableScene
* Renderer
* Renderable
* Shader
* RenderContext

### RenderView

RenderView is the main component of this architecture.  MTKView, UIScrollView and other necessary views and component will be created by itself.  So when if you like to use RenderView on your storyboard, just place this view and all dependent view will be created at runtime.

### UIScrollView

UIScrollView os placed as a subview of RenderView, and when you zoom and scroll operation on RenderView, this UIScrollView is the one act as scroll view.  As a default, is set to minimum number of touches to scroll is 2.  So, when you like to scroll, use two finger.  This can be set through RenderView.

### RenderContentView

RenderContentView sits as a subview of UIScrollView and when you zoom and scroll, this is the view actually subject to be operated.  Since this view is transparent, user will never see the content view.  Also when you touch on the view, touch event can be deliver to forth coming RenderableScene for handling event.

### RenderableScene

RenderableScene represents an object that knows how to draw a complete content.  It has its own content size, and UIScrollView behaves based on this content size.  This is the place where Renderable object are kept waiting for being drawn. 

Also touch events are delivered to this component, so if you like to pencil or paint like application, this is the place to handle those touch events.

### Renderer

Renderer is the place where Render pipeline, vertex descriptor, color sampler state exists.  So, Renderer knows the format of corresponding shader's vertex format and other spec necessary to render.  Same type of Renderer should be instantiated only one per device (MTLDevice). 

### Renderable

Renderable can be an instance of Renderer.  For example, a Renderer knows vertex and color format, but it doesn't know the shape or texture of the drawn object.  On the other hand, Renderable knows its shape, textures and others necessary to draw on the screen.

### Shader

Actual Metal shader.  There are vertex shader and fragment shader program.  If you like to develop your own shader, you develop Renderer, Renderable and Shader as a whole pice.   So render pipe line descriptors, vertex descriptors and others specific to a shader can be managed separately.  Thus, RenderableScene would just instantiate any Renderable objects and draw.

### RenderContext

At this moment, RenderContext does not do much things.  But this can be used as graphics state such as holding transform matrix, just like Core Graphics's CGContext.  Furthermore, this could also hold some current color or textures, to make rendering more visually presentable.

### Visual Hierarchy and Rendering Process

<pre>
+ RenderView
	+ MTKView
	+ UIScrollView
		+ RenderContentView
</pre>

Here is a quick diagram of how objects are drawn to shaders

<pre>
MTKView -> RenderView -> RenderableScene -> Renderable -> Renderer -> Shader
</pre>

## Sample Project

This sample project provides three shader suites.  One for colored-vertex based, second is image shaders, and third is point shaders.  I believe these three shaders should be sufficient to start developing your own shader component suite.

* ColorShaders, ColorRenderer, ColorTriangleRenderable, ColorRectRenderable
* ImageShaders, ImageRenderer, ImageRenderable
* PointsShaders, PointsRenderer, PointsRenderable

<img width="512" src="https://qiita-image-store.s3.amazonaws.com/0/65634/ef7c7dd7-08f7-cfd8-c718-c41dbe954370.png"/>

As a part of experiment, this RenderView displays hybrid contents between Metal and Core Graphics.  If you find a clock displaying near the center of the contents, it is actually drawn by Core Graphics.  RenderableScene has a hood `func draw(in context: CGContext)` and all the core graphics operations made to the CGContext will be shown on the screen.  So If you like to display pretty complex things such as displaying PDF contents on Metal contents, this can be done by overriding this method.

# Considerations

There are so many things to be redesign or refactor or enhance.  Here is the short list.

#### Mechanism to provide only one Renderer instance per device

Currently all three Renderers provide own class methods to prevent creating the second renderer.  There must be a better way...

#### Better way to find synchronizing pixelFormat

Currently, if all Renderer's render pipeline's colorAttachments must match or crash. Developer must keep an eye on this, but there may be a better way to do this.  Probably some other pit fall I am to aware of may be exist.

* Layer support
* Refactoring Renderer or Renderable protocols
* More shader samples

----

Versions description:

```.log
Version 8.1 (8B62)
Apple Swift version 3.0.1 (swiftlang-800.0.58.6 clang-800.0.42.1)
```


