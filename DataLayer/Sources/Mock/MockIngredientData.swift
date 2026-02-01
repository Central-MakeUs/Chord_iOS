import CoreModels
import Foundation

public enum MockIngredientData {
  public static let items: [InventoryIngredientItem] = [
    InventoryIngredientItem(
      apiId: 1,
      name: "에스프레소 원두",
      amount: "5kg",
      price: "45,000원",
      category: "COFFEE",
      supplier: "스타벅스"
    ),
    InventoryIngredientItem(
      apiId: 2,
      name: "우유",
      amount: "10L",
      price: "25,000원",
      category: "DAIRY",
      supplier: "서울우유"
    ),
    InventoryIngredientItem(
      apiId: 3,
      name: "설탕",
      amount: "3kg",
      price: "12,000원",
      category: "ETC",
      supplier: "백설"
    ),
    InventoryIngredientItem(
      apiId: 4,
      name: "바닐라 시럽",
      amount: "2L",
      price: "18,000원",
      category: "SYRUP",
      supplier: "모닌"
    ),
    InventoryIngredientItem(
      apiId: 5,
      name: "카라멜 시럽",
      amount: "2L",
      price: "18,000원",
      category: "SYRUP",
      supplier: "모닌"
    ),
    InventoryIngredientItem(
      apiId: 6,
      name: "헤이즐넛 시럽",
      amount: "2L",
      price: "18,000원",
      category: "SYRUP",
      supplier: "모닌"
    ),
    InventoryIngredientItem(
      apiId: 7,
      name: "휘핑크림",
      amount: "1L",
      price: "8,000원",
      category: "DAIRY",
      supplier: "매일우유"
    ),
    InventoryIngredientItem(
      apiId: 8,
      name: "초콜릿 파우더",
      amount: "500g",
      price: "15,000원",
      category: "POWDER",
      supplier: "기라델리"
    ),
    InventoryIngredientItem(
      apiId: 9,
      name: "녹차 파우더",
      amount: "500g",
      price: "20,000원",
      category: "POWDER",
      supplier: "오설록"
    ),
    InventoryIngredientItem(
      apiId: 10,
      name: "종이컵 (대)",
      amount: "1000개",
      price: "80,000원",
      category: "CUP",
      supplier: "배민상회"
    ),
    InventoryIngredientItem(
      apiId: 11,
      name: "종이컵 (중)",
      amount: "1000개",
      price: "60,000원",
      category: "CUP",
      supplier: "배민상회"
    ),
    InventoryIngredientItem(
      apiId: 12,
      name: "플라스틱 컵",
      amount: "500개",
      price: "45,000원",
      category: "CUP",
      supplier: "배민상회"
    ),
    InventoryIngredientItem(
      apiId: 13,
      name: "빨대",
      amount: "2000개",
      price: "15,000원",
      category: "ETC",
      supplier: "다이소"
    ),
    InventoryIngredientItem(
      apiId: 14,
      name: "테이크아웃 홀더",
      amount: "500개",
      price: "25,000원",
      category: "ETC",
      supplier: "배민상회"
    ),
    InventoryIngredientItem(
      apiId: 15,
      name: "냅킨",
      amount: "5000장",
      price: "30,000원",
      category: "ETC",
      supplier: "코스트코"
    )
  ]
}
