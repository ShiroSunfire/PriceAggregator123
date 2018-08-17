import UIKit

class BasketViewController: UIViewController {
    
    let cellXibId = "NormalCell"
    let cellId = "Cell"
    var items:[Item?]!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var basketProductsCollection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Basket"
        basketProductsCollection.backgroundColor = UIColor.white
        basketProductsCollection.delegate = self
        basketProductsCollection.dataSource = self
        basketProductsCollection.register(UINib(nibName: cellXibId, bundle: nil), forCellWithReuseIdentifier: cellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let OurDB = DBManager()
        items = OurDB.loadData(DB: "Basket")
        basketProductsCollection.reloadData()
    }
}

extension BasketViewController: UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
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
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 80)
    }
}


extension BasketViewController: NormalCellDelegate{
    func deleteCell(cell: NormalCell){
        let DB = DBManager()
        print("print")
        DB.removeData(DB: "Basket", item: cell.item!)
        for num in 0...items.count - 1{
            if items[num] == cell.item{
                items.remove(at: num)
                basketProductsCollection.reloadData()
                break
            }
        }
    }
}

