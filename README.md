# Networking

## Работа с пакетом
### Установка
Добавьте зависимость в своем проекте на этот пакет
```
dependencies: [
    .package(url: "https://github.com/amattit/Networking", from: "1.0.0")
],
```
### Использование
Опишите API, например в формате enum
```
enum API {
    enum User {
        case byId(UUID)
    }
}
```
Подпишите API под протокол APICall
```
extension API.User: APICall {
    
    private var encoder: JSONEncoder { JSONEncoder() }
    
    var path: String {
        switch self {
        case .byId(let id):
            return "/v1/users/\(id)"
        }
    }
    
    var method: String {
        switch self {
        
        case .byId:
            return "GET"
        }
    }
    
    var headers: [String : String]? {
        return [
            "Content-Type":"application/json",
            "rqUid":UUID().description,
        ]
    }
    
    var query: [String : String]? {
        return nil
    }
    
    func body() throws -> Data? {
        return nil
    }
}
```
Для совершения вызова создайте в своем проекте репозиторий, например UserRepository и добавьте нужные функции и подпишите его под протокол WebRepository
```
import Networking

struct UserRepository: WebRepository {
    var session: URLSession = .shared
    var baseURL = "https://somehost.ru"
    var queue: DispatchQueue = DispatchQueue(label: "web_repository_queue")
    
    func fetchUserBy(id: UUID) -> AnyPublisher<API.User.UUserResponse, Error> {
        call(endpoint: API.User.byId(id))
    }
}
```
Реализуйте обработку паблишера

```
public func fetchUserBy(_ id: UUID) {
    userRepository.fetchUserBy(id: id)
        .map { $0 }
        .sink(receiveCompletion: check(_:)) { (response) in
            self.user = User(with: response.user)
        }
        .store(in: &store)
}
```
