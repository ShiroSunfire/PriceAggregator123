import UIKit
import SwiftyJSON

protocol SearchViewControllerDelegate {
    func cellWasTapped(id:Int)
}

class SearchViewController: UIViewController {

    @IBOutlet private weak var changeViewButton: UIButton!
    @IBOutlet private weak var fromPrice: UITextField!
    @IBOutlet private weak var toPrice: UITextField!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var collectionView: UICollectionView!
    private var urlCreate : [String:String] = ["query":"", "numItems":"10", "facetRange":"", "format":"json", "apiKey":"jx9ztwc42y6mfvvhfa4y87hk"]
    private var jsonItems :JSON?
    private var url = "http://api.walmartlabs.com/v1/search?"
    private var categoryId = ""
    private var nibShow = "Normal"
    private var changeView = false
    private var isOpenCategory = false
    private var refresh:RefreshImageView?
    private var delegate: SearchViewControllerDelegate?
    private let gjson = GetJSON()
    private var arrayItems = [Item]()
    var choosenCell:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.removeObject(forKey: "UserID")
        if UserDefaults.standard.string(forKey: "UserID") == nil {
            showLoginVC()
        }
        let placeholderSearchBarText = NSLocalizedString("Input the name of the product", comment: "")
        searchBar.placeholder = placeholderSearchBarText
        collectionView.register(UINib(nibName: "NormalCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        getItems(with: URL(string: "http://api.walmartlabs.com/v1/trends?format=json&apiKey=jx9ztwc42y6mfvvhfa4y87hk"))
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.layer.backgroundColor = UIColor.white.cgColor
            textfield.layer.cornerRadius = 8
        }
        changeViewButton.setBackgroundImage(UIImage(named: "menurectangle"), for: UIControlState.normal)
    }
    
    private func showLoginVC() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "Load") as! LoginViewController
        self.present(controller, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        choosenCell = nil
        self.parent?.title = NSLocalizedString("All", comment: "")
        navigationController?.delegate = self
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        collectionView.reloadData()
    }
    
    func getURL() -> URL? {
        var newURL = url + "query" + "=" + urlCreate["query"]!.replacingOccurrences(of: " ", with: "", options: [])
        newURL += "&" + "start" + "=" + String(arrayItems.count + 1)
        newURL += "&" + "numItems" + "=" + urlCreate["numItems"]!
        newURL += "&" + "format" + "=" + urlCreate["format"]!
        newURL += "&" + "apiKey" + "=" +  urlCreate["apiKey"]!
        if urlCreate["facetRange"] != "" {
            newURL += urlCreate["facetRange"]!
        }
        return URL(string: newURL)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func returnJson(_ json: JSON) {
        if json["totalResults"].int == 0 {
            DispatchQueue.main.async {
                self.refresh?.removeFromSuperview()
                self.refresh = nil
                self.showAlert(title: "No items found, please try another products", message: "")
            }
            return
        }
        jsonItems = json["items"]
        var i = 0, j = arrayItems.count
        while json["items"][i] != JSON.null && i<10 {
            arrayItems.append(gjson.appendInArrayItem(json: json["items"], i: i))
            gjson.downloadImage(with: URL(string: json["items"][i]["thumbnailImage"].string!)!, i: j, completion: saveDownloadImage(_:_:))
            i+=1
            j+=1
        }
        DispatchQueue.main.asyncAfter(wallDeadline: .now()+2) {
            self.collectionView.reloadData()
        }
    }
    
    func saveDownloadImage(_ image: UIImage, _ index: Int) {
        if index > arrayItems.count {
            return
        }
        arrayItems[index].thumbnailImage = [UIImage]()
        arrayItems[index].thumbnailImage?.append(image)
        if (index+1)%10 == 0 {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func getItems(with url: URL?) {
        setRefresh()
        self.gjson.getItems(with: url, completion: returnJson(_:))
    }
    
    @IBAction func categoriesButtonTapped(_ sender: UIButton) {
        if isOpenCategory {
            needCloseLastSubviews()
            return
        }
        openCategoryVC()
        isOpenCategory = true
    }
    
    private func setRefresh() {
        if refresh == nil {
            refresh = RefreshImageView(center: self.view.center)
            self.view.addSubview(refresh!)
        }
    }
    
    private func openCategoryVC() {
        guard let categoriesVC = storyboard?.instantiateViewController(withIdentifier: "categoriesVC") as? CategoriesViewController else { return }
        categoriesVC.delegate = self
        categoriesVC.view.frame.origin = CGPoint(x: -categoriesVC.view.frame.size.width, y: searchBar.frame.size.height+UIApplication.shared.statusBarFrame.height)
        categoriesVC.view.frame.size = CGSize(width: 230, height: self.view.frame.size.height-searchBar.frame.size.height-UIApplication.shared.statusBarFrame.height)
        let newView = TouchView(frame: CGRect(origin: CGPoint(x: 0, y: searchBar.frame.size.height+UIApplication.shared.statusBarFrame.height), size: CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height-searchBar.frame.size.height-UIApplication.shared.statusBarFrame.height)))
        newView.delegate = self
        newView.backgroundColor = UIColor.black
        newView.alpha = 0
        self.view.addSubview(newView)
        self.addChildViewController(categoriesVC)
        self.view.addSubview(categoriesVC.view)
        UIView.animate(withDuration: 1) {
            categoriesVC.view.frame.origin.x = 0
            newView.alpha = 0.2
        }
    }
    
    @IBAction func choseCellButton(_ sender: Any) {
        if nibShow == "Normal" {
            collectionView.register(UINib(nibName: "RectangleCell", bundle: nil), forCellWithReuseIdentifier: "RectangleCell")
            nibShow = "Rectangle"
        } else if nibShow == "Rectangle" {
            collectionView.register(UINib(nibName: "NormalCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
            nibShow = "Normal"
        }
        if changeView{
            changeViewButton.setBackgroundImage(nil, for: UIControlState.normal)
            changeViewButton.setBackgroundImage(UIImage(named: "menurectangle.png"), for: UIControlState.normal)
            changeView = false
        } else {
            changeViewButton.setBackgroundImage(nil, for: UIControlState.normal)
            changeViewButton.setBackgroundImage(UIImage(named: "menuline.png"), for: UIControlState.normal)
            changeView = true
        }
        collectionView.reloadData()
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(arrayItems.count)
        return arrayItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if refresh != nil {
            refresh?.removeFromSuperview()
            refresh = nil
        }
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! NormalCell
        if nibShow == "Rectangle" {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RectangleCell", for: indexPath) as! NormalCell
        }
        cell.delegate = self
        cell.labelDescription.text = arrayItems[indexPath.row].name!
        cell.item = arrayItems[indexPath.row]
        cell.image.image = arrayItems[indexPath.row].thumbnailImage?.first
        cell.priceLabel.text = "$" + String(arrayItems[indexPath.row].price ?? 0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if nibShow == "Normal" {
            return CGSize(width: view.frame.size.width, height: 100)
        } else {
            return CGSize(width: view.frame.size.width/2, height: 300)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if arrayItems.count % 10 == 0 && indexPath.row == (arrayItems.count - 1) && urlCreate["query"] != "" {
            print("Refresh data")
            getItems(with: getURL())
        } else if arrayItems.count % 10 == 0 && indexPath.row == (arrayItems.count - 1) {
            print("Resresh data category")
            getItemsInArray()
        }
    }
    
    private func getItemsInArray() {
        let dispatch = DispatchQueue(label: "com.concurrent.quene", qos: DispatchQoS.background, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.never, target: nil)
        dispatch.async {
            let count = self.arrayItems.count
            var i = count
            while i < count + 10 && self.jsonItems![i] != JSON.null {
                self.arrayItems.append(self.gjson.appendInArrayItem(json: self.jsonItems!, i: i))
                self.gjson.downloadImage(with: URL(string: self.jsonItems![i]["thumbnailImage"].string!)!, i: i, completion: self.saveDownloadImage(_:_:))
                i += 1
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        choosenCell = collectionView.cellForItem(at: indexPath)
        openDescriptionVC(index: indexPath.row)
    }
    
    private func openDescriptionVC(index: Int) {
        let storyboard = UIStoryboard(name: "Description", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "DescriptionVC") as! DescriptionViewController
        controller.tabBarItem = self.tabBarItem
        controller.item = arrayItems[index]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing()
    }
    
    private func endEditing() {
        searchBar.endEditing(true)
        fromPrice.endEditing(true)
        toPrice.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        setRefresh()
        searchBar.endEditing(true)
        urlCreate["query"] = searchBar.text!
        arrayItems.removeAll()
        getItems(with: getURL())
    }
}

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing()
        arrayItems.removeAll()
        var from = Int(fromPrice.text!)
        if from == nil {
            from = 0
        }
        var to = Int(toPrice.text!)
        if to == nil {
            to = 10000
        }
        urlCreate["facetRange"] = "&facet.range=price:[\(from!)%20TO%20\(to!)]"
        setRefresh()
        getItems(with: getURL())
        return true
    }
}

extension SearchViewController: CategoriesViewControllerDelegate {
    func needCloseLastSubviews() {
        isOpenCategory = false
        for sub in self.view.subviews {
            if sub is UITableView {
                UIView.animate(withDuration: 1, animations: {
                    sub.frame.origin.x = -sub.frame.size.width
                }) { _ in
                    sub.removeFromSuperview()
                }
            } else if sub is TouchView {
                UIView.animate(withDuration: 1, animations: {
                    sub.alpha = 0
                }) { _ in
                    sub.removeFromSuperview()
                }
            }
        }
    }
    
    func searchButtonTapped(with id: String) {
        arrayItems.removeAll()
        urlCreate["facetRange"] = ""
        urlCreate["query"] = ""
        toPrice.text = ""
        fromPrice.text = ""
        searchBar.text = ""
        getItems(with: URL(string: "http://api.walmartlabs.com/v1/paginated/items?format=json&category=\(id)&apiKey=jx9ztwc42y6mfvvhfa4y87hk")!)
    }
}

extension SearchViewController: NormalCellDelegate {
    func buyButtonTapped(db: String, item: Item) {
        showAlert(title: "Item added to basket", message: "")
        let db = DBManager()
        db.saveData(database: .basket, item: item)
    }
    
    func favoriteButtonTapped(db: String, item: Item) {
        showAlert(title: "Item added to favorite", message: "")
        let db = DBManager()
        db.saveData(database: .favorites, item: item)
    }
}

extension SearchViewController: TouchViewDelegate {
    func touchView(view: TouchView) {
        isOpenCategory = false
        UIView.animate(withDuration: 1, animations: {
            view.alpha = 0
            self.view.subviews.last!.frame.origin.x = -self.view.subviews.last!.frame.size.width
        }) { (_) in
            view.removeFromSuperview()
            self.view.subviews.last?.removeFromSuperview()
        }
    }
}



extension SearchViewController: UINavigationControllerDelegate{
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC:
        UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push{
            let transition = CustomPush()
            guard let originFrame = choosenCell.superview?.convert(choosenCell.frame, to: nil) else {
                return transition
            }
            transition.originFrame = originFrame
            transition.presenting = true
            return transition
        } else {
            return CustomPop()
        }
    }
}



