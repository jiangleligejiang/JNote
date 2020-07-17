// 1.model需要实现Decodable协议，且定义CodingKeys对象
struct Films: Decodable {
  let count: Int
  let all: [Film]
  
  enum CodingKeys: String, CodingKey {
    case count
    case all = "results"
  }
}

struct Film: Decodable {
  let id: Int
  let title: String
  let openingCrawl: String
  let director: String
  let producer: String
  let releaseDate: String
  let starships: [String]
  
  enum CodingKeys: String, CodingKey {
    case id = "episode_id"
    case title
    case openingCrawl = "opening_crawl"
    case director
    case producer
    case releaseDate = "release_date"
    case starships
  }
}

extension MainTableViewController {
  func fetchFilms() {
    // 将需要解析的model将其class传入
    AF.request("https://swapi.dev/api/films").validate().responseDecodable(of: Films.self) { (response) in
      guard let films = response.value else { return }
      self.films = films.all
      self.items = films.all
      self.tableView.reloadData()
    }
  }
  
  func searchStarships(for name: String) {
    let url = "https://swapi.dev/api/starships"
    let parameters: [String: String] = ["search": name]
    AF.request(url, parameters: parameters).validate()
      .responseDecodable(of: Starships.self) { response in
        guard let starships = response.value else { return }
        self.items = starships.all
        self.tableView.reloadData()
    }
  }
}


extension DetailViewController {
  private func fetch<T: Decodable & Displayable>(_ list: [String], of: T.Type) {
    var items: [T] = []
    let fetchGroup = DispatchGroup()
    
    list.forEach { (url) in
      fetchGroup.enter()
      AF.request(url).validate().responseDecodable(of: T.self) { (response) in
        if let value = response.value {
          items.append(value)
        }
        fetchGroup.leave()
      }
    }
    
    fetchGroup.notify(queue: .main) {
      self.listData = items
      self.listTableView.reloadData()
    }
  }
 }
