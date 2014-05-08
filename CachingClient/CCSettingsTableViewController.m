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

-(void)setClientLocation
{
    NSInteger location = [[NSUserDefaults standardUserDefaults] integerForKey:CLIENT_LOCATION_KEY];
    switch (location) {
        case CENTRAL_CLIENT:
            ;
            break;
        case EAST_CLIENT:
            ;
            break;
        case WEST_CLIENT:
            ;
            break;
        case ANTARCTICA_CLIENT:
            ;
            break;
        case NONE_CLIENT:
            ;
            break;
        default:
            break;
    }
}


-(void)forceServerLocation
{
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    switch (indexPath.section) {
        case 0:
            // reset
            NSLog(@"reset everything");
            [d removeObjectForKey:IMAGE_FULL_KEY];
            [d removeObjectForKey:IMAGE_THUMBS_KEY];
            [[SDImageCache sharedImageCache] clearDisk];
            [[SDImageCache sharedImageCache] clearMemory];
            [[CCImageManager sharedInstance].imageThumbsInfoArray removeAllObjects];
            [[CCImageManager sharedInstance].cachedImageInfoArray removeAllObjects];
            break;
        case 1:
            // client location
            [d setInteger:indexPath.row forKey:CLIENT_LOCATION_KEY];
            
        case 2:
            // master
            switch (indexPath.row) {
                case LOCALHOST_SERVER:
                    NSLog(@"localhost");
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
