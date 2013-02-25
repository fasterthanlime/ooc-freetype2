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

    glyph: FTGlyph
    face@ glyph getGlyph(glyph&)
    
    cbox: FTBBox
    glyph getCBox(FTGlyphBBoxMode unscaled, cbox&)
    "xMin = %.2f yMin = %.2f, xMax = %.2f, yMax = %.2f" printfln(
        cbox xMin toFloat(),
        cbox yMin toFloat(),
        cbox xMax toFloat(),
        cbox yMax toFloat()
    )
}

