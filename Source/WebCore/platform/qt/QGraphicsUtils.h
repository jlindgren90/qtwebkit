/*
 * Copyright (C) 2024 John Lindgren <john@jlindgren.net>
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE COMPUTER, INC. ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef QGraphicsUtils_h
#define QGraphicsUtils_h

#include "Color.h"
#include "FloatPoint.h"
#include "FloatRect.h"
#include "FloatSize.h"
#include "FontCascade.h"
#include "IntPoint.h"
#include "IntRect.h"
#include "IntSize.h"
#include "NativeImagePtr.h"

#include <QColor>
#include <QFont>
#include <QImage>
#include <QPixmap>
#include <QPoint>
#include <QPointF>
#include <QRect>
#include <QRectF>
#include <QSize>
#include <QSizeF>
#include <cairo.h>

namespace WebCore {

inline Color fromQColor(const QColor& c)
{
    if (c.isValid())
        return Color(c.red(), c.green(), c.blue(), c.alpha());
    else
        return Color();
}

inline QColor toQColor(const Color& c)
{
    if (c.isValid())
        return QColor(c.red(), c.green(), c.blue(), c.alpha());
    else
        return QColor();
}

inline IntPoint fromQPoint(const QPoint& p) { return { p.x(), p.y() }; }
inline QPoint toQPoint(const IntPoint& p) { return { p.x(), p.y() }; }
inline FloatPoint fromQPointF(const QPointF& p)  { return { (float)p.x(), (float)p.y() }; }
inline QPointF toQPointF(const FloatPoint& p) { return { p.x(), p.y() }; }

inline IntRect fromQRect(const QRect& r) { return { r.x(), r.y(), r.width(), r.height() }; }
inline QRect toQRect(const IntRect& r) { return { r.x(), r.y(), r.width(), r.height() }; }
inline FloatRect fromQRectF(const QRectF& r) { return { (float)r.x(), (float)r.y(), (float)r.width(), (float)r.height() }; }
inline QRectF toQRectF(const FloatRect& r) { return { r.x(), r.y(), r.width(), r.height() }; }

inline IntSize fromQSize(const QSize& s) { return { s.width(), s.height() }; }
inline QSize toQSize(const IntSize& s) { return { s.width(), s.height() }; }
inline FloatSize fromQSizeF(const QSizeF& s) { return { (float)s.width(), (float)s.height() }; }
inline QSizeF toQSizeF(const FloatSize& s) { return { s.width(), s.height() }; }

inline QFont toQFont(const FontCascade& fontCascade)
{
    // just make it the right size
    QFont font;
    font.setPixelSize(fontCascade.pixelSize());
    return font;
}

inline QImage toQImage(NativeImagePtr&& nativeImg)
{
    cairo_surface_t* surface = nativeImg.leakRef();
    if (!surface || cairo_surface_get_type(surface) != CAIRO_SURFACE_TYPE_IMAGE
                 || cairo_image_surface_get_format(surface) != CAIRO_FORMAT_ARGB32)
        return QImage();

    cairo_surface_flush(surface);
    auto cleanup = [](void* s) {
        cairo_surface_mark_dirty((cairo_surface_t*)s);
        cairo_surface_destroy((cairo_surface_t*)s);
    };

    return QImage(cairo_image_surface_get_data(surface),
                  cairo_image_surface_get_width(surface),
                  cairo_image_surface_get_height(surface),
                  cairo_image_surface_get_stride(surface),
                  QImage::Format_ARGB32_Premultiplied,
                  cleanup, surface);
}

inline QPixmap toQPixmap(NativeImagePtr&& nativeImg)
{
    return QPixmap::fromImage(toQImage(std::move(nativeImg)));
}

} // namespace WebCore

#endif
