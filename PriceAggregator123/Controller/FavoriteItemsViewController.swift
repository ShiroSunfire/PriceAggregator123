

import UIKit

class FavoriteItemsViewController: UIViewController {
    
    var items:[Item?]!
    let cellXibId = "NormalCell"
    let cellId = "Cell"
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var favoriteProductsCollection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        favoriteProductsCollection.backgroundColor = UIColor.white
        favoriteProductsCollection.delegate = self
        favoriteProductsCollection.dataSource = self
        favoriteProductsCollection.register(UINib(nibName: cellXibId, bundle: nil), forCellWithReuseIdentifier: cellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let OurDB = DBManager()
        items = OurDB.loadData(DB: "Favourites")
        favoriteProductsCollection.reloadData()
    }
}


extension FavoriteItemsViewController: UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NormalCell
        cell.labelDescription.text = items[indexPath.row]?.name
        cell.item = items[indexPath.row]
        cell.image.image = (items[indexPath.row]?.thumbnailImage?.first)!
        cell.priceLabel.text = "$\((items[indexPath.row]?.price!)!)"
        cell.delegate = self
        cell.addDeletePan()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 80)
    }
}


extension FavoriteItemsViewController: NormalCellDelegate{
    func deleteCell(cell: NormalCell){
        let DB = DBManager()
        DB.removeData(DB: "Favourites", item: cell.item!)
        if let index = items.index(of: cell.item!){
            items.remove(at: index) 
        }
        favoriteProductsCollection.reloadData()
    }
}
