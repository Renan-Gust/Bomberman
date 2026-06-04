package gmap

import (
	"math/rand/v2"
)

type test struct{ percentage, limit float32 }

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

func generateDroppableItems(m *Map, droppableItems []Point){
	droppableItemsTotal := len(droppableItems)

	essentialItemsTotal := int(float32(droppableItemsTotal) * essentialItems) // total of 6 tiles
	repetitionLimit := int(float32(essentialItemsTotal) * essentialItemsLimit)
	essentialItems := droppableItems[:essentialItemsTotal]

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