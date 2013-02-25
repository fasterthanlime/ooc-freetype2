use freetype2
import freetype2

main: func {
    ft := FTLibrary
    ft init()

    path := "./Comfortaa-Regular.ttf"
    face: FTFace
    error := ft newFace(path, 0, face&)

    if (error) {
        "Error opening font %s" printfln(path)
        exit(1)
    }

    "Number of glyphs: %d" printfln(face@ numGlyphs)

    ft done()
}
