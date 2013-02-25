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
    face setCharSize(16 * 64, 8 * 64, dpi, dpi)
    glyphIndex := face getCharIndex('@' as ULong)
    face loadGlyph(glyphIndex, FTLoadFlag default)
    
    error = face@ glyph render(FTRenderMode normal)
    if (error) {
        "Error rendering glyph" println()
        exit(1)
    }

    draw(face@ glyph@ bitmap)

    ft done()
}

draw: func (bitmap: FTBitmap) {
    for (row in 0..bitmap rows) {
        for (col in 0..bitmap width) {
            val := bitmap buffer[row * bitmap pitch + col]
            match {
                case (val > 196) => "#"
                case (val > 128) => "&"
                case (val > 64)  => ":"
                case (val > 32)  => "*"
                case (val > 16)  => "."
                case             => " "
            } print()
        }
        println()
    }
}

