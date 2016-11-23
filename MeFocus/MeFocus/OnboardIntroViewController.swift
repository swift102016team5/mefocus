//
//  OnboarIntroViewController.swift
//  MeFocus
//
//  Created by Hao on 11/20/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit

class OnboardIntroViewController: UIViewController {

    var pageVC: UIPageViewController!
    lazy var arrVc: [UIViewController] = {
        return [self.vcInstance(name:"FirstVc"), self.vcInstance(name:"SecondVc"), self.vcInstance(name:"ThirdVc")]
    }()
    
    private func vcInstance(name: String) -> UIViewController {
        return UIStoryboard(name: "Onboard", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        App.shared.viewedOnboard()
        self.pageVC = UIStoryboard(name: "Onboard", bundle: nil).instantiateViewController(withIdentifier: "pageVC") as! UIPageViewController
        self.pageVC.dataSource = self
        if let firstVc = arrVc.first {
            self.pageVC.setViewControllers([firstVc], direction: .forward, animated: true, completion: nil)
        }
        self.pageVC.view.frame.origin = self.view.frame.origin
        self.pageVC.view.frame.size = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height * 0.7)
        self.addChildViewController(self.pageVC)
        self.view.addSubview(self.pageVC.view)
        self.didMove(toParentViewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSignup(_ sender: Any) {
        
        App.shared.present(
            presenter:self,
            storyboard:"User",
            controller:"UserLoginViewController",
            modifier:nil,
            completion:nil
        )
        
    }
    
    @IBAction func onSkip(_ sender: Any) {
        App.shared.present(
            presenter:self,
            storyboard:"Session",
            controller:"SessionStartViewController",
            modifier:nil,
            completion:nil
        )
    }
    
   
}

extension OnboardIntroViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = arrVc.index(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < arrVc.count else {
            return nil
        }

        return arrVc[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = arrVc.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        return arrVc[previousIndex]
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstVc = pageVC.viewControllers?.first, let firstVcIndex = arrVc.index(of: firstVc) else {
            return 0
        }
        return firstVcIndex
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return arrVc.count
    }
}
