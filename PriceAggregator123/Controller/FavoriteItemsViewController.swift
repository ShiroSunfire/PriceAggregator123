

import UIKit

class FavoriteItemsViewController: UIViewController {
    
    var items:[Item?]!
    private let cellXibId = "NormalCell"
    let cellId = "Cell"
    private var choosenView:UIView!
    @IBOutlet weak var emptyImageField: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var favoriteProductsCollection: UICollectionView!
    
    var databaseName = "Favourites"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoriteProductsCollection.backgroundColor = UIColor.white
        favoriteProductsCollection.register(UINib(nibName: cellXibId, bundle: nil), forCellWithReuseIdentifier: cellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.parent?.title = NSLocalizedString(databaseName, comment: "")
        super.viewWillAppear(animated)
        let OurDB = DBManager()
        items = OurDB.loadData(DB: databaseName)
        emptyView()
        navigationController?.delegate = self
        choosenView = nil
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
        choosenView = collectionView.cellForItem(at: indexPath)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func emptyView(){
        if items.isEmpty{
            emptyImageField.isHidden = false
        }
        else{
            emptyImageField.isHidden = true
        }
    }
}


extension FavoriteItemsViewController: NormalCellDelegate{
    func deleteCell(cell: NormalCell){
        let DB = DBManager()
        DB.removeData(DB: databaseName, item: cell.item!)
        if let index = items.index(of: cell.item!){
            items.remove(at: index) 
        }
        emptyView()
        favoriteProductsCollection.reloadData()
    }
    
    func buyButtonTapped(db: String, item: Item) {
        let alert = UIAlertController(title: "Item added to basket", message: "", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
            self.dismiss(animated: true, completion: nil)
        })
        let db = DBManager()
        db.saveData(DB: "Basket", item: item)
    }
}

extension FavoriteItemsViewController: UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC:
        UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push{
            let transition = CustomPush()
            guard let originFrame = choosenView.superview?.convert(choosenView.frame, to: nil) else {
                return transition
            }
            transition.originFrame = originFrame
            transition.presenting = true
            return transition
        }else{
            return CustomPop()
        }
        
    }
    
}

