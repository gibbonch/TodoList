import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        setupNavigationBar()
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = assemble()
        window?.makeKeyAndVisible()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    // MARK: - Private Methods
    
    private func assemble() -> UIViewController {
        return UINavigationController(rootViewController: TodoListViewController())
    }
    
    private func setupNavigationBar() {
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithDefaultBackground()
        standardAppearance.backgroundEffect = .init(style: .systemMaterialDark)
        
        standardAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.whiteAsset,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        standardAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 17)
        ]
        
        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.configureWithTransparentBackground()
        
        scrollEdgeAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.whiteAsset,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        scrollEdgeAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 17)
        ]
        
        UINavigationBar.appearance().standardAppearance = standardAppearance
        UINavigationBar.appearance().compactAppearance = standardAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = scrollEdgeAppearance
    }
}

