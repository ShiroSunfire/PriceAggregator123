import UIKit


class BasketViewController: FavoriteItemsViewController{
    @IBOutlet weak var basketProductsCollection: UICollectionView!
    
    override func viewDidLoad() {
        favoriteProductsCollection = basketProductsCollection
        super.viewDidLoad()
        self.title = NSLocalizedString("Basket", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sourceDatabase = .basket
    }
    
    override  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NormalCell
        cell.delegate = self
        cell.labelDescription.text = items[indexPath.row]?.name
        cell.item = items[indexPath.row]
        cell.image.image = (items[indexPath.row]?.thumbnailImage?.first)!
        cell.priceLabel.text = "$\((items[indexPath.row]?.price!)!)"
        cell.quantityLabel.layer.backgroundColor = UIColor(red: 142.0/255, green: 194.0/255, blue: 234.0/255, alpha: 1).cgColor
        cell.quantityLabel.layer.cornerRadius = cell.quantityLabel.frame.height / 3
        cell.quantityLabel.isHidden = false
        cell.quantityLabel.text = String(items[indexPath.row]!.quantity)
        cell.buyButton.isHidden = true
        cell.favoriteButton.isHidden = true
        cell.addDeletePan()
        return cell
    }
}
