import UIKit

class BasketViewController: UIViewController {
    
    let cellXibId = "NormalCell"
    let cellId = "Cell"
    
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
}

extension BasketViewController: UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NormalCell
        cell.labelDescription.text = String(indexPath.row)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 80)
    }


}

