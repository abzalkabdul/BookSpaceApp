import UIKit
import Kingfisher

class PopularBooksVС: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var books: [Book] = []
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NetworkService.shared.delegate = self
        setupActivityIndicator()
        setupRefreshControl()
        fetchPopularBooks()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupActivityIndicator() {
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    // MARK: - Data Fetching
    private func fetchPopularBooks() {
        // Показываем индикатор загрузки только если это первая загрузка
        if books.isEmpty {
            activityIndicator.startAnimating()
            tableView.isHidden = true
        }
        NetworkService.shared.fetchPopularBooks()
    }
    
    @objc private func refreshData() {
        fetchPopularBooks()
    }
    
    // MARK: - Error Handling
    private func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: "Failed to load books: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.fetchPopularBooks()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBookDetail",
           let detailVC = segue.destination as? DetailBookVC,
           let indexPath = tableView.indexPathForSelectedRow {
            detailVC.book = books[indexPath.row]
        }
    }
}


extension PopularBooksVС: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Popular Books"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .blue
        if let header = view as? UITableViewHeaderFooterView {
                header.textLabel?.textColor = .white // цвет текста
            }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell",for: indexPath) as? BookTableViewCell else {
            return UITableViewCell()
        }
        let book = books[indexPath.row]
        cell.configure(with: book)
        
        return cell
    }
}
extension PopularBooksVС: NetworkServiceDelegate {
    func didFetchBooks(_ books: [Book]) {
        self.books = books
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    func didFetchBookDetails(_ book: Book) {
    }
    
    func didFailWithError(_ error: NetworkError) {
        activityIndicator.stopAnimating()
        refreshControl.endRefreshing()
        tableView.isHidden = false
        showErrorAlert(error)
    }
}

extension PopularBooksVС: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showBookDetail", sender: nil)
    }
}
