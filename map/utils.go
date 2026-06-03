package gmap

import "math/rand/v2"

func shuffle(tiles []Point) []Point{
	rand.Shuffle(len(tiles), func(i int, j int) {
		tiles[i], tiles[j] = tiles[j], tiles[i]
	})

	return tiles
}