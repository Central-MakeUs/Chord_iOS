import CoreModels

public enum MenuRoute: Hashable {
  case detail(MenuItem)
  case add
  case edit(MenuItem)
}
