//
//  LoginController.swift
//  SwiftChat
//
//  Created by Jon Reed on 1/25/18.
//  Copyright © 2018 Jon Reed. All rights reserved.
//


import UIKit
import Firebase

/// Class which defines the login/register view controller
class LoginController: UIViewController {

// Setup of class level variables, such as image views, buttons, and text fields
@IBOutlet weak var loginRegisterButton: UIButton!
    
var messagesController: FileTableViewController?
    
/* Setup UI code for each input view and containers */
let inputsContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.white
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.cornerRadius = 5
    view.layer.masksToBounds = true
    return view
}()
    

let nameTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Name"
    tf.translatesAutoresizingMaskIntoConstraints = false
    return tf
}()

let nameSeparatorView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
}()

let emailTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Email"
    tf.translatesAutoresizingMaskIntoConstraints = false
    tf.autocorrectionType = .no
    tf.keyboardType = UIKeyboardType.emailAddress
    tf.textContentType = UITextContentType("")
    return tf
}()

let emailSeparatorView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
}()

let passwordTextField: UITextField = {
    let tf = UITextField()
    tf.placeholder = "Password"
    tf.translatesAutoresizingMaskIntoConstraints = false
    tf.isSecureTextEntry = true
    tf.autocorrectionType = .no
    tf.textContentType = UITextContentType("")
    return tf
}()

let OSULogoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "osu_athletics")
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    return imageView
}()

// Fucntion which is called upon first appearance of the view
override func viewWillAppear(_ animated: Bool) {
        nameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
    }
// Called when the view is loaded into memory
override func viewDidLoad() {
    super.viewDidLoad()
    
    // Modify background color
    view.backgroundColor = UIColor(r: 150, g: 150, b: 150)
    
    // Add the subviews for each text input container
    view.addSubview(inputsContainerView)
    view.addSubview(loginRegisterButton)
    view.addSubview(OSULogoImageView)
    view.addSubview(loginRegisterSegmentedControl)
    
    // Setup functionality of each button, and segmented control
    setupLoginRegisterButton()
    setupInputsContainerView()
    setupLogoImageView()
    setupLoginRegisterSegmentedControl()
}

/// Function which sets up vertical and horizontal constraints for OSU logo
func setupLogoImageView() {

    OSULogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    OSULogoImageView.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -60).isActive = true
    
    //profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 15).isActive = true
    OSULogoImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
    OSULogoImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
}

    func setupInputsContainerView() {
        //need x, y, width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        //need x, y, width, height constraints
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        
        emailTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
/// Function which sets up the constraints and styling on the register button on the login page
func setupLoginRegisterButton() {
    loginRegisterButton.backgroundColor = UIColor(r: 193, g: 62, b: 62)
    loginRegisterButton.setTitle("Register", for: UIControlState())
    loginRegisterButton.translatesAutoresizingMaskIntoConstraints = false
    loginRegisterButton.setTitleColor(UIColor.white, for: UIControlState())
    loginRegisterButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    //need x, y, width, height constraints
    loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
    loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
        loginRegisterButton.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
   
}
/// Function which determines function call for login/registerbutton based on selected segment control
@objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleUserRegistration()
        }
    }
    
/// Function which performs Firebase login
func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
    
    // UI alert to user if empty password or email
    if((emailTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)!){
        let alert = UIAlertController(title: "Invalid username or password", message: "Please ensure both the username and password fields are nonempty ", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
        return
    }
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if let error = error {
                let errorAlert = UIAlertController(title: "Login error", message: error.localizedDescription, preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
                self.present(errorAlert, animated: true)
                return
            }
            //successfully logged in our user
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "tabBarNav")
        
            self.present(vc!, animated: true, completion: nil)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.isLoggedIn = true
            self.updateOnlineStatus()
        })
    }
    
    
    
    func handleUserRegistration() {
        guard let email = emailTextField.text, let password = passwordTextField.text, var name = nameTextField.text else {
            print("Form is not valid") // Make this a UI alert
            return
        }
        name.append(": ")
        name.append(UIDevice.current.name)
        // UI alert to user if empty password or email
        if((emailTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)! || (nameTextField.text?.isEmpty)!){
            let alert = UIAlertController(title: "Invalid name, username or password", message: "Please ensure all input fields are nonempty ", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            return
        }
        
        // UI alert to user if empty password or email
        if(((passwordTextField.text?.count)! < 6)){
            let alert = UIAlertController(title: "Password too short", message: "Password must be at least 6 characters long", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            return
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            
            if let error = error {
                let errorAlert = UIAlertController(title: "Registration Error", message: error.localizedDescription,preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
                self.present(errorAlert, animated: true)
                return
            }
            guard let uid = user?.uid else {
                return
            }
            
            // If we have successfully authenticated the user, update the database
            let ref = FIRDatabase.database().reference()
            let usersReference = ref.child("users").child(uid)
            let fileManager = FileManager.default
            let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let allFiles = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            var filesString = [String]()
            
            for file in allFiles{
                filesString.append(file.lastPathComponent)
            }
        
            
            let values = ["name": name, "email": email, "online": "Online", "files": filesString] as [String : Any]
          
            usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if let err = err {
                    print(err) // Print any errors with database registration to the console
                    return
                }
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "tabBarNav")
                self.present(vc!, animated: true, completion: nil)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.isLoggedIn = true
            })
        })
    }
    
    @objc func updateUserFiles() {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let allFiles = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
        var filesString = [String]()
        
        for file in allFiles{
            filesString.append(file.lastPathComponent)
        }
        let values = ["files": filesString]
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        FIRDatabase.database().reference().child("users").child(uid).updateChildValues(values)
        
        //        do {
        //            try FIRAuth.auth()?.signOut()
        //        } catch let logoutError {
        //            print(logoutError)
        //        }
        //
        //        self.dismiss(animated: true, completion: nil)
    }
    
    func updateOnlineStatus(){
        let values = ["online": "Online"]
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
         FIRDatabase.database().reference().child("users").child(uid).updateChildValues(values)

    }
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    
    func setupLoginRegisterSegmentedControl() {
        //need x, y, width, height constraints
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    @objc func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: UIControlState())
        
        // change height of inputContainerView, but how???
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        // change height of nameTextField
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        nameTextField.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 0
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }


    

    // We want to use the light statusbar style, so override this variable
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

/// Global variable for device screen width
public var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
}

/// Global variable for device screen height
public var screenHeight: CGFloat {
    return UIScreen.main.bounds.height
}


/// Extention for handling instantiation of a new UI color
extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
}
