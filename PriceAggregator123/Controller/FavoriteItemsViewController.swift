

import UIKit

class FavoriteItemsViewController: UIViewController {
    
    var items:[Item!]!
    let cellXibId = "NormalCell"
    let cellId = "Cell"
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var favoriteProductsCollection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Favorites"
        favoriteProductsCollection.backgroundColor = UIColor.white
        favoriteProductsCollection.delegate = self
        favoriteProductsCollection.dataSource = self
        favoriteProductsCollection.register(UINib(nibName: cellXibId, bundle: nil), forCellWithReuseIdentifier: cellId)
        let OurDB = DBManager()
        items = OurDB.loadData(DB: "Favourites")
    }
}


extension FavoriteItemsViewController: UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NormalCell
        cell.labelDescription.text = items[indexPath.row].name
        cell.image.image = (items[indexPath.row].thumbnailImage?.first)!
        cell.priceLabel.text = String(items[indexPath.row].price!)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 80)
    }
}
