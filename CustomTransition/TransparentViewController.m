
#import "TransparentViewController.h"

@interface TransparentViewController ()

@property (nonatomic, strong) UIButton *button;

@end


@implementation TransparentViewController

+ (instancetype)create
{
    return [[self.class alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button.frame = CGRectMake(0, 0, 250, 50);
    [self.button addTarget:self
                    action:@selector(touched:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.button setTitle:@"Touch to add a ViewController"
                 forState:UIControlStateNormal];
    [self.view addSubview:self.button];
    self.button.center = self.view.center;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    self.navigationItem.title = @"透過ビューコントローラ";
}


/////////////////////////////////////////////////////////////////////////////
#pragma mark - Event handler

- (void)touched:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    const CGFloat r = arc4random_uniform(100) / 100.0;
    const CGFloat g = arc4random_uniform(100) / 100.0;
    const CGFloat b = arc4random_uniform(100) / 100.0;
    
    TransparentViewController *vc = [TransparentViewController create];
    [self.navigationController pushViewController:vc animated:YES];
    vc.view.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    
    // self.nextViewController = [[ViewController alloc] init];
    // self.nextViewController.view.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    
    // transitionDelegate is to be used in modal view transition.
    // self.nextViewController.transitioningDelegate = self;
    
    // [self.navigationController pushViewController:self.nextViewController
    //                                      animated:YES];
}

@end
