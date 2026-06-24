package player

import (
	"bytes"
	_ "embed"
	"fmt"
	"image"
	"log"

	"bomberman/config"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
)

//go:embed player.png
var Player_png []byte

const (
	up = iota
	up1
	up2
	right0
	right1
	right2
	left0
	left1
	left2
	down0
	down1
	down2
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
    x0 := config.FrameStartWidth
    x1 := config.FrameEndWidth

    y0 := p.CurrentFrame * config.FrameEndWidth
    y1 := y0 + config.FrameEndWidth

	rect := image.Rect(x0, y0, x1, y1)
    subImg := p.SpriteSheet.SubImage(rect).(*ebiten.Image)

	op := &ebiten.DrawImageOptions{}

    if p.X == 0 && p.Y == 0 {
        p.X = config.TilePixels
        p.Y = config.TilePixels
    }

    op.GeoM.Translate(p.X, p.Y)
    screen.DrawImage(subImg, op)
}

func(p *Player) MovePlayer() {
	if ebiten.IsKeyPressed(ebiten.KeyA) || ebiten.IsKeyPressed(ebiten.KeyArrowLeft) {
		if p.X > 0 + 32 {
			p.CurrentFrame = left0
			p.X -= config.TilePixels
		}

		fmt.Println(p.X, p.Y)
	}

	if ebiten.IsKeyPressed(ebiten.KeyW) || ebiten.IsKeyPressed(ebiten.KeyArrowUp) {
		fmt.Println("W/up")
	}
	
	if ebiten.IsKeyPressed(ebiten.KeyS) || ebiten.IsKeyPressed(ebiten.KeyArrowDown) {
		fmt.Println("S/down")
	}

	if ebiten.IsKeyPressed(ebiten.KeyD) || ebiten.IsKeyPressed(ebiten.KeyArrowRight) {

		if p.X < (544 - (32 * 2)) {
			p.CurrentFrame = right0
			p.X += config.TilePixels
			
		}

		fmt.Println(p.X, p.Y)

		
	}
}