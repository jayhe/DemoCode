//
//  ViewController.m
//  Lottery
//
//  Created by hechao on 15/12/25.
//  Copyright © 2015年 hechao. All rights reserved.
//

#import "ViewController.h"
#include "stdlib.h"
typedef NS_ENUM(NSInteger,BollType)
{
    BollTypeRed,
    BollTypeBlue
};

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *lotteryBtn;
@property (weak, nonatomic) IBOutlet UILabel *redBollL;
@property (weak, nonatomic) IBOutlet UILabel *blueBollL;
@property (weak, nonatomic) IBOutlet UITableView *lotteryTable;
@property (strong, nonatomic) NSMutableArray *selectedRedBollA;
@property (strong, nonatomic) NSMutableArray *selectedBlueBollA;
@property (strong, nonatomic) NSMutableArray *luckyLotteryA;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self viewConfig];
}

- (void)viewConfig
{
    _lotteryBtn.layer.cornerRadius = _lotteryBtn.frame.size.width/2;
    _lotteryBtn.layer.borderColor = [UIColor redColor].CGColor;
    _lotteryBtn.layer.borderWidth = 2.0;
}

- (void)initData
{
    _selectedRedBollA   = [NSMutableArray array];
    _selectedBlueBollA  = [NSMutableArray array];
    _luckyLotteryA      = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (IBAction)clearBtnPressed:(UIButton *)sender
{
    if (_selectedRedBollA.count == 6 && _selectedBlueBollA.count >=1)
    {
        [self setHistoryLotteryList];
    }
    [self resetSelectedBolls];
    [_lotteryTable reloadData];
}

- (IBAction)lotteryBtnPressed:(UIButton *)sender
{
    if (_selectedRedBollA && _selectedRedBollA.count < 6)
    {
        NSInteger luckyBoll = [self randomlyDrewANumberWithType:BollTypeRed];
        [_selectedRedBollA addObject:@(luckyBoll)];
        [self resetSelectedBollsWithType:BollTypeRed];
    }else if(_selectedBlueBollA.count < 15)
    {
        NSInteger luckyBoll = [self randomlyDrewANumberWithType:BollTypeBlue];
        [_selectedBlueBollA addObject:@(luckyBoll)];
        [self resetSelectedBollsWithType:BollTypeBlue];
    }
}

#pragma mark - Custom Methods

- (void)setHistoryLotteryList
{
    [_selectedRedBollA sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSInteger num1 = (NSInteger)obj1;
        NSInteger num2 = (NSInteger)obj2;
        return num1 > num2;
    }];
    
    [_selectedBlueBollA sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSInteger num1 = (NSInteger)obj1;
        NSInteger num2 = (NSInteger)obj2;
        return num1 > num2;
    }];
    
    NSAttributedString *redBolls = [[NSAttributedString alloc] initWithString:[_selectedRedBollA componentsJoinedByString:@" "] attributes:@{NSForegroundColorAttributeName:[UIColor redColor]}];
    NSAttributedString *blueBolls = [[NSAttributedString alloc] initWithString:[_selectedBlueBollA componentsJoinedByString:@" "] attributes:@{NSForegroundColorAttributeName:[UIColor blueColor]}];
    NSAttributedString *nulls = [[NSAttributedString alloc] initWithString:@" "];
    NSMutableAttributedString *attributeS = [[NSMutableAttributedString alloc] init];
    [attributeS appendAttributedString:redBolls];
    [attributeS appendAttributedString:nulls];
    [attributeS appendAttributedString:blueBolls];
    [_luckyLotteryA addObject:attributeS];
}

- (void)resetSelectedBolls
{
    [_selectedBlueBollA removeAllObjects];
    [_selectedRedBollA removeAllObjects];
    [self resetSelectedBollsWithType:BollTypeBlue];
    [self resetSelectedBollsWithType:BollTypeRed];
}

- (void)resetSelectedBollsWithType:(BollType)bollType
{
    if (bollType == BollTypeRed)
    {
        NSString *bollStr = [_selectedRedBollA componentsJoinedByString:@"  "];
        _redBollL.text = [NSString stringWithFormat:@"红球：%@",bollStr];
    }else
    {
        NSString *bollStr = [_selectedBlueBollA componentsJoinedByString:@"  "];
        _blueBollL.text = [NSString stringWithFormat:@"蓝球：%@",bollStr];
    }
}

#pragma mark - Arithmetic
- (NSInteger)randomlyDrewANumberWithType:(BollType)bollType
{
    NSInteger bollCount = (bollType == BollTypeRed)?32:16;
    NSMutableArray *bollsArray = [[NSMutableArray alloc] initWithCapacity:bollCount];
    // 将牌按顺序摆放
    for(int i=0; i< bollCount;i++){
        [bollsArray addObject:[NSNumber numberWithInt:i+1]];
    }
    // 对已经摇出来的号码删除掉
    switch (bollType)
    {
        case BollTypeRed:
        {
            if (_selectedRedBollA.count)
            {
                [_selectedRedBollA enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [bollsArray removeObject:obj];
                }];
            }
        }
            break;
        case BollTypeBlue:
        {
            if (_selectedBlueBollA.count)
            {
                [_selectedBlueBollA enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [bollsArray removeObject:obj];
                }];
            }
        }
            break;
        default:
            break;
    }
    // 循环将倒数第n张牌中的随机一张放到整个扑克的最后
    NSInteger unselectedCount = bollCount - ((bollType == BollTypeRed)?_selectedRedBollA.count:_selectedBlueBollA.count);
    for(NSInteger n = unselectedCount-1;n>=1;n--){
        int randIndex = (int)(random()/(float)RAND_MAX*n);
        NSNumber *pokeMoveToEnd = [bollsArray objectAtIndex:randIndex];
        [bollsArray removeObjectAtIndex:randIndex];
        [bollsArray addObject:pokeMoveToEnd];
    }
    NSInteger luckyIndex = arc4random()%unselectedCount;
    NSInteger luckyBoll = [bollsArray[luckyIndex] integerValue];
    return luckyBoll;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _luckyLotteryA.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifer = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifer];
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    [cell.textLabel setAttributedText:_luckyLotteryA[indexPath.row]];
    return cell;
}
@end
