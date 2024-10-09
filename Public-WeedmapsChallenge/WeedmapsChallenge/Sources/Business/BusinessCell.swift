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
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var isClosedLabel: UILabel!
    @IBOutlet weak var yelpDescription: UILabel!
    @IBOutlet weak var phoneNumberView: UIView!
    
    weak var delegate: BusinessCellDelegate?
    private var phoneNumber: String = ""
    
    func configure(business: Business) {
        yelpImageView.image = fetchImage(url: business.imageURL)
        nameLabel.text = business.name
        ratingLabel.text = "Rating: \(business.rating)"
        
        if let number = business.phone, !number.isEmpty {
            phoneLabel.text = "Phone: \(number)"
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
    }
    
    private func setupUI() {
        phoneNumberView.isHidden = true
        
        // set preferred font
        nameLabel.font = UIFont.preferredFont(forTextStyle: .headline, weight: .medium, maxSize: 16)
        ratingLabel.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .medium, maxSize: 13)
        yelpDescription.font = UIFont.preferredFont(forTextStyle: .subheadline, weight: .medium, maxSize: 13)
    }
    
    private func fetchImage(url: String?) -> UIImage {
        
    }
    
    @IBAction func callBusiness(_ sender: Any) {
        delegate?.calling(number: phoneNumber)
    }
    
}
