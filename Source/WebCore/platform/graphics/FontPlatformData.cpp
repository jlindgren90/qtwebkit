/*
 * Copyright (C) 2008 Holger Hans Peter Freyther
 * Copyright (C) 2009 Torch Mobile Inc. http://www.torchmobile.com/
 * Copyright (C) 2011 Brent Fulgham
 * Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies)
 * Copyright (C) 2015 The Qt Company Ltd
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 */

#include "config.h"
#include "FontPlatformData.h"

#include <wtf/HashMap.h>
#include <wtf/RetainPtr.h>
#include <wtf/Vector.h>
#include <wtf/text/StringHash.h>
#include <wtf/text/WTFString.h>

#if PLATFORM(QT)
#include "FontCascade.h"
#include "FontDescription.h"
#include "SharedBuffer.h"
#endif

#if OS(DARWIN) && USE(CG)
#include "SharedBuffer.h"
#include <CoreGraphics/CGFont.h>
#endif

namespace WebCore {

FontPlatformData::FontPlatformData(WTF::HashTableDeletedValueType)
    : m_isHashTableDeletedValue(true)
{
}

FontPlatformData::FontPlatformData()
{
}

FontPlatformData::FontPlatformData(float size, bool syntheticBold, bool syntheticOblique, FontOrientation orientation, FontWidthVariant widthVariant, TextRenderingMode textRenderingMode)
    : m_size(size)
    , m_orientation(orientation)
    , m_widthVariant(widthVariant)
    , m_textRenderingMode(textRenderingMode)
    , m_syntheticBold(syntheticBold)
    , m_syntheticOblique(syntheticOblique)
{
#if PLATFORM(QT)
    // This is necessary for SVG Fonts, which are only supported when using QRawFont.
    // It is used to construct the appropriate platform data to use as a fallback.
    QFont font;
    font.setBold(syntheticBold);
    font.setItalic(syntheticOblique);
    m_rawFont = QRawFont::fromFont(font, QFontDatabase::Any);
    m_rawFont.setPixelSize(size);
#endif
}

#if PLATFORM(QT)
// See http://www.w3.org/TR/css3-fonts/#font-weight-prop
#if QT_VERSION >= QT_VERSION_CHECK(5, 5, 0)
static inline QFont::Weight toQFontWeight(FontWeight fontWeight)
{
    switch (fontWeight) {
    case FontWeight100:
        return QFont::Thin;
    case FontWeight200:
        return QFont::ExtraLight;
    case FontWeight300:
        return QFont::Light;
    case FontWeight400:
        return QFont::Normal;
    case FontWeight500:
        return QFont::Medium;
    case FontWeight600:
        return QFont::DemiBold;
    case FontWeight700:
        return QFont::Bold;
    case FontWeight800:
        return QFont::ExtraBold;
    case FontWeight900:
        return QFont::Black;
    }
    Q_UNREACHABLE();
}
#else
static inline QFont::Weight toQFontWeight(FontWeight fontWeight)
{
    switch (fontWeight) {
    case FontWeight100:
    case FontWeight200:
    case FontWeight300:
        return QFont::Light; // QFont::Light == Weight of 25
    case FontWeight400:
    case FontWeight500:
        return QFont::Normal; // QFont::Normal == Weight of 50
    case FontWeight600:
        return QFont::DemiBold; // QFont::DemiBold == Weight of 63
    case FontWeight700:
        return QFont::Bold; // QFont::Bold == Weight of 75
    case FontWeight800:
    case FontWeight900:
        return QFont::Black; // QFont::Black == Weight of 87
    }
    Q_UNREACHABLE();
}
#endif

FontPlatformData::FontPlatformData(const FontDescription& description, const AtomicString& family)
{
    QFont font;
    int requestedSize = description.computedPixelSize();
    font.setFamily(family);
    if (requestedSize)
        font.setPixelSize(requestedSize);
    font.setItalic(description.italic());
    font.setWeight(toQFontWeight(description.weight()));

    if (!FontCascade::shouldUseSmoothing())
        font.setStyleStrategy(static_cast<QFont::StyleStrategy>(QFont::NoAntialias | QFont::ForceOutline));
    else
        font.setStyleStrategy(QFont::ForceOutline);

    // WebKit allows font size zero but QFont does not
    m_size = (!requestedSize) ? requestedSize : font.pixelSize();
    m_rawFont = QRawFont::fromFont(font, QFontDatabase::Any);
}

RefPtr<SharedBuffer> FontPlatformData::openTypeTable(uint32_t table) const
{
    const char tag[4] = {
        char(table & 0xff),
        char((table & 0xff00) >> 8),
        char((table & 0xff0000) >> 16),
        char(table >> 24)
    };
    QByteArray tableData = m_rawFont.fontTable(tag);
    return SharedBuffer::create(tableData.data(), tableData.size());
}
#endif

#if USE(CG)
FontPlatformData::FontPlatformData(CGFontRef cgFont, float size, bool syntheticBold, bool syntheticOblique, FontOrientation orientation, FontWidthVariant widthVariant, TextRenderingMode textRenderingMode)
    : FontPlatformData(size, syntheticBold, syntheticOblique, orientation, widthVariant, textRenderingMode)
{
    m_cgFont = cgFont;
    ASSERT(m_cgFont);
}
#endif

#if !USE(FREETYPE)
FontPlatformData FontPlatformData::cloneWithOrientation(const FontPlatformData& source, FontOrientation orientation)
{
    FontPlatformData copy(source);
    copy.m_orientation = orientation;
    return copy;
}

FontPlatformData FontPlatformData::cloneWithSyntheticOblique(const FontPlatformData& source, bool syntheticOblique)
{
    FontPlatformData copy(source);
    copy.m_syntheticOblique = syntheticOblique;
    return copy;
}

FontPlatformData FontPlatformData::cloneWithSize(const FontPlatformData& source, float size)
{
    FontPlatformData copy(source);
    copy.m_size = size;
#if PLATFORM(QT)
    copy.m_rawFont.setPixelSize(size);
#endif
    return copy;
}
#endif

}
