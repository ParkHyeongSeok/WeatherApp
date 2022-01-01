//
//  MainViewController.swift
//  RxWeather
//
//  Created by 박형석 on 2022/01/01.
//  Copyright © 2022 Keun young Kim. All rights reserved.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import NSObject_Rx

class MainViewController: UIViewController, ViewModelBindableType {
    var viewModel: MainViewModel!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var weatherBackground: UIImageView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    func bindViewModel() {
        viewModel.output.title
            .bind(to: locationLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        viewModel.output.weatherData
            .observe(on: MainScheduler.asyncInstance)
            .do(onNext: { [weak self] weather in
                guard let summary = weather.first?.items.first else { return }
                self?.weatherBackground.image = UIImage.background(name: summary.icon)
            })
            .bind(to: listTableView.rx.items(dataSource: viewModel.dataSource))
            .disposed(by: rx.disposeBag)
        
        searchBar.rx.text.orEmpty
            .bind(to: viewModel.input.query)
            .disposed(by: rx.disposeBag)
                
        searchBar.rx.searchButtonClicked
                .do(onNext: { [weak self] in
                    if self?.listTableView.visibleCells.count ?? 0 > 0 {
                        self?.listTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    }
                    self?.searchBar.resignFirstResponder()
                })
            .bind(to: viewModel.input.searchButtonClicked)
            .disposed(by: rx.disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listTableView.backgroundColor = UIColor.clear
        listTableView.separatorStyle = .none
        listTableView.showsVerticalScrollIndicator = false
        listTableView.allowsSelection = false
        let searBarImage = UIImage()
        searchBar.backgroundImage = searBarImage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    var topInset: CGFloat = 0.0
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if topInset == 0.0 {
            let first = IndexPath(row: 0, section: 0)
            if let cell = listTableView.cellForRow(at: first) {
                topInset = listTableView.frame.height - cell.frame.height
                listTableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
            }
        }
    }
}

