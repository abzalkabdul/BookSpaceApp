import UIKit

class BookTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bookImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configure(with book: Book) {
        titleLabel.text = book.title
        authorLabel.text = book.authors?.joined(separator: ", ") ?? "Unknown"
        descriptionLabel.text = book.description ?? "No description"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bookImageView.image = nil
        titleLabel.text = nil
        authorLabel.text = nil
        descriptionLabel.text = nil
    }
}
