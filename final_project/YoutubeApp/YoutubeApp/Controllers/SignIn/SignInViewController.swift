//
//  SignInViewController.swift
//  YoutubeApp
//
//  Created by Admin on 18/01/2024.
//

import UIKit
import GoogleAPIClientForREST
import GoogleSignIn
import FirebaseDatabase

class SignInViewController: UIViewController {
    
    let viewModel = SignInViewModel()
    private let scopes = [kGTLRAuthScopeYouTubeReadonly,
                          kGTLRAuthScopeYouTubeForceSsl,
                          kGTLRAuthScopeYouTube,
                          kGTLRAuthScopeYouTubeUpload ]
    private let service = GTLRYouTubeService()
    
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        checkForLoginSucess()
    }
    
    private func setup() {
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        setupViews()
    }
    
    private func checkForLoginSucess() {
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            // User is already signed in
            if let scene = UIApplication.shared.connectedScenes.first,
               let sd = (scene.delegate as? SceneDelegate) {
                sd.changeScreen(type: .main)
            }
        } else {
            print("User not signed in")
        }
    }
    
    private func setupViews() {
        buttonLoginGoogle()
    }
    
    private func buttonLoginGoogle() {
        loginButton.layer.cornerRadius = 5
        loginButton.layer.borderWidth = 0.5
        loginButton.layer.shadowColor =  UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        loginButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        loginButton.layer.shadowOpacity = 1.0
        loginButton.layer.shadowRadius = 0.0
        loginButton.layer.masksToBounds = false
        loginButton.layer.cornerRadius = 4.0
        
        if let imageLogo = UIImage(named: "google_logo")?.resizedImage(with: CGSize(width: 30, height: 30)) {
            loginButton.setImage(imageLogo, for: .normal)
        }
        loginButton.setTitle("Login with Google", for: .normal)
        let spacing: CGFloat = 10
        loginButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing, bottom: 0, right: spacing)
        loginButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: -spacing)
        loginButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
    }
}

extension SignInViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.loginButton.isHidden = true // Hide login button after successful sign in
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            
            
//            // Assuming you have a UserModel
//            let userModel = UserModel(name: user.profile.name, email: user.profile.email, /* other user data */)
//
//            // Write user data to Firebase
//            usersRef.child(user.userID).setValue(userModel.toDictionary())
            
            print(GIDSignIn.sharedInstance().currentUser.authentication.accessToken as String)
            
            checkForLoginSucess()
            
            viewModel.loadMyChannel { done, msg in
                if done {
                    let user = DataManager.shared().getChannelFromUserDefaults()
                    print("user default ",user?.avatarChannelUrl)
                } else {
                    
                }
            }
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
