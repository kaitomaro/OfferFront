//
//  TopViewController.swift
//  EatapApp
//
//  Created by 加藤　大起 on 2021/05/04.
//

import UIKit

class TopViewController: UIViewController,UIScrollViewDelegate {

    @IBOutlet weak var toLoginButton: UIButton!
    @IBOutlet weak var toRegisterButton: UIButton!
    @IBOutlet weak var skipLoginButton: UIButton!
    @IBOutlet weak var kiyakuLabel: UILabel!
    
    @IBOutlet weak var finishTurotialButton: UIButton!
    
    var scrollView: UIScrollView!
    var pageControll: UIPageControl!
    let pageNum = 4
    
    let pageColors:[Int:UIImage] = [
        1: UIImage(named: "tutorial1")!,
        2: UIImage(named: "tutorial2")!,
        3: UIImage(named: "tutorial3")!,
        4: UIImage(named: "tutorial4")!
    ]
    
    var activityIndicatorView = UIActivityIndicatorView()
    let kiyakuText = "利用規約"
    let privacyText = "プライバシーポリシー"
    let text = "プライバシーポリシー・利用規約に同意して"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !(UserDefaults.standard.bool(forKey: "doneInitialLoad")) {
            setUpScrollView()
        }
        self.view.bringSubviewToFront(finishTurotialButton)
        kiyakuLabel.isUserInteractionEnabled = true
        kiyakuLabel.text = text
        let kiyakuString = kiyakuLabel!.text!
        let kiyakuRange = (kiyakuString as NSString).range(of: kiyakuText)
        let privacyRange = (kiyakuString as NSString).range(of: privacyText)
        let attributedKiyaku = NSMutableAttributedString(string: kiyakuString)
        attributedKiyaku.addAttributes(
            [
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            ], range: kiyakuRange
        )
        attributedKiyaku.addAttributes(
            [
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            ], range: privacyRange
        )
        kiyakuLabel.attributedText = attributedKiyaku
        let kiyakuRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapKiyaku(_:)))
        kiyakuLabel.addGestureRecognizer(kiyakuRecognizer)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                self.navigationController?.setNavigationBarHidden(true, animated: false)
        toRegisterButton.layer.cornerRadius = 22
    }
    
    func setUpScrollView(){
        scrollView = UIScrollView(frame: self.view.bounds)
        scrollView.contentSize = CGSize(width: self.view.bounds.width * CGFloat(pageNum), height: self.view.bounds.height)
        
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        self.view.addSubview(self.scrollView)
        self.pageControll = UIPageControl(frame: CGRect(x:0, y:self.view.bounds.height-50, width: self.view.bounds.width, height: 50))
        self.pageControll.numberOfPages = pageNum
        self.pageControll.currentPage = 0
        self.view.addSubview(self.pageControll)

        for p in 1...pageNum {
            var v = UIImageView(frame: CGRect(x: self.view.bounds.width * CGFloat(p-1), y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
            v.backgroundColor = #colorLiteral(red: 0.5733121037, green: 0.8155091405, blue: 0.3133224845, alpha: 1)
            v.contentMode = .scaleAspectFit
            v.image = self.pageColors[p]!
            self.scrollView.addSubview(v)
        }
    }
    
    @objc func tapKiyaku(_ sender: UITapGestureRecognizer) {
        let kiyakuRange = (text as NSString).range(of: "利用規約")
        let privacyRange = (text as NSString).range(of: "プライバシーポリシー")
        if sender.didTapAttributedTextInLabel(label: kiyakuLabel, inRange: kiyakuRange) {
            performSegue(withIdentifier: "toKiyakuVC", sender: nil)
        } else if sender.didTapAttributedTextInLabel(label: kiyakuLabel, inRange: privacyRange) {
            performSegue(withIdentifier: "toPrivacyVC", sender: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    
    @IBAction func finTutorialTapped(_ sender: Any) {
        print("tapped")
        UIView.animate(withDuration: 0.3, delay: 0.0 , animations: {
            self.scrollView.frame.origin.x -= self.view.bounds.width
        }, completion: nil)
        UserDefaults.standard.setValue(true, forKey: "doneInitialLoad")
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        performSegue(withIdentifier: "toRegister", sender: nil)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        performSegue(withIdentifier: "toLogin", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRegister" {
            let registerVC: RegisterViewController = (segue.destination as? RegisterViewController)!
        } else if(segue.identifier == "toLogin") {
            let loginVC: LoginViewController = (segue.destination as? LoginViewController)!
        }else if(segue.identifier == "toKiyakuVC") {
            let kiyakuVC: KiyakuVC = (segue.destination as? KiyakuVC)!
        } else if(segue.identifier == "toPrivacyVC") {
            let privacyVC: PolicyVC = (segue.destination as? PolicyVC)!
        }
    }
    
    @IBAction func skipLoginTapped(_ sender: Any) {
        skipLoginButton.isEnabled = false
        toLoginButton.isEnabled = false
        toRegisterButton.isEnabled = false
        activityIndicatorView.style = .large
        activityIndicatorView.center = view.center
        activityIndicatorView.color = .black
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        DispatchQueue.global(qos: .default).async {
            Thread.sleep(forTimeInterval: 3)
            DispatchQueue.main.async {
                let rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "Tab")
                UIApplication.shared.keyWindow?.rootViewController = rootViewController
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var pageProgress = Double(scrollView.contentOffset.x / scrollView.bounds.width)
        self.pageControll.currentPage = Int(round(pageProgress))
        if pageControll.currentPage == 3 {
            finishTurotialButton.isHidden = false
        }
        
        print(scrollView.contentOffset.x)
        print(self.view.frame.width * 3)
        if scrollView.contentOffset.x > self.view.frame.width * 3 {
            UIView.animate(withDuration: 0.3, delay: 0.0 , animations: {
                self.scrollView.frame.origin.x -= self.view.bounds.width
            }, completion: nil)
            UserDefaults.standard.setValue(true, forKey: "doneInitialLoad")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
