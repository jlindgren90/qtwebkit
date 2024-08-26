/*
 * Copyright (C) 2006 Dirk Mueller <mueller@kde.org>
 * Copyright (C) 2006 Zack Rusin <zack@kde.org>
 * Copyright (C) 2006 Simon Hausmann <hausmann@kde.org>
 * Copyright (C) 2009 Torch Mobile Inc. http://www.torchmobile.com/
 * Copyright (C) 2010 Sencha, Inc.
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

#include "config.h"
#include "Image.h"

#include "AffineTransform.h"
#include "BitmapImage.h"
#include "FloatRect.h"
#include "GraphicsContext.h"
#include "ImageBackingStore.h"
#include "ImageObserver.h"
#include "ShadowBlur.h"
#include "StillImageQt.h"
#include "Timer.h"

#include <QCoreApplication>
#include <QImage>
#include <QImageReader>
#include <QPaintEngine>
#include <QPainter>
#include <QPixmap>
#include <QPixmapCache>
#include <QTransform>
#include <private/qhexstring_p.h>
#include <wtf/NeverDestroyed.h>
#include <wtf/text/WTFString.h>

#if OS(WINDOWS)
QT_BEGIN_NAMESPACE
Q_GUI_EXPORT QPixmap qt_pixmapFromWinHBITMAP(HBITMAP, int hbitmapFormat = 0);
QT_END_NAMESPACE
#endif

typedef Vector<QPixmap, 3> WebGraphicVector;
typedef HashMap<CString, WebGraphicVector> WebGraphicHash;

static WebGraphicHash& graphics()
{
    static NeverDestroyed<WebGraphicHash> hash;

    if (hash.get().isEmpty()) {
        // QWebSettings::MissingImageGraphic
        hash.get().add("missingImage", WebGraphicVector { {
            QPixmap(QStringLiteral(":webkit/resources/missingImage.png")),
            QPixmap(QStringLiteral(":webkit/resources/missingImage@2x.png")),
            QPixmap(QStringLiteral(":webkit/resources/missingImage@3x.png"))
        } });

        // QWebSettings::MissingPluginGraphic
        hash.get().add("nullPlugin", WebGraphicVector { {
            QPixmap(QStringLiteral(":webkit/resources/nullPlugin.png")),
            QPixmap(QStringLiteral(":webkit/resources/nullPlugin@2x.png"))
        } });

        // QWebSettings::DefaultFrameIconGraphic
        hash.get().add("urlIcon", WebGraphicVector { {
            QPixmap(QStringLiteral(":webkit/resources/urlIcon.png"))
        } });

        // QWebSettings::TextAreaSizeGripCornerGraphic
        hash.get().add("textAreaResizeCorner", WebGraphicVector { {
            QPixmap(QStringLiteral(":webkit/resources/textAreaResizeCorner.png")),
            QPixmap(QStringLiteral(":webkit/resources/textAreaResizeCorner@2x.png"))
        } });
    }

    return hash;
}

static QPixmap loadResourcePixmapForScale(const CString& name, size_t scale)
{
    const auto& iterator = graphics().find(name);
    if (iterator == graphics().end())
        return QPixmap();

    WebGraphicVector v = iterator->value;
    if (scale <= v.size())
        return v[scale - 1];

    return v.last();
}

static QPixmap loadResourcePixmap(const char* name)
{
    int length = strlen(name);

    // Handle "name@2x" and "name@3x"
    if (length > 3 && name[length - 1] == 'x' && name[length - 3] == '@' && isASCIIDigit(name[length - 2])) {
        CString nameWithoutScale(name, length - 3);
        char digit = name[length - 2];
        size_t scale = digit - '0';
        return loadResourcePixmapForScale(nameWithoutScale, scale);
    }

    return loadResourcePixmapForScale(CString(name, length), 1);
}

namespace WebCore {

NativeImagePtr ImageBackingStore::image() const
{
    QImage::Format format = m_premultiplyAlpha ? QImage::Format_ARGB32_Premultiplied : QImage::Format_ARGB32;
    QImage img((const uchar*)m_pixelsPtr, size().width(), size().height(), size().width() * sizeof(RGBA32), format);
    return QPixmap::fromImage(img);
}

IntSize nativeImageSize(const NativeImagePtr& image)
{
    return { image->width(), image->height() };
}

bool nativeImageHasAlpha(const NativeImagePtr& image)
{
    return image->hasAlpha();
}

Color nativeImageSinglePixelSolidColor(const NativeImagePtr& image)
{
    if (image->size() != QSize(1, 1))
        return Color();

    return QColor::fromRgba(image->toImage().pixel(0, 0));
}

float subsamplingScale(GraphicsContext&, const FloatRect&, const FloatRect&)
{
    return 1;
}

// ================================================
// Image Class
// ================================================

PassRefPtr<Image> Image::loadPlatformResource(const char* name)
{
    return StillImage::create(loadResourcePixmap(name));
}

void Image::setPlatformResource(const char* name, const QPixmap& pixmap)
{
    if (pixmap.isNull())
        graphics().remove(name);
    else
        graphics().add(name, WebGraphicVector { pixmap });
}

void Image::drawPattern(GraphicsContext& ctxt, const FloatRect& tileRect, const AffineTransform& patternTransform,
    const FloatPoint& phase, const FloatSize& spacing, CompositeOperator op, const FloatRect& destRect, BlendMode blendMode)
{
    ctxt.drawPattern(*this, tileRect, patternTransform, phase, spacing, op, destRect, blendMode);

    if (imageObserver())
        imageObserver()->didDraw(this);
}

void BitmapImage::invalidatePlatformData()
{
}

QPixmap prescaleImageIfRequired(QPainter* painter, const QPixmap &image, const QRectF& destRect, QRectF* srcRect)
{
    // The quality of down scaling at 0.5x and below in QPainter is not very good
    // due to using bilinear sampling, so for high quality scaling we need to
    // perform scaling ourselves.
    ASSERT(image);
    ASSERT(painter);
    if (!(painter->renderHints() & QPainter::SmoothPixmapTransform))
        return image;

    if (painter->paintEngine()->type() != QPaintEngine::Raster)
        return image;

    QTransform transform = painter->combinedTransform();

    // Prescaling transforms that does more than scale or translate is not supported.
    if (transform.type() > QTransform::TxScale)
        return image;

    QRectF transformedDst = transform.mapRect(destRect);
    // Only prescale if downscaling to 0.5x or less
    if (transformedDst.width() * 2 > srcRect->width() && transformedDst.height() * 2 > srcRect->height())
        return image;

    // This may not work right with subpixel positions, but that can not currently happen.
    QRect pixelSrc = srcRect->toRect();
    QSize scaledSize = transformedDst.size().toSize();

    QString key = QStringLiteral("qtwebkit_prescaled_")
        % HexString<qint64>(image.cacheKey())
        % HexString<int>(pixelSrc.x()) % HexString<int>(pixelSrc.y())
        % HexString<int>(pixelSrc.width()) % HexString<int>(pixelSrc.height())
        % HexString<int>(scaledSize.width()) % HexString<int>(scaledSize.height());

    QPixmap buffer;
    if (!QPixmapCache::find(key, &buffer)) {
        if (pixelSrc != image.rect())
            buffer = image.copy(pixelSrc).scaled(scaledSize, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
        else
            buffer = image.scaled(scaledSize, Qt::IgnoreAspectRatio, Qt::SmoothTransformation);
        QPixmapCache::insert(key, buffer);
    }

    *srcRect = QRectF(QPointF(), buffer.size());
    return buffer;
}

// Drawing Routines
void drawNativeImage(const NativeImagePtr& srcImage, GraphicsContext& ctxt, const FloatRect& dst,
    const FloatRect& src, const IntSize&, CompositeOperator op, BlendMode blendMode, const ImageOrientation&)
{
    QRectF normalizedDst = dst.normalized();
    QRectF normalizedSrc = src.normalized();

    if (normalizedSrc.isEmpty() || normalizedDst.isEmpty())
        return;

#if ENABLE(IMAGE_DECODER_DOWN_SAMPLING)
    normalizedSrc = adjustSourceRectForDownSampling(normalizedSrc, srcImage->size());
#endif

    QPixmap image = prescaleImageIfRequired(ctxt.platformContext(), *srcImage, normalizedDst, &normalizedSrc);

    CompositeOperator previousOperator = ctxt.compositeOperation();
    BlendMode previousBlendMode = ctxt.blendModeOperation();
    ctxt.setCompositeOperation(!image.hasAlpha() && op == CompositeSourceOver && blendMode == BlendModeNormal ? CompositeCopy : op, blendMode);

    if (ctxt.hasShadow()) {
        ShadowBlur shadow(ctxt.state());
        GraphicsContext* shadowContext = shadow.beginShadowLayer(ctxt, normalizedDst);
        if (shadowContext) {
            QPainter* shadowPainter = shadowContext->platformContext();
            shadowPainter->drawPixmap(normalizedDst, image, normalizedSrc);
            shadow.endShadowLayer(ctxt);
        }
    }

    ctxt.platformContext()->drawPixmap(normalizedDst, image, normalizedSrc);

    ctxt.setCompositeOperation(previousOperator, previousBlendMode);
}

void clearNativeImageSubimages(const NativeImagePtr&)
{
}

#if OS(WINDOWS)
PassRefPtr<BitmapImage> BitmapImage::create(HBITMAP hBitmap)
{
    QPixmap* qPixmap = new QPixmap(qt_pixmapFromWinHBITMAP(hBitmap));

    return BitmapImage::create(qPixmap);
}
#endif

}


// vim: ts=4 sw=4 et
