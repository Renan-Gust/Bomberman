package main

import (
	gmap "bomberman/map"
	"bomberman/player"
	"log"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
)

const (
	screenWidth  = 544
	screenHeight = 352
)

type Game struct{
	Map *gmap.Map
	Player *player.Player
}

func (g *Game) Update() error {
	return nil
}

func (g *Game) Draw(screen *ebiten.Image) {
	g.Map.Draw(screen)
	g.Player.Draw(screen)

	ebitenutil.DebugPrint(screen, "Hello, World!")
}

func (g *Game) Layout(outsideWidth, outsideHeight int) (int, int) {
	return screenWidth, screenHeight
}

func main() {
	g := &Game{}
	g.Map = &gmap.Map{}
	g.Player = &player.Player{}

	g.Map.Generate()
	g.Player.Launcher()

	ebiten.SetWindowSize(screenWidth * 2, screenHeight * 2)
	ebiten.SetWindowTitle("Bomberman")
	
	if err := ebiten.RunGame(g); err != nil {
		log.Fatal(err)
	}
}