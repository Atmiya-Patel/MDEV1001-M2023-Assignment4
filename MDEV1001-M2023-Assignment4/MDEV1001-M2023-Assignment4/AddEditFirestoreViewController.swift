import UIKit
import Firebase

class AddEditFirestoreViewController: UIViewController {

    // UI References
    @IBOutlet weak var AddEditTitleLabel: UILabel!
    @IBOutlet weak var UpdateButton: UIButton!
    
    // Movie Fields
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var studioTextField: UITextField!
    @IBOutlet weak var criticsRatingTextField: UITextField!
    
    @IBOutlet weak var posterImageLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    
    @IBOutlet weak var imageUrlTextField: UITextField!
    
    var movie: Movie?
    var movieViewController: FirestoreCRUDViewController?
    var movieUpdateCallback: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let movie = movie {
            // Editing existing movie
            titleTextField.text = movie.title
            studioTextField.text = movie.studio
            criticsRatingTextField.text = "\(movie.criticsRating)"
            let url = URL(string: movie.thumbnail)!
            DispatchQueue.global().async {
              // Fetch Image Data
            if let data = try? Data(contentsOf: url) {
              DispatchQueue.main.async {
              // Create Image and Update Image View
             self.thumbnailImage.image = UIImage(data: data)
                 }
                }
              }

            imageUrlTextField.text = movie.thumbnail
            AddEditTitleLabel.text = "Edit Movie"
            UpdateButton.setTitle("Update", for: .normal)
            self.posterImageLabel.isHidden = false
            self.thumbnailImage.isHidden = false
        } else {
            AddEditTitleLabel.text = "Add Movie"
            UpdateButton.setTitle("Add", for: .normal)
            self.posterImageLabel.isHidden = true
            self.thumbnailImage.isHidden = true
        }
    }
    
    @IBAction func CancelButton_Pressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func UpdateButton_Pressed(_ sender: UIButton) {
        guard
              let title = titleTextField.text,
              let studio = studioTextField.text,

                let thumbnail = imageUrlTextField.text,
               
              let criticsRatingString = criticsRatingTextField.text,
              let criticsRating = Double(criticsRatingString) else {
            print("Invalid data")
            return
        }

        let db = Firestore.firestore()

        if let movie = movie {
            // Update existing movie
            guard let documentID = movie.documentID else {
                print("Document ID not available.")
                return
            }

            let movieRef = db.collection("movies").document(documentID)
            movieRef.updateData([
             //   "movieID": movieID,
                "title": title,
                "studio": studio,
                "thumbnail":thumbnail,
                "criticsRating": criticsRating
            ]) { [weak self] error in
                if let error = error {
                    print("Error updating movie: \(error)")
                } else {
                    print("Movie updated successfully.")
                    self?.dismiss(animated: true) {
                        self?.movieUpdateCallback?()
                    }
                }
            }
        } else {
            // Add new movie
            let newMovie     = [
                "title": title,
                "studio": studio,
                "thumbnail":thumbnail,
                "criticsRating": Double(criticsRating)
            ] as [String : Any]

            var ref: DocumentReference? = nil
            ref = db.collection("movies").addDocument(data: newMovie) { [weak self] error in
                if let error = error {
                    print("Error adding movie: \(error)")
                } else {
                    if self?.imageUrlTextField.text != ""
                    {
                        let url = URL(string: self!.imageUrlTextField.text!)!
                        // Fetch Image Data
                          DispatchQueue.global().async {
                           // Fetch Image Data
                         if let data = try? Data(contentsOf: url) {
                         DispatchQueue.main.async {
                        // Create Image and Update Image View
                          self?.thumbnailImage.image = UIImage(data: data)
                                                  }
                                              }
                                          }
                    }
                   
                    print("Movie added successfully.")
                    self?.dismiss(animated: true) {
                        self?.movieUpdateCallback?()
                    }
                }
            }
        }
    }
}
