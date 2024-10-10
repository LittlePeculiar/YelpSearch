//
//  Copyright © 2022 Weedmaps, LLC. All rights reserved.
//

import UIKit

protocol BusinessCellDelegate: AnyObject {
    func calling(number: String)
}

class BusinessCell: UITableViewCell {
    @IBOutlet weak var yelpImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var phoneTitleLabel: UILabel!
    @IBOutlet weak var isClosedLabel: UILabel!
    @IBOutlet weak var yelpDescription: UILabel!
    @IBOutlet weak var phoneNumberView: UIView!
    @IBOutlet weak var bgView: UIView!
    
    weak var delegate: BusinessCellDelegate?
    private var phoneNumber: String = ""
    
    func configure(api: APIService, business: Business) {
        
        nameLabel.text = business.name
        ratingLabel.text = "Rating:  "
        createStars(rating: business.rating)
        
        if let number = business.phone, !number.isEmpty {
            print("phone: \(number)")
            phoneLabel.text = "\(number.formatPhoneNumber())"
            phoneLabel.textColor = .blue
            phoneNumber = number
            phoneNumberView.isHidden = false
        }
        
        if let isClosed = business.isClosed {
            isClosedLabel.text = isClosed ? "Closed" : "Open"
            isClosedLabel.textColor = isClosed ? .red : .green
        }
        
        // build yelp business description
        var string = "Business Description:"
        for category in business.categories {
            string.append(" \(category.title),")
        }
        
        // remove the comma
        string.removeLast()
        yelpDescription.text = string
        
        Task {
            await yelpImageView.image = fetchImage(api: api, imageURL: business.imageURL)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        setupUI()
    }
    
    override func prepareForReuse() {
        yelpImageView.image = nil
        nameLabel.text = nil
        ratingLabel.text = nil
        yelpDescription.text = nil
        phoneLabel.text = nil
        isClosedLabel.text = nil
    }
    
    private func setupUI() {
        bgView.layer.cornerRadius = 10
        bgView.layer.masksToBounds = true
        phoneNumberView.isHidden = true
        
        // set preferred font
        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline, weight: .medium, maxSize: 16)
        ratingLabel.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .medium, maxSize: 13)
        yelpDescription.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .medium, maxSize: 13)
        phoneLabel.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .medium, maxSize: 13)
        phoneTitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .medium, maxSize: 13)
        isClosedLabel.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .medium, maxSize: 13)
    }
    
    private func createStars(rating: Double) {
        ratingStackView.subviews.forEach { $0.removeFromSuperview() }
        
        let starCount: Int = Int(rating)
        for _ in 0..<starCount {
            if let image = UIImage(systemName: "star.fill") {
                let imageView = UIImageView(image: image)
                imageView.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
                imageView.tintColor = .systemRed
                ratingStackView.addArrangedSubview(imageView)
            }
            
        }
    }
    
    @MainActor func fetchImage(api: APIService, imageURL: String?) async -> UIImage? {
        guard let url = imageURL else { return nil }
        do {
            let image = try await api.fetchImage(urlPath: url)
            return image
        } catch let error {
            print("error fetching image: \(url) :: \(error.localizedDescription)")
        }
        return nil
    }
    
    @IBAction func callBusiness(_ sender: Any) {
        delegate?.calling(number: phoneNumber)
    }
    
}
