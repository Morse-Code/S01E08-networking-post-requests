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

    func map<B>(_ f: (Body) -> B) -> HttpMethod<B> {
        switch self {
        case .get: return .get
        case .post(let body):
            return .post(f(body))
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
        self.method = method.map { json in
            print(json)
            return try! JSONSerialization.data(withJSONObject: json, options: [])
        }
        if case let .post(d) = self.method {
            print(d)
        }
        self.parse = { data in
            let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
            return json.flatMap(parseJSON)
        }
    }
}


func pushNotification(_ token: String) -> Resource<Bool> {
    let url = URL(string: "https://www.google.com")!
    let dictionary = ["token": token]
    return Resource(url: url, method: .post(dictionary), parseJSON: { _ in
        return true
    })
}


extension NSMutableURLRequest {
    convenience init<A>(resource: Resource<A>) {
        self.init(url: resource.url)
        httpMethod = resource.method.method
        if case let .post(data) = resource.method {
            httpBody = data
        }
    }
}


final class Webservice {
    func load<A>(_ resource: Resource<A>, completion: (A?) -> ()) {
        let request = NSMutableURLRequest(resource: resource)
        URLSession.shared.dataTask(with: request as URLRequest) { data, _, _ in
            completion(data.flatMap(resource.parse))
        }.resume()
    }
}

pushNotification("")

