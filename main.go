package main

import (
	"bomberman/config"
	gmap "bomberman/map"
	"bomberman/player"
	"log"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
)

type Game struct{
	Map *gmap.Map
	Player *player.Player
}

func (g *Game) Update() error {
	g.Player.MovePlayer()
	return nil
}

func (g *Game) Draw(screen *ebiten.Image) {
	g.Map.Draw(screen)
	g.Player.Draw(screen)

	ebitenutil.DebugPrint(screen, "Hello, World!")
}

func (g *Game) Layout(outsideWidth, outsideHeight int) (int, int) {
	return config.ScreenWidth, config.ScreenHeight
}

func main() {
	g := &Game{}
	g.Map = &gmap.Map{}
	g.Player = &player.Player{}

	g.Map.Generate()
	g.Player.Launcher()

	ebiten.SetWindowSize(config.ScreenWidth * 2, config.ScreenHeight * 2)
	ebiten.SetWindowTitle("Bomberman")
	
	if err := ebiten.RunGame(g); err != nil {
		log.Fatal(err)
	}
}