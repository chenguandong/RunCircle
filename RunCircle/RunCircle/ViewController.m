//
//  ViewController.m
//  RunCircle
//
//  Created by chenguandong on 15/4/13.
//  Copyright (c) 2015年 chenguandong. All rights reserved.
//

#import "ViewController.h"
#import "MathTools.h"
@interface ViewController ()

@end

@implementation ViewController

- (IBAction)StopLocation:(id)sender {
    
    [self.localtionManage stopUpdatingLocation];
    [self.timer invalidate];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _routes = [NSMutableArray arrayWithCapacity:10];
    
    [self initLocation];
    [self initMapView];
    
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(1.0) target:self selector:@selector(eachSecond) userInfo:nil repeats:YES];
}



- (void)eachSecond
{
    //在这里计算时间 更新界面等 如速度更新
    self.seconds++;
    
    NSString *timeStr = [NSString stringWithFormat:@"Time: %@",  [MathTools stringifySecondCount:self.seconds usingLongFormat:NO]];
    
    //距离
    NSString *distStr = [NSString stringWithFormat:@"Distance: %@", [MathTools stringifyDistance:self.distance]];
    //步速
    NSString *paceStr = [NSString stringWithFormat:@"Pace: %@",  [MathTools stringifyAvgPaceFromDist:self.distance overTime:self.seconds]];
    
    
    _infoText.text = [NSString stringWithFormat:@"time = %@ \n dist=%@ \n pace= %@",timeStr,distStr,paceStr];

}



#pragma mark --初始化Map
-(void)initMapView{
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    self.mapView.camera.pitch = 70;
    self.mapView.showsBuildings = YES;
}

#pragma mark --初始化定位
-(void)initLocation{

    if (!self.localtionManage) {
        self.localtionManage = [[CLLocationManager alloc]init];
    }
    
    
    assert(self.localtionManage);
    
    
    
    // iOS 8 introduced a more powerful privacy model: <https://developer.apple.com/videos/wwdc/2014/?id=706>.
    // We use -respondsToSelector: to only call the new authorization API on systems that support it.
    //
    if ([self.localtionManage respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        
        [self.localtionManage requestWhenInUseAuthorization];
        
        
        // note: doing so will provide the blue status bar indicating iOS
        // will be tracking your location, when this sample is backgrounded
    }
    
    self.localtionManage.delegate = self; // tells the location manager to send updates to this object
    
    //设置定位精准度
    self.localtionManage.desiredAccuracy =kCLLocationAccuracyBest;
   
    // 最小更新距离
    self.localtionManage.distanceFilter = 10.0f;
    
    
    [self.localtionManage startUpdatingLocation];
}


#pragma mark -- locationManager


/*
 *  locationManager:didUpdateLocations:
 *
 *  Discussion:
 *    Invoked when new locations are available.  Required for delivery of
 *    deferred locations.  If implemented, updates will
 *    not be delivered to locationManager:didUpdateToLocation:fromLocation:
 *
 *    locations is an array of CLLocation objects in chronological order.
 */
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_6_0){
    
    CLLocation * currLocation = [locations lastObject];
    
    
    NSLog(@"%@",[NSString stringWithFormat:@"%.3f",currLocation.coordinate.latitude]);
    
    NSLog(@"%@",[NSString stringWithFormat:@"%.3f",currLocation.coordinate.longitude]);
    

    NSLog(@"%@",[NSString stringWithFormat:@"%.3f",currLocation.coordinate.latitude]);
    
    // update distance
    if (self.routes.count > 0) {
        self.distance += [currLocation distanceFromLocation:self.routes.lastObject];
    }
    
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:currLocation.coordinate.latitude longitude:currLocation.coordinate.longitude];

    [_routes addObject:location];
    
    
    //一次性执行：  设置地图中心点坐标位置
    static dispatch_once_t onceToken; dispatch_once(&onceToken, ^{
 
    });
    
  
    // code to be executed once
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = currLocation.coordinate.latitude;
    coordinate.longitude = currLocation.coordinate.longitude;
    
    //设置显示范围
    MKCoordinateRegion region;
    region.span.latitudeDelta = 0.03;
    region.span.longitudeDelta =0.03;//0.03
    region.center = coordinate;
    // 设置显示位置(动画)
    [self.mapView setRegion:region animated:YES];
    // 设置地图显示的类型及根据范围进行显示
    [self.mapView regionThatFits:region];
    
    //划线
    [self updateRouteView];
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    
    NSLog(@"定位失败");

}


/**
 TODO:重新绘制导航视图
 
 @author pigpigdaddy
 @since 3.0
 */
- (void)updateRouteView{
    [self.mapView removeOverlays:self.mapView.overlays];
    
    CLLocationCoordinate2D pointsToUse[[self.routes count]];
    for (int i = 0; i < [self.routes count]; i++) {
        CLLocationCoordinate2D coords;
        CLLocation *loc = [self.routes objectAtIndex:i];
        coords.latitude = loc.coordinate.latitude;
        coords.longitude = loc.coordinate.longitude;
        pointsToUse[i] = coords;
    }
    MKPolyline *lineOne = [MKPolyline polylineWithCoordinates:pointsToUse count:[self.routes count]];
    [self.mapView addOverlay:lineOne];
}



#pragma mark -- MapKit


- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay NS_AVAILABLE(10_9, 7_0)
{
    
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    
    renderer.strokeColor = [UIColor orangeColor];

    renderer.lineWidth = 4.0;
    renderer.alpha = 0.5;

    return  renderer;
    

}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation NS_AVAILABLE(10_9, 4_0){
    
 
    
    NSLog(@"map=%@",[NSString stringWithFormat:@"%.3f",userLocation.location.coordinate.latitude]);
    
    NSLog(@"map=%@",[NSString stringWithFormat:@"%.3f",userLocation.location.coordinate.longitude]);
    
    //self.title =[NSString stringWithFormat:@"%ld",_routes.count];
}


-(void)createSnapshot{

    /*
    [SVProgressHUD showWithStatus:@"Creating a screenshot..."
                         maskType:SVProgressHUDMaskTypeGradient];
     */
    
    MKMapSnapshotOptions *options = [[MKMapSnapshotOptions alloc] init];
    options.size = CGSizeMake(512, 512);
    options.scale = [[UIScreen mainScreen] scale];
    options.camera = self.mapView.camera;
    options.mapType = MKMapTypeStandard;
    
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:options];
    
    [snapshotter startWithCompletionHandler:^(MKMapSnapshot *snapshot, NSError *e)
     {
         if (e) {
             NSLog(@"error:%@", e);
         }
         else {
             
             /*
             [SVProgressHUD showSuccessWithStatus:@"done!"];
             
             self.imageView.image = snapshot.image;
              */
         }
     }];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc{
    self.localtionManage.delegate = nil;
    self.localtionManage = nil;
    self.mapView.delegate = nil;

}

@end
