package main

import (
	"log"

	"github.com/kulado/wealthmind/kuladoapi/actions"
)

func main() {
	app := actions.App()
	if err := app.Serve(); err != nil {
		log.Fatal(err)
	}
}
