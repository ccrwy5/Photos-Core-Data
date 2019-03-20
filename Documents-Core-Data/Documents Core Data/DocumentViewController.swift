
import UIKit
import Foundation

class DocumentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var mealImageView: UIImageView!
    
    var document: Document?
    
    var imagePickerController = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        imagePickerController.delegate = self
        title = ""

        if let document = document {
            let name = document.name
            nameTextField.text = name
            contentTextView.text = document.content
            title = name
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func alertNotifyUser(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func save(_ sender: Any) {
        guard let name = nameTextField.text else {
            alertNotifyUser(message: "Document not saved.\nThe name is not accessible.")
            return
        }
        
        let documentName = name.trimmingCharacters(in: .whitespaces)
        if (documentName == "") {
            alertNotifyUser(message: "Document not saved.\nA name is required.")
            return
        }
        
        let content = contentTextView.text
        
        if document == nil {
            document = Document(name: documentName, content: content)
        } else {
            document?.update(name: documentName, content: content)
        }
        
        if let document = document {
            do {
                let managedContext = document.managedObjectContext
                try managedContext?.save()
            } catch {
                alertNotifyUser(message: "Failed")
            }
        } else {
            alertNotifyUser(message: "Failed")
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nameChanged(_ sender: Any) {
        title = nameTextField.text
    }
    
    @IBAction func takePicButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Camera Error", message: "Xcode doesn't have a camera to use, must use actual iPhone :(", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .destructive, handler: nil))
            
            self.present(alert, animated: true)
        }
        
    }
    
    @IBAction func organizeButton(_ sender: Any) {
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imagefromLibrary = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            mealImageView.image = imagefromLibrary
        }
        dismiss(animated: true, completion: nil)
    }
    
}

    
    

