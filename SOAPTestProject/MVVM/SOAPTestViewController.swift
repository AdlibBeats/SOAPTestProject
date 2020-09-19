//
//  SOAPTestViewController.swift
//  SOAPTestProject
//
//  Created by Andrew on 18.09.2020.
//  Copyright © 2020 Andrew. All rights reserved.
//

import Cartography
import Lottie
import RxCocoa
import RxDataSources
import RxSwift

final class SOAPTestViewController: UIViewController {
    private let animationView = AnimationView(name: "loadingAnimation").then { $0.alpha = 0.0 }
    private let disposeBag = DisposeBag()
    private let viewModel: SOAPTestViewModelProtocol
    
    init(with viewModel: SOAPTestViewModelProtocol) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let tableView = UITableView().then {
        $0.register(
            SOAPTestTableViewCell.self,
            forCellReuseIdentifier: String(describing: SOAPTestTableViewCell.self)
        )
        $0.tableHeaderView = UIView().with { $0.backgroundColor = .white }
        $0.tableFooterView = UIView().with { $0.backgroundColor = .white }
        $0.sectionFooterHeight = 0
        $0.sectionHeaderHeight = 0
        $0.rowHeight = UITableView.automaticDimension
        $0.estimatedRowHeight = 56
        $0.clipsToBounds = true
        $0.allowsSelection = false
        $0.backgroundColor = .white
        $0.alpha = 0.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Optimal fares offers"
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        func setConstraints() {
            guard let view = view else { return }
            
            view.addSubview(tableView)
            
            constrain(view, tableView) { view, tableView in
                tableView.left == view.left
                tableView.top == view.top
                tableView.right == view.right
                tableView.bottom == view.bottom
            }
        }
        
        func setAnimationViewConstraints() {
            guard let view = view else { return }
            
            animationView.removeFromSuperview()
            view.addSubview(animationView)
            
            constrain(view, animationView) { view, animationView in
                animationView.width == 200
                animationView.height == 200
                animationView.center == view.center
            }
        }
        
        func bind() {
            let output = viewModel.transform(with: .init())
            
            output.loading.drive(onNext: { [weak self] loading in
                if loading {
                    setAnimationViewConstraints()
                    
                    UIView.animate(withDuration: 0.3) {
                        self?.animationView.alpha = 1.0
                        self?.tableView.alpha = 0.0
                    }
                    self?.animationView.play(fromProgress: 0, toProgress: 1, loopMode: .loop)
                } else {
                    UIView.animate(
                        withDuration: 0.3,
                        animations: {
                            self?.animationView.alpha = 0.0
                            self?.tableView.alpha = 1.0
                        },
                        completion: { _ in
                            self?.animationView.stop()
                            self?.animationView.removeFromSuperview()
                        }
                    )
                }
            }).disposed(by: disposeBag)
            
            output.source.asObservable().bind(
                to: tableView.rx.items(
                    cellIdentifier: String(describing: SOAPTestTableViewCell.self),
                    cellType: SOAPTestTableViewCell.self
                ),
                curriedArgument: { $2.model = $1 }
            ).disposed(by: disposeBag)
        }
        
        setConstraints()
        bind()
    }
}
