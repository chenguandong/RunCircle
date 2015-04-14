//
//  ViewController.h
//  RunCircle
//
//  Created by chenguandong on 15/4/13.
//  Copyright (c) 2015年 chenguandong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "CrumbPath.h"
#import "CrumbPathRenderer.h"
#import "LongitudeAndlatitudeModel.h"
@interface ViewController : UIViewController<CLLocationManagerDelegate,MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property(nonatomic,strong) CLLocationManager *localtionManage;

@property (nonatomic, strong) CrumbPath *crumbs;

@property (nonatomic, strong) CrumbPathRenderer *crumbPathRenderer;

//路线点
@property (nonatomic, retain) NSMutableArray                     *routes;
//记录当前时间的计时器
@property (nonatomic, strong) NSTimer *timer;

//seconds 当前时间秒数

@property(nonatomic,assign)int seconds;

@property (weak, nonatomic) IBOutlet UITextView *infoText;

//步速
@property float distance;
@end

