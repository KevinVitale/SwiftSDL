public func SDL_GetBasePath() throws(SDL_Error) -> String {
  guard let basePath = SDL_GetBasePath() else {
    throw .error
  }
  
  return String(cString: basePath)
}


import class Foundation.ProcessInfo

extension Bundle {
  public static func resourceBundles(
    matching filter: (URL) throws -> Bool = {
      // By default, we look filter the bundles that contain the executable name
      $0.lastPathComponent.contains(ProcessInfo.processInfo.processName)
    },
    relativeTo basePath: String? = ((try? SDL_GetBasePath()) ?? Bundle.main.resourcePath)
  ) -> [Bundle] {
    var matches: [String] = []
    guard let result = basePath?.completePath(
      caseSensitive: false,
      matchesInto: &matches
    ) else {
      return []
    }
    
    guard result > 0 else {
      return []
    }
    
    return (try? matches
      .compactMap({ URL(string: "file://\($0)") })
      .filter({
        $0.lastPathComponent.hasSuffix(".bundle") ||
        $0.lastPathComponent.hasSuffix(".resources")
      })
        .filter(filter)
        .compactMap(Bundle.init(url:))
    ) ?? []
  }
}
