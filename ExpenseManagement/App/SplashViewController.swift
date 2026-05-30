//
//  SplashViewController.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 14/02/26.
//


import UIKit
import LocalAuthentication
import CoreData

class SplashViewController: UIViewController {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "SplashIcon") ?? UIImage(systemName: "app")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let minimumSplashDuration: TimeInterval = 1.0
    private var startTime: Date = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("splashview")
        view.backgroundColor = .systemBackground
        setupIconImageView()
        startTime = Date()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkUserState()
    }

    private func setupIconImageView() {
        view.addSubview(iconImageView)
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 120),
            iconImageView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func checkUserState() {
        let context = CoreDataStack.shared.context
        
        let fetch: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        fetch.fetchLimit = 1
        
        do {
            let users = try context.fetch(fetch)
            
            if users.first == nil {
                let uuid = createDefaultUser()
                promptEnableLocalAuth(uuid: uuid)
                return
            }
            
            let uuid = fetchUserId() ?? UUID()
            let laEnabled = UserDefaults.standard.bool(forKey: "localAuthEnabled")
            if laEnabled {
                Task {
                    let success = await authenticateUser()
                    DispatchQueue.main.async {
                        if success {
                            self.proceedToDashboard(uuid: uuid)
                        } else {
                            self.showAuthFailedAlert()
                        }
                    }
                }
            } else {
                let laDisabledPermanently = UserDefaults.standard.bool(forKey: "localAuthDisabledPermanently")
                if laDisabledPermanently {
                    proceedToDashboard(uuid: uuid)
                    return
                }
                else {
                    promptEnableLocalAuth(uuid: uuid)
                }
            }
        } catch {
            print("Failed to fetch user: \(error)")
        }
    }

    private func authenticateUser() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            print("Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")")
            return false
        }
        
        do {
            try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Please authenticate to access your expenses")
            return true
        } catch let error {
            print("Authentication failed: \(error.localizedDescription)")
            return false
        }
    }

    private func proceedToDashboard(uuid: UUID) {
        self.loginUser(uuid: uuid)
        let mainTabBarController = MainTabBarController()
        if let sceneDelegate = UIApplication.shared.connectedScenes
            .compactMap({ $0.delegate as? SceneDelegate }).first {
            sceneDelegate.setRootViewController(mainTabBarController, animated: true)
        }
    }

    private func showAuthFailedAlert() {
        let alert = UIAlertController(title: "Authentication Failed", message: "We couldn't verify your identity. Try again or continue without biometrics.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: { [weak self] _ in
            Task { [weak self] in
                guard let self = self else { return }
                let success = await self.authenticateUser()
                DispatchQueue.main.async {
                    if success {
                        let uuid = self.fetchUserId() ?? UUID()
                        self.proceedToDashboard(uuid: uuid)
                    } else {
                        self.showAuthFailedAlert()
                    }
                }
            }
        }))
        present(alert, animated: true)
    }

    private func createDefaultUser() -> UUID {
        let context = CoreDataStack.shared.context
        let entity = NSEntityDescription.entity(forEntityName: "User", in: context)!
        let user = NSManagedObject(entity: entity, insertInto: context)
        let uuid = UUID()
        user.setValue(uuid, forKey: "id")
        user.setValue("user", forKey: "name")
        user.setValue("user@local.com", forKey: "email")
        user.setValue(true, forKey: "isAdmin")
        try? context.save()
        loginUser(uuid: uuid)
        return uuid
    }
    
    private func loginUser(uuid: UUID) {
        UserDefaults.standard.set(uuid.uuidString, forKey:"userId")
    }
    
    private func fetchUserId() -> UUID? {
        let context = CoreDataStack.shared.context
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let user = results.first as? NSManagedObject, let id = user.value(forKey: "id") as? UUID {
                return id
            }
        } catch {
            print("Failed to fetch user ID: \(error)")
        }
        return nil
    }

    private func promptEnableLocalAuth(uuid: UUID) {
        let alert = UIAlertController(title: "Enable Face ID / Touch ID?", message: "Would you like to enable biometric authentication for extra security?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Enable", style: .default) { _ in
            UserDefaults.standard.set(true, forKey: "localAuthEnabled")
                self.proceedToDashboard(uuid: uuid)
        })
        alert.addAction(UIAlertAction(title: "Not Now", style: .cancel) { _ in
            UserDefaults.standard.set(false, forKey: "localAuthEnabled")
                self.proceedToDashboard(uuid: uuid)
        })
        alert.addAction(UIAlertAction(title: "Never", style: .destructive) { _ in
            UserDefaults.standard.set(false, forKey: "localAuthEnabled")
            UserDefaults.standard.set(true, forKey: "localAuthDisabledPermanently")
                self.proceedToDashboard(uuid: uuid)
        })
        present(alert, animated: true)
    }
    
    private func completeAfterMinimumDuration(_ completion: @escaping () -> Void) {
        let elapsed = Date().timeIntervalSince(startTime)
        let remaining = max(0, minimumSplashDuration - elapsed)
        DispatchQueue.main.asyncAfter(deadline: .now() + remaining) {
            completion()
        }
    }
}

