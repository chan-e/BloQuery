//
//  EditProfileViewController.m
//  BloQuery
//
//  Created by Eddy Chan on 9/29/16.
//  Copyright © 2016 Eddy Chan. All rights reserved.
//

#import "EditProfileViewController.h"
@import Photos;

@import Firebase;
#import "UIImageView+AFNetworking.h"

@interface EditProfileViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@property (strong, nonatomic) NSString *profileImageURL;
@property (strong, nonatomic) NSString *profileDescription;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;

@property (strong, nonatomic) FIRStorageReference *storageRef;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Database reference
    self.ref = [[FIRDatabase database] reference];
    self.usersRef = [[self.ref child:@"users"] child:self.userID];
    
    // Storage reference
    self.storageRef = [[FIRStorage storage] reference];
    
    self.descriptionTextView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self.usersRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        NSDictionary *user = snapshot.value;
        
        self.profileImageURL = user[@"profileImageURL"];
        self.profileDescription = user[@"description"];
        
        self.descriptionTextView.text = self.profileDescription;
        
        if (self.profileImageURL.length) {
            // Download the profile image
            NSURL *url = [NSURL URLWithString:self.profileImageURL];
            [self.userImageView setImageWithURL:url];
        }
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [self.usersRef updateChildValues:@{@"description": self.profileDescription}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.profileDescription = self.descriptionTextView.text;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *userID = [FIRAuth auth].currentUser.uid;
    
    NSString *imagePath = [NSString stringWithFormat:@"profile-images/%@/profile.JPG", userID];
    
    FIRStorageMetadata *metadata = [FIRStorageMetadata new];
    metadata.contentType = @"image/jpeg";
    
    NSURL *referenceUrl = info[UIImagePickerControllerReferenceURL];
    
    if (referenceUrl) {
        // It is an image from the library
        PHFetchResult* assets = [PHAsset fetchAssetsWithALAssetURLs:@[referenceUrl] options:nil];
        PHAsset *asset = assets.firstObject;
        
        [asset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput *contentEditingInput, NSDictionary *editingRequestInfo) {
            NSURL *imageFileURL = contentEditingInput.fullSizeImageURL;
            
            NSData *imageData = [NSData dataWithContentsOfURL:imageFileURL];
            UIImage *image = [UIImage imageWithData:imageData];
            
            NSData *resizedImageData = [self resizeImage:image];
            
            // Upload the image data
            [[self.storageRef child:imagePath] putData:resizedImageData metadata:metadata completion:^(FIRStorageMetadata *metadata, NSError *error) {
                if (error) {
                    NSLog(@"Error uploading: %@", error);
                    return;
                }
                
                [self uploadSuccess:metadata];
            }];
        }];
        
    } else {
        // It is an image from the camera
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        NSData *resizedImageData = [self resizeImage:image];
        
        // Upload the image data
        [[self.storageRef child:imagePath] putData:resizedImageData metadata:metadata completion:^(FIRStorageMetadata *metadata, NSError *error) {
            if (error) {
                NSLog(@"Error uploading: %@", error);
                return;
            }
            
            [self uploadSuccess:metadata];
        }];
    }
}

- (void)uploadSuccess:(FIRStorageMetadata *)metadata {
    self.profileImageURL = metadata.downloadURL.absoluteString;
    
    NSURL *url = [NSURL URLWithString:self.profileImageURL];
    [self.userImageView setImageWithURL:url];
    
    [self.usersRef updateChildValues:@{@"profileImageURL": self.profileImageURL}];
}

- (NSData *)resizeImage:(UIImage *)image {
    CGFloat actualWidth = image.size.width;
    CGFloat actualHeight = image.size.height;
    CGFloat actualRatio = actualWidth / actualHeight;
    
    CGFloat maxWidth = 300.0;
    CGFloat maxHeight = 400.0;
    CGFloat maxRatio = maxWidth / maxHeight;
    
    CGFloat targetWidth = 0.0;
    CGFloat targetHeight = 0.0;
    CGFloat compressionQuality = 0.8;
    
    if (actualWidth > maxWidth || actualHeight > maxHeight) {
        if(actualRatio > maxRatio) {
            targetWidth = maxWidth;
            targetHeight = maxWidth / actualRatio;
        }
        else if(actualRatio < maxRatio) {
            targetWidth = maxHeight * actualRatio;
            targetHeight = maxHeight;
        }
        else {
            targetWidth = maxWidth;
            targetHeight = maxHeight;
        }
    } else {
        targetWidth = actualWidth;
        targetHeight = actualHeight;
    }
    
    CGRect rect = CGRectMake(0.0, 0.0, targetWidth, targetHeight);
    
    UIGraphicsBeginImageContext(rect.size);
    
    [image drawInRect:rect];
    
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    NSData *resizedImageData = UIImageJPEGRepresentation(resizedImage, compressionQuality);
    
    UIGraphicsEndImageContext();
    
    return resizedImageData;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBActions

- (IBAction)dismissKeyboard:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self.descriptionTextView resignFirstResponder];
}

- (IBAction)doneButtonTapped:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeProfilePhoto:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Change Profile Photo" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:nil];
    }];
    
    UIAlertAction *chooseFromLibraryAction = [UIAlertAction actionWithTitle:@"Choose from Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:nil];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:cancelAction];
    [alert addAction:chooseFromLibraryAction];
    [alert addAction:takePhotoAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
