package config

const (
	ScreenWidth  = 544
	ScreenHeight = 352
)

// Map
const (
	MapHeight                     = 11
	MapWidth                      = 17
	TilePixels                    = 32
	PercentageOfDestructibleTiles = 0.75 // 75% of the free tiles(95)
	PercentageOfDroppableItem     = 0.17 // 17% of destructible tiles are droppable items
)

const (
	IndestructibleTile = iota // 0
	FreeTile                  // 1
	DestructibleTile          // 2
)

// Items
const (
	EssentialItems      = 0.50 // 50% of droppable items are essential type
	// Only 50% of the essentials items can be repeated
	// (Ex.: If the total of essential items is 6. It can only drop a maximum 3 fire items)
	EssentialItemsLimit = 0.50

	SpecialItems   = 0.25  // 25% of droppable items are special type
	NegativeItems  = 0.25  // 25% of droppable items are negative type
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

// Player
const (
	FrameStartWidth = iota
	FrameEndWidth   = 24
)

const (
	DefaultSpeed = 2.0
)