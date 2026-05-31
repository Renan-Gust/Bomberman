package gmap

import (
	"image/color"
	"math/rand/v2"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/vector"
)

const (
	MapHeight         = 11
	MapWidth          = 17
	DestructibleRatio = 0.75
	TilePixels        = 32
)

const (
	IndestructibleWall = iota // 0
	FreeFloor                 // 1
	DestructibleWall          // 2
)

type Map struct{
	Grid [MapHeight][MapWidth]int
}

func(m *Map) GenerateMap() *Map{
	for x := range m.Grid {
		for y := range m.Grid[x] {
			borders := x == 0 || x == 10 || y == 0 || y == 16
			indestructibleTiles := x % 2 == 0  && y % 2 == 0

			topRows := x == 1 && (y == 1 || y == 2 || y == 14 || y == 15)
			bottomRows := x == 9 && (y == 1 || y == 2 || y == 14 || y == 15)
			verticalExtensions := (x == 2 || x == 8) && (y == 1 || y == 15)

			spawnAreas := topRows || bottomRows || verticalExtensions

			if borders || indestructibleTiles {
                m.Grid[x][y] = IndestructibleWall // (Red)
            } else if spawnAreas {
				m.Grid[x][y] = FreeFloor // (Green)
			} else {
                if rand.Float32() < DestructibleRatio {
					m.Grid[x][y] = DestructibleWall // (Blue)
				} else {
					m.Grid[x][y] = FreeFloor // The remaining 25% stays as free floor (Green)
				}
            }
		}
	}

	return m
}

func (m *Map) DrawMap(screen *ebiten.Image) * Map{
	red := color.RGBA{255, 0, 0, 255}
	green := color.RGBA{34, 139, 34, 255}
	blue := color.RGBA{0, 0, 255, 255}

	for x := range m.Grid {
		for y := range m.Grid[x] {
			posX := float32(y * TilePixels)
			posY := float32(x * TilePixels)

			tile := m.Grid[x][y]
			tileColor := green

			if tile == IndestructibleWall {
				tileColor = red
			} else if tile == DestructibleWall {
				tileColor = blue
			}

			vector.FillRect(screen, posX, posY, TilePixels, TilePixels, tileColor, true)
		}
	}

	return m
}