use freetype2
import freetype2

import structs/[List, ArrayList]

Vector2: class {
    x, y: Float

    init: func (=x, =y)

    set!: func (=x, =y)

    add!: func (.x, .y) {
        this x += x
        this y += y
    }

    add!: func ~otherVec (v: This) {
        this x += v x
        this y += v y
    }

    toString: func -> String {
        "[%.2f, %.2f]" format(x, y)
    }

    _: String { get { toString() } }
}

BBox: class {
    xMin, yMin, xMax, yMax: Float

    init: func {
        // all 0
    }
    
    init: func ~fromFtBbox (bbox: FTBBox) {
        xMin = bbox xMin toFloat()
        yMin = bbox yMin toFloat()
        xMax = bbox xMax toFloat()
        yMax = bbox yMax toFloat()
    }

    add!: func (v: Vector2) {
        xMin += v x
        yMin += v y
        xMax += v x
        yMax += v y
    }

    expand!: func (other: This) {
        if (other xMin < xMin) {
            xMin = other xMin
        }

        if (other yMin < yMin) {
            yMin = other yMin
        }

        if (other xMax > xMax) {
            xMax = other xMax
        }

        if (other yMax > yMax) {
            yMax = other yMax
        }
    }

    expand!: func ~fromVec2 (other: Vector2) {
        if (other x < xMin) {
            xMin = other x
        }

        if (other y < yMin) {
            yMin = other y
        }

        if (other x > xMax) {
            xMax = other x
        }

        if (other y > yMax) {
            yMax = other y
        }
    }

    toString: func -> String {
        "[[%.2f, %.2f], [%.2f, %.2f]]" format(xMin, yMin,
            xMax, yMax)
    }

    _: String { get { toString() } }

    width:  Float { get { xMax - xMin } }
    height: Float { get { yMax - yMin } }
}

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

    renderText(face, "free")
    renderText(face, "type")

    ft done()
}

renderText: func (face: FTFace, text: String) {
    bbox := BBox new()

    spacingX := 2.0

    dpi := 300
    face setCharSize(6 * 64, 3 * 64, dpi, dpi)

    position := Vector2 new(0, 0)

    for (c in text) {
        glyphIndex := face getCharIndex(c as ULong)
        face loadGlyph(glyphIndex, FTLoadFlag default)

        glyph: FTGlyph
        face@ glyph getGlyph(glyph&)

        cbox: FTBBox
        glyph getCBox(FTGlyphBBoxMode unscaled, cbox&)

        tempBbox := BBox new(cbox)
        tempBbox add!(position)

        bbox expand!(tempBbox)

        position x += face@ glyph@ advance x toFloat()
        position x += spacingX
    }
    bbox expand!(position)

    position set!(0, 0)

    bitmap: FTBitmap
    bitmap init()

    bitmap width = bbox width
    bitmap pitch = bitmap width
    bitmap rows = bbox height
    bitmap buffer = gc_malloc(UInt8 size * bitmap pitch * bitmap rows)

    offset := Vector2 new(bbox xMin, bbox yMin)

    for (c in text) {
        glyphIndex := face getCharIndex(c as ULong)
        face loadGlyph(glyphIndex, FTLoadFlag default)

        error := face@ glyph render(FTRenderMode normal)
        if (error) {
            "Error rendering glyph" println()
            exit(1)
        }

        blit(face@ glyph@ bitmap, bitmap, position,
            face@ glyph@ bitmapLeft,
            face@ glyph@ bitmapTop,
            offset)

        position x += face@ glyph@ advance x toFloat()
        position x += spacingX
    }

    println()
    draw(bitmap)
}

blit: func (source: FTBitmap, dest: FTBitmap, position: Vector2,
    left: Int, top: Int, offset: Vector2) {

    ourPos := Vector2 new(position x, position y)
    ourPos add!(left, top)
    ourPos y = dest rows - ourPos y
    ourPos add!(offset)

    for (x in 0..source width) {
        for (y in 0..source rows) {
            actualX := x + ourPos x
            actualY := y + ourPos y

            dest buffer[actualX + actualY * dest pitch] = \
                source buffer[x + y * source pitch]
        }
    }
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

