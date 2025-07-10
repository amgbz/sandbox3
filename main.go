package main

import (
	"fmt"
	"log"
	"os"

	"gioui.org/app"
	"gioui.org/io/key"
	"gioui.org/layout"
	"gioui.org/op"
	"gioui.org/text"
	"gioui.org/unit"
	"gioui.org/widget/material"

	"gioui.org/font/gofont"
)

// Version information injected at build time
var (
	version   = "dev"
	buildDate = "unknown"
	gitCommit = "unknown"
	gitTag    = "unknown"
)

func main() {
	go func() {
		// Create new window using correct v0.8.0 API
		w := new(app.Window)
		w.Option(app.Title("Hello World - Gio GUI"))
		w.Option(app.Size(unit.Dp(400), unit.Dp(300)))

		err := run(w)
		if err != nil {
			log.Fatal(err)
		}
		os.Exit(0)
	}()
	app.Main()
}

func run(w *app.Window) error {
	th := material.NewTheme()
	th.Shaper = text.NewShaper(text.WithCollection(gofont.Collection()))

	var ops op.Ops
	for {
		// Use correct v0.8.0 event handling
		switch e := w.Event().(type) {
		case app.DestroyEvent:
			return e.Err
		case app.FrameEvent:
			gtx := app.NewContext(&ops, e)
			drawUI(gtx, th)
			e.Frame(gtx.Ops)
		case key.Event:
			if e.Name == key.NameEscape {
				return nil
			}
		}
	}
}

func drawUI(gtx layout.Context, th *material.Theme) layout.Dimensions {
	return layout.Center.Layout(gtx, func(gtx layout.Context) layout.Dimensions {
		return layout.Flex{
			Axis:      layout.Vertical,
			Alignment: layout.Middle,
		}.Layout(gtx,
			layout.Rigid(func(gtx layout.Context) layout.Dimensions {
				title := material.H1(th, "Hello, World!")
				title.Alignment = text.Middle
				return title.Layout(gtx)
			}),
			layout.Rigid(func(gtx layout.Context) layout.Dimensions {
				return layout.Inset{Top: unit.Dp(20)}.Layout(gtx, func(gtx layout.Context) layout.Dimensions {
					subtitle := material.H6(th, "Cross-Platform GUI with Go and Gioui")
					subtitle.Alignment = text.Middle
					return subtitle.Layout(gtx)
				})
			}),
			layout.Rigid(func(gtx layout.Context) layout.Dimensions {
				return layout.Inset{Top: unit.Dp(30)}.Layout(gtx, func(gtx layout.Context) layout.Dimensions {
					versionInfo := fmt.Sprintf("Version: %s\nTag: %s\nBuilt: %s\nCommit: %.7s", version, gitTag, buildDate, gitCommit)
					versionLabel := material.Body2(th, versionInfo)
					versionLabel.Alignment = text.Middle
					return versionLabel.Layout(gtx)
				})
			}),
		)
	})
}