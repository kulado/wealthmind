package grifts

import (
	"github.com/gobuffalo/buffalo"
	"github.com/kulado/wealthmind/kuladoapi/actions"
)

func init() {
	buffalo.Grifts(actions.App())
}
