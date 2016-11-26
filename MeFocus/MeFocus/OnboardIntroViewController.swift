//
//  OnboarIntroViewController.swift
//  MeFocus
//
//  Created by Hao on 11/20/16.
//  Copyright © 2016 Group5. All rights reserved.
//

import UIKit

class OnboardIntroViewController: UIPageViewController {
    
    let identifiers:[String] = [
        "OnboardFirstViewController",
        "OnboardSecondViewController",
        "OnboardThirdViewController"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        setViewControllers(
            [load(index:0)],
            direction: .forward,
            animated: true,
            completion: {
                (finished:Bool) in
            }
        )
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds
                continue
            }
            
            if view is UIPageControl {
                view.backgroundColor = UIColor.clear
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indexOf(controller:UIViewController) -> Int{
        if let identifier = controller.restorationIdentifier{
            return identifiers.index(of: identifier) ?? 0
        }
        return 0
    }
    
    func load(index:Int) -> UIViewController{
        return storyboard!.instantiateViewController(withIdentifier:identifiers[index])
        
    }
   
}

extension OnboardIntroViewController : UIPageViewControllerDataSource {
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
        let current = indexOf(controller: viewController)
        let index = (current == 0) ? identifiers.count - 1 : current - 1
        return load(index:index)
    }
    

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
        let current = indexOf(controller: viewController)
        let index = (current == identifiers.count - 1) ? 0 : current + 1
        return load(index:index)
    }
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return identifiers.count
    }
    
    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }

    
}
