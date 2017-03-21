import UIKit
import SweetUIKit

protocol SearchResultsViewDelegate: class {
    func searchResultsView(_ searchResultsView: SearchResultsView, didTapApp app: TokenContact)
}

class SearchResultsView: UITableView {
    weak var selectionDelegate: SearchResultsViewDelegate?

    var results = [TokenContact]() {
        didSet {
            self.reloadData()
        }
    }

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)

        self.dataSource = self
        self.delegate = self
        self.separatorStyle = .none

        self.register(SearchResultCell.self)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchResultsView: UITableViewDataSource {

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(SearchResultCell.self, for: indexPath)
        let app = self.results[indexPath.row]
        cell.app = app

        return cell
    }
}

extension SearchResultsView: UITableViewDelegate {

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = self.results[indexPath.row]

        self.selectionDelegate?.searchResultsView(self, didTapApp: app)
    }
}
