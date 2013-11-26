//
//  ViewController.m
//  AddShopCar demo
//
//  Created by tripbe on 13-6-20.
//  Copyright (c) 2013年 lkk. All rights reserved.
//

#import "ViewController.h"
#import "UIGlossyButton.h"
#import "UIView+LayerEffects.h"
#import  <QuartzCore/QuartzCore.h>

@interface ViewController()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *dataList;
    __weak IBOutlet UITableView *mainTable;
    int addPrice;
    int allPrice;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"demodata" ofType:@"plist"];
    dataList = [[NSMutableArray alloc] initWithContentsOfFile:path];
    [mainTable setDelegate:self];
    [mainTable setDataSource:self];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    mainTable = nil;
    [super viewDidUnload];
}

#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataList.count;
}
- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 70, 70)];
        [logo setTag:11];
        [cell addSubview:logo];
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(90, 0, 200, 40)];
        [nameLabel setTag:22];
        [cell addSubview:nameLabel];
        
        UILabel *contentLabel = [[UILabel alloc]initWithFrame:CGRectMake(90, 40, 200, 40)];
        [contentLabel setText:@"价格仅供参考哦亲～"];
        [cell addSubview:contentLabel];
        
        UIGlossyButton *priceBt = [UIGlossyButton buttonWithType:UIButtonTypeCustom];
        [priceBt useWhiteLabel:YES];
        priceBt.tintColor = [UIColor lightGrayColor];
        [priceBt setFrame:CGRectMake(215, 15, 80, 30)];
        [priceBt.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [priceBt setTag:33];
        [priceBt addTarget:self action:@selector(addToShopCar:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:priceBt];
    }
    NSDictionary *dic = [dataList objectAtIndex:indexPath.row];
    UIImageView *logo = (UIImageView *)[cell viewWithTag:11];
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:22];
    UIGlossyButton *priceBt = (UIGlossyButton *)[cell viewWithTag:33];
    [logo setImage:[UIImage imageNamed:[dic valueForKey:@"logo"]]];
    [nameLabel setText:[dic valueForKey:@"name"]];
    [priceBt setTitle:[NSString stringWithFormat:@"￥%@",[dic valueForKey:@"price"]] forState:UIControlStateNormal];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

//加入购物车 步骤1
- (void)addToShopCar:(UIButton *)bt{
    //得到产品信息
    UITableViewCell *cell = (UITableViewCell *)[bt superview];
    NSIndexPath *indexPath = [mainTable indexPathForCell:cell];
    NSDictionary *dic = [dataList objectAtIndex:indexPath.row];
    addPrice = [[dic valueForKey:@"price"]intValue];
    
    UIButton *shopCarBt = (UIButton*)[self.view viewWithTag:44];
    
    //加入购物车动画效果
    CALayer *transitionLayer = [[CALayer alloc] init];
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    transitionLayer.opacity = 1.0;
    transitionLayer.contents = (id)bt.titleLabel.layer.contents;
    transitionLayer.frame = [[UIApplication sharedApplication].keyWindow convertRect:bt.titleLabel.bounds fromView:bt.titleLabel];
    [[UIApplication sharedApplication].keyWindow.layer addSublayer:transitionLayer];
    [CATransaction commit];
    
    //路径曲线
    UIBezierPath *movePath = [UIBezierPath bezierPath];
    [movePath moveToPoint:transitionLayer.position];
    CGPoint toPoint = CGPointMake(shopCarBt.center.x, shopCarBt.center.y+60);
    [movePath addQuadCurveToPoint:toPoint
                     controlPoint:CGPointMake(shopCarBt.center.x,transitionLayer.position.y-120)];
    //关键帧
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.path = movePath.CGPath;
    positionAnimation.removedOnCompletion = YES;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.beginTime = CACurrentMediaTime();
    group.duration = 0.7;
    group.animations = [NSArray arrayWithObjects:positionAnimation,nil];
    group.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    group.delegate = self;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.autoreverses= NO;
    
    [transitionLayer addAnimation:group forKey:@"opacity"];
    [self performSelector:@selector(addShopFinished:) withObject:transitionLayer afterDelay:0.5f];
}
//加入购物车 步骤2
- (void)addShopFinished:(CALayer*)transitionLayer{
    
    [mainTable reloadData];
    transitionLayer.opacity = 0;
    UIButton *shopCarBt = (UIButton*)[self.view viewWithTag:55];
    if (shopCarBt.hidden) {
        NSString *str = [NSString stringWithFormat:@"￥%i",addPrice];
        [shopCarBt setTitle:str forState:UIControlStateNormal];
        [shopCarBt setHidden:NO];
    }
    else{
        allPrice = allPrice + addPrice;
        NSString *str = [NSString stringWithFormat:@"￥%i",allPrice];
        [shopCarBt setTitle:str forState:UIControlStateNormal];
        
        //加入购物车动画效果
        UILabel *addLabel = (UILabel*)[self.view viewWithTag:66];
        [addLabel setText:[NSString stringWithFormat:@"+%i",addPrice]];
        
        CALayer *transitionLayer1 = [[CALayer alloc] init];
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        transitionLayer1.opacity = 1.0;
        transitionLayer1.contents = (id)addLabel.layer.contents;
        transitionLayer1.frame = [[UIApplication sharedApplication].keyWindow convertRect:addLabel.bounds fromView:addLabel];
        [[UIApplication sharedApplication].keyWindow.layer addSublayer:transitionLayer1];
        [CATransaction commit];
        
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(addLabel.frame.origin.x+30, addLabel.frame.origin.y+20)];
        positionAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(addLabel.frame.origin.x+30, addLabel.frame.origin.y)];
        
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
        opacityAnimation.toValue = [NSNumber numberWithFloat:0];
        
        CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        rotateAnimation.fromValue = [NSNumber numberWithFloat:0 * M_PI];
        rotateAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.beginTime = CACurrentMediaTime();
        group.duration = 0.3;
        group.animations = [NSArray arrayWithObjects:positionAnimation,opacityAnimation,nil];
        group.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        group.delegate = self;
        group.fillMode = kCAFillModeForwards;
        group.removedOnCompletion = NO;
        group.autoreverses= NO;
        [transitionLayer1 addAnimation:group forKey:@"opacity"];
    }
}
@end
