import UIKit

protocol BasketControllerDelegate {
    func describeItem(retItem:Item)
}

class BasketViewController: UIViewController {
    
    let cellXibId = "NormalCell"
    let cellId = "Cell"
    var items:[Item?]!
    @IBOutlet weak var emptyImageField: UIView!
    var delegate:BasketControllerDelegate?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var basketProductsCollection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        basketProductsCollection.backgroundColor = UIColor.white
        basketProductsCollection.delegate = self
        basketProductsCollection.dataSource = self
        basketProductsCollection.register(UINib(nibName: cellXibId, bundle: nil), forCellWithReuseIdentifier: cellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.parent?.title = "Basket"
        super.viewWillAppear(animated)
        let OurDB = DBManager()
        items = OurDB.loadData(DB: "Basket")
        emptyView()
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
        cell.quantityLabel.text = String(items[indexPath.row]!.quantity)
        cell.buyButton.isHidden = true
        cell.favoriteButton.isHidden = true
        cell.delegate = self
        cell.addDeletePan()

        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Description", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DescriptionVC") as! DescriptionViewController
        controller.item = items[indexPath.row]!
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func emptyView(){
        if items.isEmpty{
            emptyImageField.isHidden = false
        }
        else{
            emptyImageField.isHidden = true
        }
    }
}


extension BasketViewController: NormalCellDelegate{
    func deleteCell(cell: NormalCell){
        let DB = DBManager()
        DB.removeData(DB: "Basket", item: cell.item!)
        if let index = items.index(of: cell.item!){
            items.remove(at: index)
        }
        viewWillAppear(true)
        basketProductsCollection.reloadData()
    }
}

