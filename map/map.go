package gmap

import (
	"image/color"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/vector"
)

const (
	MapHeight                     = 11
	MapWidth                      = 17
	PercentageOfDestructibleTiles = 0.75 // 75% from free floors(95)
	TilePixels                    = 32
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
    // var destructibleWallPositions []Point
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
                // if rand.Float32() < DestructibleRatio {
				// 	m.Grid[x][y] = DestructibleWall // (Blue)

				// 	destructibleWallPositions = append(destructibleWallPositions, Point{X: x, Y: y})
				// } else {
				// 	m.Grid[x][y] = FreeFloor // The remaining 25% stays as free floor (Green)
				// }

				m.Grid[x][y] = FreeTile 
				freeTiles = append(freeTiles, Point{X: x, Y: y}) // total of 95 tiles
            }
		}
	}

	freeFloorsTotal := len(freeTiles)
	destructibleTilesTotal := int(float32(freeFloorsTotal) * PercentageOfDestructibleTiles)

	shuffle(freeTiles)
	
	destructibleTiles := freeTiles[:destructibleTilesTotal]

	for _, pos := range destructibleTiles{
		m.Grid[pos.X][pos.Y] = DestructibleTile // (Blue)
	}
	
	// fmt.Println(destructibleWalls)
	// fmt.Println("\n")
	// fmt.Println(shuffle(freeFloors))

	// destructibleWallPositionsLength := len(destructibleWallPositions) - 1
	// fmt.Println(destructibleWallPositionsLength)
	// for i := 0; i <= 12; i++ {
	// 	random := rand.Int32N(destructibleWallPositionsLength)
	// }

	return m
}

func (m *Map) DrawMap(screen *ebiten.Image) *Map{
	red := color.RGBA{255, 0, 0, 255}
	green := color.RGBA{34, 139, 34, 255}
	blue := color.RGBA{0, 0, 255, 255}
	yellow := color.RGBA{255, 255, 0, 255}

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
			} else if tile == 3 {
				tileColor = yellow
			}

			vector.FillRect(screen, posX, posY, TilePixels, TilePixels, tileColor, true)
		}
	}

	return m
}