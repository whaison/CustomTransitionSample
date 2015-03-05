
#import "ViewController.h"

#import "FadeAnimationController.h"
#import "D3AnimationController.h"
#import "TransparentViewController.h"


@interface ViewController ()
<
UIViewControllerTransitioningDelegate,
UINavigationControllerDelegate,
UIGestureRecognizerDelegate
>

@property (nonatomic, strong) ViewController *nextViewController;

@property (nonatomic, strong) FadeAnimationController *animationController;

@property (nonatomic, assign) BOOL isGesture;

@property (nonatomic, strong) D3AnimationController *d3AnimationController;

@end


@implementation ViewController

/**
 *  View did load.
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button1.frame = CGRectMake(0, 0, 250, 50);
    [button1 addTarget:self
                    action:@selector(addNormal:)
          forControlEvents:UIControlEventTouchUpInside];
    [button1 setTitle:@"Touch to add a ViewController"
                 forState:UIControlStateNormal];
    [self.view addSubview:button1];
    button1.center = self.view.center;
    
    // Button2
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button2.frame = CGRectMake(0, 0, 300, 50);
    [button2 addTarget:self
                    action:@selector(addTransparent:)
          forControlEvents:UIControlEventTouchUpInside];
    [button2 setTitle:@"Touch to add a TransaparentViewController"
                 forState:UIControlStateNormal];
    [self.view addSubview:button2];
    CGPoint center = self.view.center;
    center.y += 60;
    button2.center = center;
    
    /////////////////////////////////////////////////////////////////////////////
    
    self.d3AnimationController = [D3AnimationController create];
    
    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.edges    = UIRectEdgeLeft;
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
}


/**
 *  View did appear.
 */
- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    static BOOL firstTime = NO;
    if (!firstTime) {
        firstTime = YES;
        self.navigationController.delegate                                 = self.d3AnimationController;
        self.navigationController.interactivePopGestureRecognizer.enabled  = YES;
        self.navigationController.interactivePopGestureRecognizer.delegate = self.d3AnimationController;
    }
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark - UINavigationControllerDelegate

/**
 *  It'll be called when this shown in lifecycle.
 *  This is invoked after `viewDidAppear:` method has called.
 */
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}


/**
 *  It'll be called when starting an animation of transition.
 */
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    if (operation == UINavigationControllerOperationPop) {
        self.animationController = [FadeAnimationController create];
        if (self.isGesture) {
            [self.animationController startAsSwipe];
        }
        return self.animationController;
    }
    
    // To use by default.
    return nil;
}
- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return self.animationController;
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - Event handler

- (void)addNormal:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    const CGFloat r = arc4random_uniform(100) / 100.0;
    const CGFloat g = arc4random_uniform(100) / 100.0;
    const CGFloat b = arc4random_uniform(100) / 100.0;
    
    self.nextViewController = [[ViewController alloc] init];
    self.nextViewController.view.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    
    // transitionDelegate is to be used in modal view transition.
    // self.nextViewController.transitioningDelegate = self;
    
    [self.navigationController pushViewController:self.nextViewController
                                         animated:YES];
}

- (void)addTransparent:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    const CGFloat r = arc4random_uniform(100) / 100.0;
    const CGFloat g = arc4random_uniform(100) / 100.0;
    const CGFloat b = arc4random_uniform(100) / 100.0;
    
    TransparentViewController *vc = [TransparentViewController create];
    [self.navigationController pushViewController:vc animated:YES];
    vc.view.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}


/**
 *  Pan Gesture's handler
 */
- (void)handlePan:(UIScreenEdgePanGestureRecognizer *)gesture
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    CGFloat width = gesture.view.frame.size.width;
    
    static UINavigationController *navigationController;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.isGesture = YES;
        [self.d3AnimationController startAsSwipe];
        
        navigationController = self.navigationController;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:gesture.view];
        CGFloat percent = ABS(translation.x / width);
        navigationController.navigationBar.alpha = 1.0 - percent;
        
        [self.d3AnimationController updateInteractiveTransition:percent];
    }
    else if (gesture.state == UIGestureRecognizerStateEnded ||
             gesture.state == UIGestureRecognizerStateCancelled) {
        self.isGesture = NO;
        
        CGPoint translation = [gesture translationInView:gesture.view];
        CGPoint velocity    = [gesture velocityInView:gesture.view];
        CGFloat percent     = MAX(0, translation.x + velocity.x * 0.25) / width;
        
        if (percent < 0.5 || gesture.state == UIGestureRecognizerStateCancelled) {
            [self.d3AnimationController cancelInteractiveTransition];
        }
        else {
            [self.d3AnimationController finishInteractiveTransition];
        }
    }
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - UIGestureRecognizerDelegate

/**
 *  UIScreenEdgePanGestureRecognizer's handler
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    return YES;
}

@end
