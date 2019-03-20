import UIKit
import CoreData

class DocumentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var documentsTableView: UITableView!
    let dateFormatter = DateFormatter()
    var documents = [Document]()
    
    let searchController = UISearchController(searchResultsController: nil)
    var scope = SearchScope.Both
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        documentsTableView.dataSource = self
        documentsTableView.delegate = self
        title = "Documents"

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        searchController.searchResultsUpdater = self as? UISearchResultsUpdating
        searchController.searchBar.delegate = self as? UISearchBarDelegate

        
      
        
        searchController.searchBar.scopeButtonTitles = SearchScope.titles
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchDocuments()
        documentsTableView.reloadData()
    }
    
    func alertNotifyUser(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel) {
            (alertAction) -> Void in
            print("OK selected")
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func fetchDocuments() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)] 
        
        do {
            documents = try managedContext.fetch(fetchRequest)
        } catch {
            alertNotifyUser(message: "Failed")
            return
        }
    }
    
    func getDocuments(with query: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Document>(entityName: "Document")
        do {
            if query != "" {
                switch scope {
                case .Title:
                    fetchRequest.predicate = NSPredicate(format: "name contains[c] %@", query)
                case.Content:
                    fetchRequest.predicate = NSPredicate(format:"content contains[c] %@", query)
                case .Both:
                    fetchRequest.predicate = NSPredicate(format: "name contains[c] %@ OR content contains[c] %@", query, query)
                }
            }
            documents = try context.fetch(fetchRequest)
            documentsTableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func deleteDocument(at indexPath: IndexPath) {
        let document = documents[indexPath.row]
        
        if let managedObjectContext = document.managedObjectContext {
            managedObjectContext.delete(document)
            
            do {
                try managedObjectContext.save()
                self.documents.remove(at: indexPath.row)
                documentsTableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                alertNotifyUser(message: "Delete failed.")
                documentsTableView.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentCell", for: indexPath)
        
        if let cell = cell as? DocumentTableViewCell {
            let document = documents[indexPath.row]
            cell.nameLabel.text = document.name
            cell.sizeLabel.text = String(document.size) + " bytes"
            
            if let modifiedDate = document.modifiedDate {
                cell.modifiedLabel.text = dateFormatter.string(from: modifiedDate)
            } else {
                cell.modifiedLabel.text = "unknown"
            }
        }
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DocumentViewController,
           let segueIdentifier = segue.identifier, segueIdentifier == "existingDocument",
           let row = documentsTableView.indexPathForSelectedRow?.row {
                destination.document = documents[row]
        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteDocument(at: indexPath)
        }
    }
}
    
    extension DocumentsViewController: UISearchResultsUpdating {
        func updateSearchResults(for searchController: UISearchController) {
            getDocuments(with: searchController.searchBar.text ?? "")
        }
    }
    
    extension DocumentsViewController: UISearchBarDelegate {
        func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
            self.scope = SearchScope.scopes[selectedScope]
            if let searchTerm = searchBar.text {
                getDocuments(with: searchTerm)
            }
        }
    }


    
 


