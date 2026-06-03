package gmap

import (
	"math/rand/v2"
)

const (
	essentialItems = 0.5  // 50% of droppable items are essential type
	specialItems   = 0.25 // 25% of droppable items are special type
	negativeItems  = 0.25 // 25% of droppable items are negative type
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
	essentialItems := droppableItems[:essentialItemsTotal]

	for _, pos := range essentialItems{
		index := rand.IntN(len(essentialItemsList))
		item := essentialItemsList[index]

		m.Grid[pos.X][pos.Y] = item
	}
}