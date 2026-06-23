package player

import (
	"bytes"
	_ "embed"
	"image"
	"log"

	gmap "bomberman/map"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
)

//go:embed player.png
var Player_png []byte

const (
	frameStartWidth = iota
	frameEndWidth   = 24
)

type Player struct {
	SpriteSheet  *ebiten.Image
	X, Y         float64
	CurrentFrame int
}

func(p *Player) Launcher(){
	img, _, err := image.Decode(bytes.NewReader(Player_png))
	if err != nil {
		log.Fatal(err)
	}

	p.SpriteSheet = ebiten.NewImageFromImage(img)
}

func(p *Player) Draw(screen *ebiten.Image){
	if p.SpriteSheet == nil {
        ebitenutil.DebugPrint(screen, "Erro: Player não carregado")
        return
    }

	// X never changes because the image is only 24px
    x0 := frameStartWidth
    x1 := frameEndWidth

    y0 := p.CurrentFrame * frameEndWidth
    y1 := y0 + frameEndWidth

	rect := image.Rect(x0, y0, x1, y1)
    subImg := p.SpriteSheet.SubImage(rect).(*ebiten.Image)

	op := &ebiten.DrawImageOptions{}

    posX := p.X
    posY := p.Y

    if posX == 0 && posY == 0 {
        posX = gmap.TilePixels
        posY = gmap.TilePixels
    }

    op.GeoM.Translate(posX, posY)
    screen.DrawImage(subImg, op)
}