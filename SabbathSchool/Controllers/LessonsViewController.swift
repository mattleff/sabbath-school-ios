//
//  LessonsViewController.swift
//  SabbathSchool
//
//  Created by Heberti Almeida on 26/02/16.
//  Copyright © 2016 Adventech. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Firebase
import Unbox

final class LessonsViewController: BaseTableViewController {
    var database: FIRDatabaseReference!
    var quarterlyInfo: QuarterlyInfo!
    
    // MARK: - Init
    
    init(quarterlyIndex: String) {
        super.init()
        tableNode.delegate = self
        tableNode.dataSource = self
        
        title = "Lesson".uppercased()
        backgroundColor = UIColor.baseBlue
        
        database = FIRDatabase.database().reference()
        database.keepSynced(true)
        
        // Load data
        let emptyQuarterly = Quarterly(id: "", title: "", description: "", humanDate: "", startDate: Date(), endDate: Date(), cover: URL(string: "a:/a")!, index: "", path: "", fullPath: URL(string: "a:/a")!, lang: "")
        quarterlyInfo = QuarterlyInfo(quarterly: emptyQuarterly, lessons: [])
        
        loadQuarterlyInfo(quarterlyIndex: quarterlyIndex)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackButtom()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideNavigationBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    //
    
    func loadQuarterlyInfo(quarterlyIndex: String) {
        database.child("quarterly-info").child(quarterlyIndex).observe(.value, with: { (snapshot) in
            guard let json = snapshot.value as? [String: AnyObject] else { return }
            
            do {
                let item: QuarterlyInfo = try unbox(dictionary: json)
                self.quarterlyInfo = item
                
                self.tableNode.view.beginUpdates()
                self.tableNode.view.reloadData()
                self.tableNode.view.endUpdates()
            } catch let error {
                print(error)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}

// MARK: - ASTableDataSource

extension LessonsViewController: ASTableDataSource {
    
    func tableView(_ tableView: ASTableView, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let quarterly = quarterlyInfo.quarterly
        
        // this will be executed on a background thread - important to make sure it's thread safe
        let cellNodeBlock: () -> ASCellNode = {
            if indexPath.section == 0 {
                let node = FeaturedQuarterlyCellNode(
                    title: quarterly.title,
                    subtitle: quarterly.humanDate,
                    cover: quarterly.cover
                )
                node.backgroundColor = self.backgroundColor
                return node
            }
            
            let lesson = self.quarterlyInfo.lessons[indexPath.row]
            let node = LessonCellNode(
                title: lesson.title,
                subtitle: "\(lesson.startDate.stringLessonDate()) - \(lesson.endDate.stringLessonDate())",
                number: "\(indexPath.row+1)"
            )
            return node
        }
        return cellNodeBlock
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : quarterlyInfo.lessons.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

// MARK: - ASTableDelegate

extension LessonsViewController: ASTableDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 30 {
            showNavigationBar()
        } else {
            hideNavigationBar()
        }
    }
}
