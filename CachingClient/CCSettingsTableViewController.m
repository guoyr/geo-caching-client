//
//  CCSettingsTableViewController.m
//  CachingClient
//
//  Created by Robert Guo on 5/7/14.
//  Copyright (c) 2014 Robert Guo. All rights reserved.
//

#import <SDImageCache.h>
#import "CCSettingsTableViewController.h"
#import "CCImageManager.h"

@interface CCSettingsTableViewController ()

@end

@implementation CCSettingsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setCacheLife:(NSInteger)cacheLifeIndex
{
    NSInteger cacheLife = 0;
    switch (cacheLifeIndex) {
        case 0:
            cacheLife = 1;
            break;
        case 1:
            cacheLife = 5;
            break;
        case 2:
            cacheLife = 60;
            break;
        case 3:
            cacheLife = 300;
            break;
        case 4:
            cacheLife = 3600;
            break;
        case 5:
            cacheLife = 10800;
            break;
        default:
            break;
    }
    [[SDImageCache sharedImageCache] setMaxCacheAge:cacheLife];
}

-(void)setCacheSize:(NSInteger)cacheSizeIndex
{
    NSInteger cacheLife;
    switch (cacheSizeIndex) {
        case 0:
            cacheLife = 1;
            break;
        case 1:
            cacheLife = 2;
            break;
        case 2:
            cacheLife = 5;
            break;
        case 3:
            cacheLife = 10;
            break;
        case 4:
            cacheLife = 100;
            break;
        case 5:
            cacheLife = 0;
        default:
            break;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:cacheLife forKey:CACHE_SIZE_KEY];
}


-(void)forceServerLocation:(NSInteger)locationIndex
{
    switch (locationIndex) {
        case LOCALHOST_SERVER:
            
            break;
        case WEST_SERVER:
            ;
            break;
        case EAST_SERVER:
            ;
            break;
        case AUTOMATIC_SERVER:
            ;
            break;
        default:
            break;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];

    switch (indexPath.section) {
        case 0:
            // reset
            NSLog(@"reset everything");
            [d removeObjectForKey:IMAGE_FULL_KEY];
            [d removeObjectForKey:IMAGE_THUMBS_KEY];
            [[CCImageManager sharedInstance].imageCache clearDisk];
            [[CCImageManager sharedInstance].imageCache clearMemory];
            [[CCImageManager sharedInstance] removeAllImages];
            [[CCImageManager sharedInstance].imageThumbsInfoArray removeAllObjects];
            [[CCImageManager sharedInstance].cachedImageInfoArray removeAllObjects];
            break;
        case 1:
            // client location
            [d setInteger:indexPath.row forKey:SERVER_LOCATION_KEY];
            break;
        case 2:
            // cache life
            [self setCacheLife:indexPath.row];
            break;
        case 3:
            // cache size
            [self setCacheSize:indexPath.row];
            break;
        default:
            break;
    }
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

@end
