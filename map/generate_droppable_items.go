package gmap

import (
	"fmt"
	"math/rand/v2"
)

const (
	essentialItems      = 0.50 // 50% of droppable items are essential type
	// Only 50% of the essentials items can be repeated
	// (Ex.: If the total of essential items is 6. It can only drop a maximum 3 fire items)
	essentialItemsLimit = 0.50

	specialItems   = 0.25  // 25% of droppable items are special type
	negativeItems  = 0.25  // 25% of droppable items are negative type
)

const (
	// Essential item (family 30-39)
	SpeedItem = 30
	FireItem  = 31
	BombItem  = 32

	// Special item (family 40-49)
	HeartItem     = 40
	ShieldItem    = 41
	BombPassItem  = 42

	// Negative item (family 50-59)
	SlownessItem       = 50
	HyperSpeedItem     = 51
	ShortFuseItem      = 52
	ReverseControlItem = 53
)

var essentialItemsList = []int{SpeedItem, FireItem, BombItem}
var specialItemsList = []int{HeartItem, ShieldItem, BombPassItem}
var negativeItemsList = []int{SlownessItem, HyperSpeedItem, ShortFuseItem, ReverseControlItem}

var remainingDroppableItems []Point

func generateDroppableItems(m *Map, droppableItems []Point){
	generateEssentialItems(m, droppableItems)
	generateSpecialItems(m, droppableItems)
}

func generateEssentialItems(m *Map, droppableItems []Point){
	droppableItemsTotal := len(droppableItems)

	essentialItemsTotal := int(float32(droppableItemsTotal) * essentialItems) // total of 6 tiles
	repetitionLimit := int(float32(essentialItemsTotal) * essentialItemsLimit)

	essentialItems := droppableItems[:essentialItemsTotal]
	remainingDroppableItems = droppableItems[essentialItemsTotal:]

	countRepeatedItems := make(map[int]int)

	for _, pos := range essentialItems{
		for {
			index := rand.IntN(len(essentialItemsList))
			item := essentialItemsList[index]

			if countRepeatedItems[item] >= repetitionLimit {
				continue
			}

			countRepeatedItems[item]++
			m.Grid[pos.X][pos.Y] = item

			break
		}	
	}
}

func generateSpecialItems(m *Map, droppableItems []Point){
	droppableItemsTotal := len(droppableItems)

	specialItemsTotal := int(float32(droppableItemsTotal) * specialItems) // total of 3 tiles
	// repetitionLimit := int(float32(essentialItemsTotal) * essentialItemsLimit)

	specialItems := remainingDroppableItems[:specialItemsTotal]
	remainingDroppableItems = remainingDroppableItems[specialItemsTotal:]

	countRepeatedItems := make(map[int]int)
	var test []int

	for _, pos := range specialItems{
		for {
			random := rand.IntN(100)

			if random > 0 && random <= 20 {
				if countRepeatedItems[BombPassItem] >= 1 {
					continue
				}

				countRepeatedItems[BombPassItem]++
				m.Grid[pos.X][pos.Y] = BombPassItem
				test = append(test, BombPassItem)

				break
			} else {
				index := rand.IntN(len(specialItemsList) - 1) // All special items less the bomb pass
				item := specialItemsList[index]

				fmt.Println(item)

				if countRepeatedItems[item] >= 2 {
					continue
				}

				countRepeatedItems[item]++
				m.Grid[pos.X][pos.Y] = item
				test = append(test, item)

				break
			}
		}
	}

	fmt.Println(test)
}