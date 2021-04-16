//
//  LoginViewController.swift
//  GoogleMapsTracker
//
//  Created by Александр Ипатов on 10.04.2021.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet var loginRouter: LoginRouter!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func loginButton(_ sender: Any) {
        loginButtonTapped()
    }
    @IBAction func signUpButton(_ sender: Any) {
        signUpButtonTapped()
    }
    private let authService = AuthService.shared

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // MARK: - Methods
    private func setupInputSecurity() {
        loginTextField.autocorrectionType = .no
        passwordTextField.isSecureTextEntry = true
    }

    private func loginButtonTapped() {
        authService.login(login: loginTextField.text, password: passwordTextField.text) { (result) in
            switch result{
            case .success(let user):
                self.showAlert(title: "Success", message: "Hello! \(user.login)") {
                    self.loginRouter.toMain()
                }
            case .failure(let error):
                self.showAlert(title: "Error!", message: error.localizedDescription)
            }
        }
    }
    private func signUpButtonTapped(){
        authService.signUp(login: loginTextField.text, password: passwordTextField.text) { (result) in
            switch result {
            case .success(let user):
                self.showAlert(title: "Success", message: "Hello! \(user.login)"){
                    self.loginRouter.toMain()
                }
            case .failure(let error):
                self.showAlert(title: "Error!", message: error.localizedDescription)
            }
        }
    }

}
extension LoginViewController {
    func showAlert(title: String,
                   message: String, completion: @escaping () -> Void = { }) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            completion()
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
