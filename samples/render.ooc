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

    dpi := 300
    face setCharSize(0, 16*64, dpi, dpi)
    glyphIndex := face getCharIndex('F' as ULong)
    face loadGlyph(glyphIndex, FTLoadFlag default)
    
    error = face@ glyph render(FTRenderMode normal)
    if (error) {
        "Error rendering glyph" println()
        exit(1)
    }

    draw(face@ glyph@ bitmap)
}

draw: func (bitmap: FTBitmap) {
    "Should draw a %dx%d bitmap (%d pitch)" printfln(bitmap width, bitmap rows, bitmap pitch)
}

