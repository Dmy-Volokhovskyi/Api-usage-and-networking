//
//  PopVC.swift
//  Api usage and networking
//
//  Created by Дмитро Волоховський on 24/01/2022.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    var passedImage : UIImage!
    
    func initData (forImage image : UIImage) {
        self.passedImage = image
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
        addDoubleTap()
        // Do any additional setup after loading the view.
    }
    
    
    func addDoubleTap () {
       let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubletapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    @objc func screenWasDoubletapped () {
        dismiss(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
