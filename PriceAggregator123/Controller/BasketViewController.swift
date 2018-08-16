import UIKit

class BasketViewController: UIViewController {
    
    let cellXibId = "NormalCell"
    let cellId = "Cell"
    var item = [Item]()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var basketProductsCollection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Basket"
        basketProductsCollection.backgroundColor = UIColor.white
        basketProductsCollection.delegate = self
        basketProductsCollection.dataSource = self
        basketProductsCollection.register(UINib(nibName: cellXibId, bundle: nil), forCellWithReuseIdentifier: cellId)
        let db = DBManager()
        item = db.loadData(DB: "Basket")
    }
    
    
}

extension BasketViewController: UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return item.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NormalCell
        cell.labelDescription.text = item[indexPath.row].name
        cell.image.image = item[indexPath.row].thumbnailImage?.first
        cell.priceLabel.text = "$" + String(item[indexPath.row].price!)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 80)
    }


}

