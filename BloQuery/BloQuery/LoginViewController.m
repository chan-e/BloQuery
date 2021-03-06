//
//  LoginViewController.m
//  BloQuery
//
//  Created by Eddy Chan on 8/25/16.
//  Copyright © 2016 Eddy Chan. All rights reserved.
//

#import "LoginViewController.h"
@import Firebase;

@interface LoginViewController () <UITextFieldDelegate>

@property (strong, nonatomic) FIRDatabaseReference *ref;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.ref = [[FIRDatabase database] reference];
    
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)showMessagePrompt:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [textField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [textField resignFirstResponder];
        [self tapOnLoginButton:nil];
    }
    
    return YES;
}

#pragma mark - IBActions

- (IBAction)tapOnLoginButton:(id)sender {
    [[FIRAuth auth] signInWithEmail:self.emailTextField.text
                           password:self.passwordTextField.text
                         completion:^(FIRUser *user, NSError *error) {
                             if (error) {
                                 [self showMessagePrompt:error.localizedDescription];
                                 return;
                             }
                             [self performSegueWithIdentifier:@"ShowPosts" sender:nil];
                         }];
}

- (IBAction)tapOnSignUpButton:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Sign Up"
                                                                   message:@"Enter username, email, and password"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Username";
        textField.returnKeyType = UIReturnKeyNext;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Email";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        textField.returnKeyType = UIReturnKeyNext;
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Password";
        textField.returnKeyType = UIReturnKeyDone;
        textField.secureTextEntry = YES;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *logInAction =
    [UIAlertAction actionWithTitle:@"Log In"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction *action) {
                               UITextField *usernameTextField = alert.textFields[0];
                               UITextField *emailTextField = alert.textFields[1];
                               UITextField *passwordTextField = alert.textFields[2];
                               
                               [[FIRAuth auth] createUserWithEmail:emailTextField.text
                                                          password:passwordTextField.text
                                                        completion:^(FIRUser *user, NSError *error) {
                                                            if (error) {
                                                                [self showMessagePrompt:error.localizedDescription];
                                                                return;
                                                            }
                                                            
                                                            FIRUserProfileChangeRequest *changeRequest = [[FIRAuth auth].currentUser profileChangeRequest];
                                                            changeRequest.displayName = usernameTextField.text;
                                                            
                                                            [changeRequest commitChangesWithCompletion:^(NSError *error) {
                                                                if (error) {
                                                                    [self showMessagePrompt:error.localizedDescription];
                                                                    return;
                                                                }
                                                                
                                                                [[[self.ref child:@"users"] child:user.uid] setValue:@{@"username": usernameTextField.text, @"description": @"", @"profileImageURL": @""}];
                                                                
                                                                [self performSegueWithIdentifier:@"ShowPosts" sender:nil];
                                                            }];
                                                        }];
                           }];
    
    [alert addAction:cancelAction];
    [alert addAction:logInAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)dismissKeyboard:(UITapGestureRecognizer *)recognizer {
    [self.view endEditing:YES];
}

#pragma mark - Unwind Segue

- (IBAction)unwindToLoginVC:(UIStoryboardSegue *)segue {
    NSError *error;
    [[FIRAuth auth] signOut:&error];
    if (error) {
        [self showMessagePrompt:error.localizedDescription];
        return;
    }
    
    // Sign-out succeeded
    
    self.emailTextField.text = @"";
    self.passwordTextField.text = @"";
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
