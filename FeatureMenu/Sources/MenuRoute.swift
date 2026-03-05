import CoreModels

public enum MenuRoute: Hashable {
  case detail(MenuItem)
  case add(MenuCategory)
  case edit(MenuItem)
  case ingredients(menuId: Int, menuName: String, ingredients: [IngredientItem])
}
