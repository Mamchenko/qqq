//
//  ViewController.swift
//  RentateamImageView
//
//  Created by Anatoliy Mamchenko on 15.02.2021.
//

import UIKit


private let reuseIdentifire = "RickAndMortyCell"

class CharactersViewController: UIViewController  {
    
    
    
    
    
    let infoVC = InfoViewController()
    
    lazy private var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(frame: self.view.bounds)
        loader.style = .large
        loader.color = .white
        return loader
    }()
    
    lazy private var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        let collectionViewPosition = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        var collectionView = UICollectionView(frame: collectionViewPosition, collectionViewLayout: collectionViewLayout)
        collectionView.register(CharactersCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifire)
        collectionView.backgroundColor = UIColor(named: "mainBckgroundColor")
        return collectionView
    }()
    
    var presenter: CharactersPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = CharactersPresenter(controller: self)
        configureViewComponents()
        presenter?.getArrayOfCharacters()
    }
    
    
    
    private func addCollectionView() {
        view.addSubview(collectionView)
    }
    
    func configureViewComponents () {
        navigationController?.navigationBar.barTintColor = . white
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.title = "Rick and Morty"
        navigationItem.rightBarButtonItem?.tintColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

//MARK: - Collection view DataSource and Delegate
extension CharactersViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter?.getImageAndDate(by: Singleton.shared.arrayOfCharactersObject[indexPath.row].image, handler: { [weak self] (image, date) in
            self?.infoVC.imageView.image = image
            self?.infoVC.dateLabel.text = date.currentDateToString()
        })
        
        self.navigationController?.pushViewController(infoVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Singleton.shared.arrayOfCharactersObject.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifire, for: indexPath) as! CharactersCollectionViewCell
        cell.backgroundColor = UIColor(named: "cellColor")
        cell.layer.cornerRadius = 16
        cell.configConstraints()
        cell.nameLabel.text = Singleton.shared.arrayOfCharactersObject[indexPath.row].name
        presenter?.getImageAndDate(by: Singleton.shared.arrayOfCharactersObject[indexPath.row].image, handler: { (image, _) in
            cell.imageView.image = image
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        var rotatingTransform: CATransform3D
        if indexPath.row % 2 == 0 {
            rotatingTransform = duration(.fromLeft)
        }
        else {
            rotatingTransform = duration(.fromRright)
        }
        cell.layer.transform = rotatingTransform
        UIView.animate(withDuration: 0.5) {
            cell.layer.transform =  CATransform3DIdentity
        }
        
    }
    
    private func duration (_ from: AnimationDuration) -> CATransform3D {
        switch from {
        case .fromLeft:
            return CATransform3DTranslate(CATransform3DIdentity, -500, 0, 0)
        case .fromRright:
            return CATransform3DTranslate(CATransform3DIdentity, 500, 0, 0)
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension CharactersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 32, left: 8, bottom: 8, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 36) / 2
        let height = (view.frame.height - 36) / 3
        return CGSize(width: width, height: height)
    }
}

extension CharactersViewController: CharactersViewControllerProtocol {
    func startLoading() {
        view.addSubview(loader)
        loader.startAnimating()
    }
    
    func stopLoading() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) { [weak self] in
            self?.loader.stopAnimating()
            self?.addCollectionView()
        }
    }
    
    func collectionViewReloaded() {
        collectionView.reloadData()
    }
    
}


