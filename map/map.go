package gmap

import (
	"image/color"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/vector"
)

const (
	MapHeight                     = 11
	MapWidth                      = 17
	TilePixels                    = 32
	percentageOfDestructibleTiles = 0.75 // 75% of the free tiles(95)
	percentageOfDroppableItem     = 0.17 // 17% of destructible tiles are droppable items
)

const (
	IndestructibleTile = iota // 0
	FreeTile                  // 1
	DestructibleTile          // 2
)

type Map struct{
	Grid [MapHeight][MapWidth]int // total of 187 tiles
}

type Point struct{ X, Y int }

func(m *Map) GenerateMap() *Map{
	var freeTiles []Point

	for x := range m.Grid {
		for y := range m.Grid[x] {
			borders := x == 0 || x == 10 || y == 0 || y == 16 // total of 52 tiles
			indestructibleTiles := x % 2 == 0 && y % 2 == 0 // total of 28 tiles

			topRows := x == 1 && (y == 1 || y == 2 || y == 14 || y == 15)
			bottomRows := x == 9 && (y == 1 || y == 2 || y == 14 || y == 15)
			verticalExtensions := (x == 2 || x == 8) && (y == 1 || y == 15)

			spawnAreas := topRows || bottomRows || verticalExtensions // total of 12 tiles

			if borders || indestructibleTiles {
                m.Grid[x][y] = IndestructibleTile // (Red)
            } else if spawnAreas {
				m.Grid[x][y] = FreeTile // (Green)
			} else {
				m.Grid[x][y] = FreeTile 
				freeTiles = append(freeTiles, Point{X: x, Y: y}) // total of 95 tiles
            }
		}
	}

	freeTilesTotal := len(freeTiles)
	destructibleTilesTotal := int(float32(freeTilesTotal) * percentageOfDestructibleTiles) // total of 71 tiles

	shuffle(freeTiles)
	
	destructibleTiles := freeTiles[:destructibleTilesTotal]

	for _, pos := range destructibleTiles{
		m.Grid[pos.X][pos.Y] = DestructibleTile // (Blue)
	}

	droppableItemsTotal := int(float32(destructibleTilesTotal) * percentageOfDroppableItem) // total of 12 tiles
	droppableItems := destructibleTiles[:droppableItemsTotal]

	generateDroppableItems(m, droppableItems)

	return m
}

func (m *Map) DrawMap(screen *ebiten.Image) *Map{
	red := color.RGBA{255, 0, 0, 255}
	green := color.RGBA{34, 139, 34, 255}
	blue := color.RGBA{0, 0, 255, 255}

	for x := range m.Grid {
		for y := range m.Grid[x] {
			posX := float32(y * TilePixels)
			posY := float32(x * TilePixels)

			tile := m.Grid[x][y]
			tileColor := green

			if tile == IndestructibleTile {
				tileColor = red
			} else if tile == DestructibleTile {
				tileColor = blue
			} else {
				tileColor = itemColor(tile)
			}

			vector.FillRect(screen, posX, posY, TilePixels, TilePixels, tileColor, true)
		}
	}

	return m
}

func itemColor(tile int) color.RGBA{
	switch tile {
	// Essential items
	case SpeedItem:
		return color.RGBA{255, 255, 0, 255} // Amarelo
	case FireItem:
		return color.RGBA{255, 255, 0, 255} //color.RGBA{255, 0, 255, 255} // Magenta
	case BombItem:
		return color.RGBA{255, 255, 0, 255} //color.RGBA{128, 0, 128, 255} // Roxo
	
	// Special items 
	case HeartItem:
		return color.RGBA{255, 255, 255, 255} //color.RGBA{101, 67, 33, 255} // Marrom
	case ShieldItem:
		return color.RGBA{255, 255, 255, 255} //color.RGBA{211, 211, 211, 255} // Cinza
	case BombPassItem:
		return color.RGBA{255, 255, 255, 255} // Branco

	// Negative items 
	case SlownessItem:
		return color.RGBA{0, 0, 0, 255} // Preto
	case HyperSpeedItem:
		return color.RGBA{0, 0, 0, 255} // Preto
	case ShortFuseItem:
		return color.RGBA{0, 0, 0, 255} // Preto		
	case ReverseControlItem:
		return color.RGBA{0, 0, 0, 255} // Preto
	default:
		return color.RGBA{34, 139, 34, 255} // Green (Free Tile)
	}
}