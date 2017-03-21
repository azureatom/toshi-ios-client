import UIKit

public class MessagingNavigationController: UINavigationController {

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.tabBarItem = UITabBarItem(title: "Messages", image: #imageLiteral(resourceName: "messages"), tag: 0)
        self.tabBarItem.titlePositionAdjustment.vertical = TabBarItemTitleOffset
    }

    public required init?(coder _: NSCoder) {
        fatalError("")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public func openThread(withAddress address: String) {
        self.popToRootViewController(animated: false)
        guard let chatsController = self.topViewController as? ChatsController else { fatalError() }

        let thread = chatsController.thread(withAddress: address)
        let messagesController = MessagesViewController(thread: thread, chatAPIClient: chatsController.chatAPIClient)

        self.pushViewController(messagesController, animated: false)
    }
}
