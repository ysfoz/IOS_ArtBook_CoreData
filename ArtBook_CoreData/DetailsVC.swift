//
//  DetailsVC.swift
//  ArtBook_CoreData
//
//  Created by ysf on 20.10.21.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    
    var selectedItem = ""
    var selectedId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedItem != "" {
            // Core Data
            
            let appDelagate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelagate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            let idString = selectedId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@",idString!)
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(fetchRequest)
                print(results)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                    
                }
            } catch {
                print("error")
            }
            
            
        } else {
            nameText.text = ""
            artistText.text = ""
            yearText.text = ""
            
        }

        //RECOGNIZERS
        
       //1-ekranin bos kisimlarina tiklandiginda klavyeyi kapatma
        
        let gesturerecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gesturerecognizer)
        
        //2-  image secimi icin
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    // 1
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    //2
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
//
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    //2
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func saveButtonClicked(_ sender: Any) {
        // dosyalar icerisinde bulunan appDelegate e ve icerisindeki context fonksiyonuna ulastik
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //Attributes
        
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.4)
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
        } catch  {
            print("error")

        }
        
        // burada bir mesaj yayinliyoruz, bu mesaja uygulamanin her sayfasindan ulasilabilir.
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        // islemlerden sonra otomatik olarak viewController a gitmasi icin
        self.navigationController?.popViewController(animated: true)
        
    }
    

}
