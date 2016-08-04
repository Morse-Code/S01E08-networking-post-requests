import UIKit


typealias JSONDictionary = [String: AnyObject]


enum HttpMethod {
    case get
    case post(Data)
}

extension HttpMethod {
    var method: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        }
    }
}


struct Resource<A> {
    let url: URL
    let method: HttpMethod
    let parse: (Data) -> A?
}

extension Resource {
    init(url: URL, method: HttpMethod = .get, parseJSON: (AnyObject) -> A?) {
        self.url = url
        self.method = method
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
            return json.flatMap(parseJSON)
        }
    }
}


func pushNotification(_ token: String) -> Resource<Bool> {
    let url = URL(string: "")!
    let dictionary = ["token": token]
    let bodyData = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
    return Resource(url: url, method: .post(bodyData), parse: { _ in
        return true
    })
}


final class Webservice {
    func load<A>(_ resource: Resource<A>, completion: (A?) -> ()) {
        URLSession.shared.dataTask(with: resource.url) { data, _, _ in
            completion(data.flatMap(resource.parse))
            }.resume()
    }
}
