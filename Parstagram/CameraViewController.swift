//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Kristy Lau on 3/12/21.
//

import UIKit
import AlamofireImage
import Parse

// UIImagePickerControllerDelegate allows for camera events
class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var commentField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onSubmitButton(_ sender: Any) {
        
        // Create PF Object
        let post = PFObject(className: "Posts")
        // Similar to a dictionary, can enter values and keys
        
        post["caption"] = commentField.text!
        // Whoever is the logged in author
        post["author"] = PFUser.current()!
        
        // Grab image data
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(data: imageData!) //add exclamation point to unwrap it
        
        post["image"] = file
        
        
        // On save, dismiss the photo view
        post.saveInBackground { (success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
                print("saved!")
            } else {
                print("error!")
            }
            
        }
        
    }
    
    // When user taps the image
    @IBAction func onCameraButton(_ sender: Any) {
        
        // Launch camera
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        // Check if camera is available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    // After picker is finished
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // comes inside dictioanry called info
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af.imageScaled(to: size)
        
        imageView.image = scaledImage
        
        
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
