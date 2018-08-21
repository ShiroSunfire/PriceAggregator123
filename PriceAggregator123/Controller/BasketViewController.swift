import UIKit


class BasketViewController: FavoriteItemsViewController{
    @IBOutlet weak var basketProductsCollection: UICollectionView!
    
    override func viewDidLoad() {
        databaseName = "Basket"
        favoriteProductsCollection = basketProductsCollection
        super.viewDidLoad()
    }
    
    
    override  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NormalCell
        cell.labelDescription.text = items[indexPath.row]?.name
        cell.item = items[indexPath.row]
        cell.image.image = (items[indexPath.row]?.thumbnailImage?.first)!
        cell.priceLabel.text = "$\((items[indexPath.row]?.price!)!)"
        cell.quantityLabel.text = String(items[indexPath.row]!.quantity)
        cell.buyButton.isHidden = true
        cell.favoriteButton.isHidden = true
        cell.delegate = self
        cell.addDeletePan()
        
        
        return cell
    }
}
