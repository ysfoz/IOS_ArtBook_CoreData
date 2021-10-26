//
//  ViewController.swift
//  ArtBook_CoreData
//
//  Created by ysf on 20.10.21.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // ust bar menusune simge veya buto koyma
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        
        getData()
    }
    
    //detail sayfasinda yayinladigimiz mesaji burada yakalayip sayfanin render edilmesini saglayacagiz
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newData"), object: nil)
    }
    
    // veri cekme
    
    @objc func getData() {
        
        // listeleri her dafasinda bosaltip o sekilde kalan islemleri yapaiyoruz. Boylece wiewWillAppearda ve viewDidLoad icerisinde getData nin iki defa cagrilmasindan dolayi olusan verilerin ekrana iki defa basilmasi sorunu ortadan kalkiyor
        
        nameArray.removeAll()
        idArray.removeAll()
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            
            for result in results as! [NSManagedObject] {
                if let name = result.value(forKey: "name") as? String {
                    self.nameArray.append(name)
                }
                self.tableView.reloadData()
            }
        } catch {
            print("error")
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    @objc func addButtonClicked(){
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }


}

