//
//  PageViewController.swift
//  YummyFoodTrackIn
//
//  Created by webwerks on 3/21/17.
//  Copyright © 2017 webwerks. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {

    weak var tutorialDelegate: OrderPageViewControllerDelegate?
    var selectedIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.white
        
        navigationController?.navigationBar.barTintColor = UIColor.customRed
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(addTapped))
        self.title = "Order Details"
        dataSource = self
        delegate = self
        tutorialDelegate?.tutorialPageViewController(tutorialPageViewController : self,
                                                     didUpdatePageCount: orderedViewControllers.count)
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: false,
                               completion: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
       // self.scrollToViewController(index: 0)
    }
    
    func addTapped(sender: UIBarButtonItem) {
        
        self .dismiss(animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        
        let mapVC = self.newViewController(identifier: "MapViewController") as! MapViewController
        
        let customerInfoVC = self.newViewController(identifier: "CustomerInfoController") as! CustomerInfoController
        
        mapVC.customerInfoPageDelegate = customerInfoVC
        
        return [customerInfoVC,
                mapVC,
                self.newViewController(identifier: "OrderMenuDetailController")]
    }()
    
    private func newViewController(identifier: String) -> UIViewController {
        
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "\(identifier)")
    }
    
    func scrollToViewController(index newIndex: Int) {
       
        /*
        if (viewControllers?.first) != nil {
            var currentIndexlet : Int = 0
            var direction : UIPageViewControllerNavigationDirection = .reverse
            if newIndex == 0 {
                 currentIndexlet = 1
                 direction  = .forward

            }else if newIndex == 1 {
                direction = .forward
                currentIndexlet = 1
            }else {
                currentIndexlet = 2
                direction = .forward

            }
            
            let nextViewController = orderedViewControllers[currentIndexlet]
            scrollToViewController(viewController: nextViewController, direction:direction)
        }
 */
        
        
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers.index(of: firstViewController) {
            let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers[newIndex]
            scrollToViewController(viewController: nextViewController, direction: direction)
        }
    }
    
    private func scrollToViewController(viewController: UIViewController,
                                        direction: UIPageViewControllerNavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: { (finished) -> Void in
                            // Setting the view controller programmatically does not fire
                            // any delegate methods, so we have to manually notify the
                            // 'tutorialDelegate' of the new index.
                            self.notifyTutorialDelegateOfNewIndex()
        })
    }
    
     func notifyTutorialDelegateOfNewIndex() {
       
        /*
        if let firstViewController = viewControllers?.first {
            var indexPage = 0
            if firstViewController.isKind(of: OrderMenuDetailController.self) {
                indexPage = 2
            }else if firstViewController.isKind(of: MapViewController.self) {
                indexPage = 1
            }else{
                indexPage = 0
            }
            tutorialDelegate?.tutorialPageViewController(tutorialPageViewController : self,
                                                         didUpdatePageIndex: indexPage)
        }
        */
        
        if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.index(of: firstViewController) {
            tutorialDelegate?.tutorialPageViewController(tutorialPageViewController :self,
                                                         didUpdatePageIndex: index)
        }
    }
}

// MARK: UIPageViewControllerDataSource

extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        selectedIndex = previousIndex
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        selectedIndex = nextIndex

        return orderedViewControllers[nextIndex]
    }
    
}

extension PageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        notifyTutorialDelegateOfNewIndex()

    }
}


protocol OrderPageViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func tutorialPageViewController(tutorialPageViewController: PageViewController,
                                    didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func tutorialPageViewController(tutorialPageViewController: PageViewController,
                                    didUpdatePageIndex index: Int)
    
}

