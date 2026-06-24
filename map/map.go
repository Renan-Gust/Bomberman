package gmap

import (
	"bomberman/config"
	"image/color"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/vector"
)

type Map struct{
	Grid [config.MapHeight][config.MapWidth]int // total of 187 tiles
}

type Point struct{ X, Y int }

func(m *Map) Generate(){
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
                m.Grid[x][y] = config.IndestructibleTile // (Red)
            } else if spawnAreas {
				m.Grid[x][y] = config.FreeTile // (Green)
			} else {
				m.Grid[x][y] = config.FreeTile 
				freeTiles = append(freeTiles, Point{X: x, Y: y}) // total of 95 tiles
            }
		}
	}

	freeTilesTotal := len(freeTiles)
	destructibleTilesTotal := int(float32(freeTilesTotal) * config.PercentageOfDestructibleTiles) // total of 71 tiles

	shuffle(freeTiles)
	
	destructibleTiles := freeTiles[:destructibleTilesTotal]

	for _, pos := range destructibleTiles{
		m.Grid[pos.X][pos.Y] = config.DestructibleTile // (Blue)
	}

	droppableItemsTotal := int(float32(destructibleTilesTotal) * config.PercentageOfDroppableItem) // total of 12 tiles
	droppableItems := destructibleTiles[:droppableItemsTotal]

	generateDroppableItems(m, droppableItems)
}

func (m *Map) Draw(screen *ebiten.Image){
	red := color.RGBA{255, 0, 0, 255}
	green := color.RGBA{34, 139, 34, 255}
	blue := color.RGBA{0, 0, 255, 255}

	for x := range m.Grid {
		for y := range m.Grid[x] {
			posX := float32(y * config.TilePixels)
			posY := float32(x * config.TilePixels)

			tile := m.Grid[x][y]
			tileColor := green

			if tile == config.IndestructibleTile {
				tileColor = red
			} else if tile == config.DestructibleTile {
				tileColor = blue
			} else {
				tileColor = itemColor(tile)
			}

			vector.FillRect(screen, posX, posY, config.TilePixels, config.TilePixels, tileColor, true)
		}
	}
}

func itemColor(tile int) color.RGBA{
	switch tile {
	// Essential items
	case config.SpeedItem:
		return color.RGBA{255, 255, 0, 255} // Amarelo
	case config.FireItem:
		return color.RGBA{255, 255, 0, 255} //color.RGBA{255, 0, 255, 255} // Magenta
	case config.BombItem:
		return color.RGBA{255, 255, 0, 255} //color.RGBA{128, 0, 128, 255} // Roxo
	
	// Special items 
	case config.HeartItem:
		return color.RGBA{255, 255, 255, 255} //color.RGBA{101, 67, 33, 255} // Marrom
	case config.ShieldItem:
		return color.RGBA{255, 255, 255, 255} //color.RGBA{211, 211, 211, 255} // Cinza
	case config.BombPassItem:
		return color.RGBA{255, 255, 255, 255} // Branco

	// Negative items 
	case config.SlownessItem:
		return color.RGBA{0, 0, 0, 255} // Preto
	case config.HyperSpeedItem:
		return color.RGBA{0, 0, 0, 255} // Preto
	case config.ShortFuseItem:
		return color.RGBA{0, 0, 0, 255} // Preto		
	case config.ReverseControlItem:
		return color.RGBA{0, 0, 0, 255} // Preto
	default:
		return color.RGBA{34, 139, 34, 255} // Green (Free Tile)
	}
}