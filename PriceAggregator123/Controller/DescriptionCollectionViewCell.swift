import UIKit

class DescriptionCollectionViewCell: UICollectionViewCell {
    

    
    @IBOutlet weak var cellImage: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
}
