#import "DeMarcbenderWebrtcViewProxy.h"
#import "TiUtils.h"





@implementation DeMarcbenderWebrtcViewProxy {

    
}

- (id)init
{
    // This is the designated initializer method and will always be called
    // when the view proxy is created.

    //NSLog(@"[SVG VIEWPROXY LIFECYCLE EVENT] init");

    //webRTCView = [[DeMarcbenderWebrtcView alloc] init];
    
    NSLog(@" proxy INIT ");

    
    return [super init];
}

- (void)_destroy
{
    // This method is called from the dealloc method and is good place to
    // release any objects and memory that have been allocated for the view proxy.

    //NSLog(@"[SVG VIEWPROXY LIFECYCLE EVENT] _destroy");

    [super _destroy];
}

-(void)putWebRTCView:(DeMarcbenderWebrtcView *)view {
    webRTCView = view;
}

- (DeMarcbenderWebrtcView *)getWebRTCView
{
    return webRTCView;
}



- (id)_initWithPageContext:(id<TiEvaluator>)context
{
    // This method is one of the initializers for the view proxy class. If the
    // proxy is created without arguments then this initializer will be called.
    // This method is also called from the other _initWithPageContext method.
    // The superclass method calls the init and _configure methods.

    //NSLog(@"[SVG VIEWPROXY LIFECYCLE EVENT] _initWithPageContext (no arguments)");
    NSLog(@" proxy _initWithPageContext ");

    return [super _initWithPageContext:context];
}

- (id)_initWithPageContext:(id<TiEvaluator>)context_ args:(NSArray *)args
{
    // This method is one of the initializers for the view proxy class. If the
    // proxy is created with arguments then this initializer will be called.
    // The superclass method calls the _initWithPageContext method without
    // arguments.

    NSLog(@" proxy _initWithPageContext _args ");

    
    //NSLog(@"[SVG VIEWPROXY LIFECYCLE EVENT] _initWithPageContext %@", args);
    webRTCView = [[DeMarcbenderWebrtcView alloc] init];
    [webRTCView initializeState];

    return [super _initWithPageContext:context_ args:args];
}

- (void)_configure
{
    // This method is called from _initWithPageContext to allow for
    // custom configuration of the module before startup. The superclass
    // method calls the startup method.

    //NSLog(@"[SVG VIEWPROXY LIFECYCLE EVENT] _configure");

    [super _configure];
}

- (void)_initWithProperties:(NSDictionary *)properties
{
    // This method is called from _initWithPageContext if arguments have been
    // used to create the view proxy. It is called after the initializers have completed
    // and is a good point to process arguments that have been passed to the
    // view proxy create method since most of the initialization has been completed
    // at this point.

    //NSLog(@"[SVG VIEWPROXY LIFECYCLE EVENT] _initWithProperties %@", properties);
    
    [super _initWithProperties:properties];
}

- (void)viewWillAttach
{
    // This method is called right before the view is attached to the proxy

    //NSLog(@"[SVG VIEWPROXY LIFECYCLE EVENT] viewWillAttach");
}

- (void)viewDidAttach
{
    
    NSLog(@" proxy viewDidAttach  ");

    
    // This method is called right after the view has attached to the proxy

    //NSLog(@"[SVG VIEWPROXY LIFECYCLE EVENT] viewDidAttach");
}

- (void)viewDidDetach
{
    // This method is called right before the view is detached from the proxy

    //NSLog(@"[SVG VIEWPROXY LIFECYCLE EVENT] viewDidDetach");
}

- (void)viewWillDetach
{
    // This method is called right after the view has detached from the proxy

    //NSLog(@"[SVG VIEWPROXY LIFECYCLE EVENT] viewWillDetach");
}

@end


@implementation DeMarcbenderWebrtcView

- (id)init
{
  self = [super init];
    
    if (self != nil) {

    }
  return self;
}


- (void)initializeState
{
  // Creates and keeps a reference to the view upon initialization
  [super initializeState];
  [(DeMarcbenderWebrtcViewProxy *)[self proxy] putWebRTCView:self];
}

- (void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
  // Sets the size and position of the view
//  [TiUtils setView:square positionRect:bounds];
}

- (void)setColor_:(id)color
{
  // Assigns the view's background color
//  square.backgroundColor = [[TiUtils colorValue:color] _color];
}

@end

