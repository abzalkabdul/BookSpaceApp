import UIKit
import Kingfisher

class PopularBooksViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var books: [Book] = []
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupActivityIndicator()
        setupRefreshControl()
        fetchPopularBooks()
    }
    
    private func setupUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupTableView() {
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
        
        NetworkService.shared.fetchPopularBooks { result in
            switch result {
            case .success(let books):
                self.books = books
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.showErrorAlert(error)
                }
            }
            
            // Останавливаем индикаторы на главном потоке
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                self.tableView.isHidden = false
            }
        }
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


extension PopularBooksViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
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


extension PopularBooksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showBookDetail", sender: nil)
    }
}
