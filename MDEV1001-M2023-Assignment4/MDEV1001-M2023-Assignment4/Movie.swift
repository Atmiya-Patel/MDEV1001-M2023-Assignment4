import Foundation

struct Movie: Codable {
    var documentID: String?
    var title: String
    var studio: String
    var criticsRating: Double
    var thumbnail: String
}
