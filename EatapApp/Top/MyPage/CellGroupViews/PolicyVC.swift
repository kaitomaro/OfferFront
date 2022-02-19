//
//  PolicyVC.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/06/07.
//

import UIKit
import PDFKit

class PolicyVC: UIViewController {

    @IBOutlet weak var pdfView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "プライバシーポリシー", style: .plain, target: nil, action: nil)
        if let documentURL = Bundle.main.url(forResource: "policy", withExtension: "pdf") {
            if let document = PDFDocument(url: documentURL) {
                pdfView.document = document
                pdfView.autoScales = true
                pdfView.displayMode = .singlePageContinuous
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = "プライバシーポリシー"
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: #colorLiteral(red: 0, green: 0.6392156863, blue: 0.5058823529, alpha: 1),
            NSAttributedString.Key.font: UIFont(name: "NotoSansJP-Medium", size: 18.0)!
        ]
    }
}
