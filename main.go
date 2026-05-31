package main

import (
	"image/color"
	"log"
	"math/rand/v2"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
	"github.com/hajimehoshi/ebiten/v2/vector"
)

const (
	screenWidth int = 544
	screenHeight int = 352
)

type Game struct{
	defaultMap [11][17]int
}

func (g *Game) Update() error {
	return nil
}

func (g *Game) Draw(screen *ebiten.Image) {
	for i := range g.defaultMap {
		for j := range g.defaultMap[i] {
			posX := float32(j * 32)
			posY := float32(i * 32)

			tile := g.defaultMap[i][j]

			red := color.RGBA{255, 0, 0, 255}
			green := color.RGBA{34, 139, 34, 255}
			blue := color.RGBA{0, 0, 255, 255}

			tileColor := green

			if tile == 0 {
				tileColor = red
			} else if tile == 2 {
				tileColor = blue
			}

			vector.FillRect(screen, posX, posY, 32, 32, tileColor, true)
		}
	}

	ebitenutil.DebugPrint(screen, "Hello, World!")
}

func (g *Game) Layout(outsideWidth, outsideHeight int) (int, int) {
	return screenWidth, screenHeight
}

func main() {
	g := &Game{}

	for i := range g.defaultMap {
		for j := range g.defaultMap[i] {
			borders := i == 0 || i == 10 || j == 0 || j == 16
			indestructibleTiles := i % 2 == 0  && j % 2 == 0

			topRows := i == 1 && (j == 1 || j == 2 || j == 14 || j == 15)
			bottomRows := i == 9 && (j == 1 || j == 2 || j == 14 || j == 15)
			verticalExtensions := (i == 2 || i == 8) && (j == 1 || j == 15)

			spawnAreas := topRows || bottomRows || verticalExtensions

			if borders || indestructibleTiles {
                g.defaultMap[i][j] = 0 // Parede indestrutível (Vermelho)
            } else if spawnAreas {
				g.defaultMap[i][j] = 1 // Chão livre (Verde)
			} else {
                if rand.Float32() < 0.75 {
					g.defaultMap[i][j] = 2 // Destructible wall (Blue)
				} else {
					g.defaultMap[i][j] = 1 // The remaining 20% stays as free floor (Green)
				}
            }
		}
	}

	ebiten.SetWindowSize(screenWidth * 2, screenHeight * 2)
	ebiten.SetWindowTitle("Bomberman")
	
	if err := ebiten.RunGame(g); err != nil {
		log.Fatal(err)
	}
}