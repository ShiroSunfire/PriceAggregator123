import UIKit

protocol DescriptionCellDelegate {
    func cellTaped(sender: UITapGestureRecognizer)
}

class DescriptionCollectionViewCell: UICollectionViewCell {
    
    var isFullScreeen = false
    var delegate:DescriptionCellDelegate?
    @IBOutlet weak var cellImage: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTapGestureRecognizer()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTapGestureRecognizer()
    }
    func downloadImage(with url:String){
        let currUrl = URL(string: url)
        URLSession.shared.dataTask(with: currUrl!) { (data, response, error) in
            if error != nil{
                print(error!)
                return
            }
            DispatchQueue.main.async {
                self.cellImage.image = UIImage(data: data!)
            }
        }.resume()
    }
    
    func addTapGestureRecognizer(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler(sender:)))
        self.addGestureRecognizer(tap)
    }
    
    @objc func tapGestureHandler(sender: UITapGestureRecognizer){
        isFullScreeen = !isFullScreeen
        delegate?.cellTaped(sender: sender)
    }
    
}
