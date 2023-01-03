//
//  DistinctSectionsViewController.swift
//  SampleCompositionalLayout
//
//  Created by Johnny Toda on 2023/01/03.
//

import UIKit

final class DistinctSectionsViewController: UIViewController {
    private enum SectionLayoutKind: Int, CaseIterable {
        case list, grid5, grid3, grid2
        // それぞれのSectionの列数を保持
        var columnCount: Int {
            switch self {
            case .list:
                return 1
            case .grid5:
                return 5
            case .grid3:
                return 3
            case .grid2:
                return 2
            }
        }
    }

    @IBOutlet private weak var distinctSectionsCollectionView: UICollectionView!

    // collectionViewに表示させるデータを管理するクラス
    private var dataSource: UICollectionViewDiffableDataSource<SectionLayoutKind, Int>! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
    }

    private func setUpCollectionView() {
        configureHierarchy()
        configureDataSource()
    }
}

extension DistinctSectionsViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnviroment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            guard let sectionLayoutKind = SectionLayoutKind(rawValue: sectionIndex) else { return nil }
            // 列数を保持
            let columns = sectionLayoutKind.columnCount

            // Itemサイズを定義
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )

            let item  = NSCollectionLayoutItem(layoutSize: itemSize)

            // 列数が1ならCollectionViewのwidth20%の値を返し、1ではない（もしくはnil)なら絶対値44を返す
            let groupHeight = columns == 1 ? NSCollectionLayoutDimension.absolute(44) : NSCollectionLayoutDimension.fractionalWidth(0.2)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: groupHeight
            )
//            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
//                                                           repeatingSubitem: item,
//                                                           count: columns)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)

            // もしsectionKindがgrid2ならばItem間の間隔は10空ける
            if sectionLayoutKind == .grid2 { group.interItemSpacing = .fixed(10) }
            let section = NSCollectionLayoutSection(group: group)
            // Section間の間隔を指定
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
            // もしsectionKindがgrid2ならばGroup間の間隔は10空ける
            if sectionLayoutKind == .grid2 { section.interGroupSpacing = 10 }

            return section
        }
        return layout
    }
}


extension DistinctSectionsViewController {
    private func configureHierarchy() {
        distinctSectionsCollectionView.collectionViewLayout = createLayout()

        // 🍎なくても特に問題はないように見える。
//        distinctSectionsCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        distinctSectionsCollectionView.backgroundColor = .systemBackground
        distinctSectionsCollectionView.register(TextCollectionViewCell.nib, forCellWithReuseIdentifier: TextCollectionViewCell.identifier)
    }

    private func configureDataSource() {
        // Cellの登録処理
        let listCellRegistration = UICollectionView.CellRegistration<ListCell, Int> { (cell, indexPath, identifier) in
            cell.label.text = "\(identifier)"
            cell.backgroundColor = .systemPink
        }

        let textCellRegistration = UICollectionView.CellRegistration<TextCell, Int> { cell, indexPath, identifier in
            cell.label.text = "\(identifier)"
            cell.label.textAlignment = .center
            cell.label.font = UIFont.preferredFont(forTextStyle: .title1)
            cell.contentView.backgroundColor = .systemYellow
            cell.contentView.layer.borderColor = UIColor.black.cgColor
            cell.contentView.layer.borderWidth = 1.0
            cell.contentView.layer.cornerRadius = cell.bounds.width / 2
        }

        // 3列表示バージョンのTextCellの登録処理
        let textCellGrid3Registration = UICollectionView.CellRegistration<TextCell, Int> { (cell, indexPath, identifier) in
            cell.label.text = "\(identifier)"
            cell.contentView.backgroundColor = .systemOrange
            cell.contentView.layer.borderColor = UIColor.black.cgColor
            cell.contentView.layer.borderWidth = 1
            cell.contentView.layer.cornerRadius = 20
            cell.label.textAlignment = .center
            cell.label.font = UIFont.preferredFont(forTextStyle: .title1)
        }

        // CollectionViewに渡すデータを代入
        dataSource = UICollectionViewDiffableDataSource<SectionLayoutKind, Int>(collectionView: distinctSectionsCollectionView, cellProvider:  { collectionView, indexPath, identifier in
            switch SectionLayoutKind(rawValue: indexPath.section)! {
            case .list:
                return collectionView.dequeueConfiguredReusableCell(using: listCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            case .grid5:
                return collectionView.dequeueConfiguredReusableCell(using: textCellRegistration,
                                                                    for: indexPath,
                                                                    item: identifier)
            case .grid3:
                return collectionView.dequeueConfiguredReusableCell(using: textCellGrid3Registration,
                                                                    for: indexPath,
                                                                    item: identifier)
            case .grid2:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TextCollectionViewCell.identifier, for: indexPath) as! TextCollectionViewCell
                cell.backgroundColor = .systemGreen
                cell.configure(number: identifier)
                cell.layer.cornerRadius = 10
                return cell
            }
        })
        // CollectionViewへのデータの反映を実行
        applySnapshot()
    }

    private func applySnapshot() {
        // SectionごとのItem数(1Sectionにつき10個のItemということになる。
        let itemsPerSection = 10

        // データをViewに反映させる為のDiffableDataSourceSnapshotクラスのインスタンスを生成
        var snapshot = NSDiffableDataSourceSnapshot<SectionLayoutKind, Int>()
        SectionLayoutKind.allCases.forEach {
            snapshot.appendSections([$0])

            // Rangeの最低値
            let itemOffset = $0.rawValue * itemsPerSection
            // Rangeの最高値
            let itemUpperbound = itemOffset + itemsPerSection - 1

            print("*******\($0), \($0.columnCount)の時*********")
            print("$0.rawValue: \($0.rawValue)")
            print("itemsPerSection: \(itemsPerSection)")
            print("itemOffset: \(itemOffset)")
            print("itemUpperbound: \(itemUpperbound)")


            print("Array(itemOffset...itemUpperbound): \(Array(itemOffset...itemUpperbound))")

            snapshot.appendItems(Array(itemOffset...itemUpperbound))
        }
        dataSource.apply(snapshot)
    }
}


