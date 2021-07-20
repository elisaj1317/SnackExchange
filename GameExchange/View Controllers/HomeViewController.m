//
//  HomeViewController.m
//  GameExchange
//
//  Created by Elisa Jacobo Arill on 7/13/21.
//

#import "HomeViewController.h"
#import "DetailsViewController.h"
#import "RequestCell.h"

#import "SceneDelegate.h"
#import "APIManager.h"
#import <Parse/Parse.h>


@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *requests;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self setUpRefresh];
    [self fetchRequests];
    
    [[APIManager shared] getGamesWithCompletion:^(NSArray *data, NSError *error) {
        if(error){
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"Data2: %@", data);
        }
    }];
    
    
}

- (IBAction)didTapLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
            if (!error) {
                [self segueToLogin];
            } else {
                NSLog(@"User log out failed: %@", error.localizedDescription);
            }
    }];
}

- (void)setUpRefresh {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchRequests) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)fetchRequests {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Request"];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"author"];
    query.limit = 20;
    
    // fetch data
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable requests, NSError * _Nullable error) {
        if(!error) {
            self.requests = [NSMutableArray arrayWithArray:requests];
            
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void) segueToLogin {
    SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavBarController"];
    sceneDelegate.window.rootViewController = loginViewController;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RequestCell"];
    cell.request = self.requests[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.requests.count;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"detailsSegue"]) {
        // Passes selected Request into DetailsViewController
        UITableViewCell *tappedCell = sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
        Request *request = self.requests[indexPath.row];
        
        DetailsViewController *detailsViewController = [segue destinationViewController];
        
        detailsViewController.request = request;
    }
}


@end
