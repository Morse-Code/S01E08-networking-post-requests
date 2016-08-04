import UIKit


typealias JSONDictionary = [String: AnyObject]


enum HttpMethod<Body> {
    case get
    case post(Body)
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
    let method: HttpMethod<Data>
    let parse: (Data) -> A?
}

extension Resource {
    init(url: URL, method: HttpMethod<AnyObject> = .get, parseJSON: (AnyObject) -> A?) {
        self.url = url
        switch method {
        case .get:
            self.method = .get
        case .post(let json):
            let bodyData = try! JSONSerialization.data(withJSONObject: json, options: [])
            self.method = .post(bodyData)
        }
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
            return json.flatMap(parseJSON)
        }
    }
}


func pushNotification(_ token: String) -> Resource<Bool> {
    let url = URL(string: "")!
    let dictionary = ["token": token]
    return Resource(url: url, method: .post(dictionary), parseJSON: { _ in
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
