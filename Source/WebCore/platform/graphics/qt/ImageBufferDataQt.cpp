/*
 * Copyright (C) 2006 Nikolas Zimmermann <zimmermann@kde.org>
 * Copyright (C) 2008 Holger Hans Peter Freyther
 * Copyright (C) 2009 Dirk Schulze <krit@webkit.org>
 * Copyright (C) 2010 Torch Mobile (Beijing) Co. Ltd. All rights reserved.
 * Copyright (C) 2014 Digia Plc. and/or its subsidiary(-ies)
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
#include "ImageBuffer.h"

#include "GraphicsContext.h"
#include "GraphicsSurface.h"
#include "IntRect.h"
#include "StillImageQt.h"

#include <QImage>
#include <QPaintEngine>
#include <QPainter>
#include <QPixmap>

namespace WebCore {

// ---------------------- ImageBufferDataPrivateUnaccelerated

struct ImageBufferDataPrivateUnaccelerated final : public ImageBufferDataPrivate {
    ImageBufferDataPrivateUnaccelerated(const FloatSize&, float scale);
    QPaintDevice* paintDevice() final { return m_pixmap.isNull() ? 0 : &m_pixmap; }
    QImage toQImage() const final;
    RefPtr<Image> image() const final;
    RefPtr<Image> copyImage() const final;
    RefPtr<Image> takeImage() final;
    bool isAccelerated() const final { return false; }
    PlatformLayer* platformLayer() final { return 0; }
    void draw(GraphicsContext& destContext, const FloatRect& destRect,
        const FloatRect& srcRect, CompositeOperator, BlendMode, bool ownContext) final;
    void drawPattern(GraphicsContext& destContext, const FloatRect& srcRect, const AffineTransform& patternTransform,
        const FloatPoint& phase, const FloatSize& spacing, CompositeOperator,
        const FloatRect& destRect, BlendMode, bool ownContext) final;
    void clip(GraphicsContext&, const IntRect& floatRect) const final;
    void platformTransformColorSpace(const Vector<int>& lookUpTable) final;

    QPixmap m_pixmap;
    RefPtr<Image> m_image;
};

ImageBufferDataPrivateUnaccelerated::ImageBufferDataPrivateUnaccelerated(const FloatSize& size, float scale)
    : m_pixmap(IntSize(size * scale))
    , m_image(StillImage::createForRendering(&m_pixmap))
{
    m_pixmap.fill(QColor(Qt::transparent));
    m_pixmap.setDevicePixelRatio(scale);
}

QImage ImageBufferDataPrivateUnaccelerated::toQImage() const
{
    QPaintEngine* paintEngine = m_pixmap.paintEngine();
    if (!paintEngine || paintEngine->type() != QPaintEngine::Raster)
        return m_pixmap.toImage();

    // QRasterPixmapData::toImage() will deep-copy the backing QImage if there's an active QPainter on it.
    // For performance reasons, we don't want that here, so we temporarily redirect the paint engine.
    QPaintDevice* currentPaintDevice = paintEngine->paintDevice();
    paintEngine->setPaintDevice(0);
    QImage image = m_pixmap.toImage();
    paintEngine->setPaintDevice(currentPaintDevice);
    return image;
}

RefPtr<Image> ImageBufferDataPrivateUnaccelerated::image() const
{
    return StillImage::createForRendering(&m_pixmap);
}

RefPtr<Image> ImageBufferDataPrivateUnaccelerated::copyImage() const
{
    return StillImage::create(m_pixmap);
}

RefPtr<Image> ImageBufferDataPrivateUnaccelerated::takeImage()
{
    return StillImage::create(WTFMove(m_pixmap));
}

void ImageBufferDataPrivateUnaccelerated::draw(GraphicsContext& destContext, const FloatRect& destRect,
    const FloatRect& srcRect, CompositeOperator op, BlendMode blendMode, bool ownContext)
{
    if (ownContext) {
        // We're drawing into our own buffer. In order for this to work, we need to copy the source buffer first.
        RefPtr<Image> copy = copyImage();
        destContext.drawImage(*copy, destRect, srcRect, ImagePaintingOptions(op, blendMode, ImageOrientationDescription()));
    } else
        destContext.drawImage(*m_image, destRect, srcRect, ImagePaintingOptions(op, blendMode, ImageOrientationDescription()));
}

void ImageBufferDataPrivateUnaccelerated::drawPattern(GraphicsContext& destContext, const FloatRect& srcRect, const AffineTransform& patternTransform,
    const FloatPoint& phase, const FloatSize& spacing, CompositeOperator op,
    const FloatRect& destRect, BlendMode blendMode, bool ownContext)
{
    if (ownContext) {
        // We're drawing into our own buffer. In order for this to work, we need to copy the source buffer first.
        RefPtr<Image> copy = copyImage();
        copy->drawPattern(destContext, srcRect, patternTransform, phase, spacing, op, destRect, blendMode);
    } else
        m_image->drawPattern(destContext, srcRect, patternTransform, phase, spacing, op, destRect, blendMode);
}

void ImageBufferDataPrivateUnaccelerated::clip(GraphicsContext& context, const IntRect& rect) const
{
    QPixmap* nativeImage = m_image->nativeImageForCurrentFrame();
    if (!nativeImage)
        return;

    QPixmap alphaMask = *nativeImage;
    context.pushTransparencyLayerInternal(rect, 1.0, alphaMask);
}

void ImageBufferDataPrivateUnaccelerated::platformTransformColorSpace(const Vector<int>& lookUpTable)
{
    QPainter* painter = paintDevice()->paintEngine()->painter();

    bool isPainting = painter->isActive();
    if (isPainting)
        painter->end();

    QImage image = toQImage().convertToFormat(QImage::Format_ARGB32);
    ASSERT(!image.isNull());

    uchar* bits = image.bits();
    const int bytesPerLine = image.bytesPerLine();

    for (int y = 0; y < m_pixmap.height(); ++y) {
        quint32* scanLine = reinterpret_cast_ptr<quint32*>(bits + y * bytesPerLine);
        for (int x = 0; x < m_pixmap.width(); ++x) {
            QRgb& pixel = scanLine[x];
            pixel = qRgba(lookUpTable[qRed(pixel)],
                          lookUpTable[qGreen(pixel)],
                          lookUpTable[qBlue(pixel)],
                          qAlpha(pixel));
        }
    }

    m_pixmap = QPixmap::fromImage(image);

    if (isPainting)
        painter->begin(&m_pixmap);
}

// ---------------------- ImageBufferData

ImageBufferData::ImageBufferData(const FloatSize& size, float resolutionScale)
{
    m_painter = new QPainter;

    m_impl = new ImageBufferDataPrivateUnaccelerated(size, resolutionScale);

    if (!m_impl->paintDevice())
        return;
    if (!m_painter->begin(m_impl->paintDevice()))
        return;

    initPainter();
}

ImageBufferData::~ImageBufferData()
{
    m_painter->end();
    delete m_painter;
    delete m_impl;
}

void ImageBufferData::initPainter()
{
    m_painter->setRenderHints(QPainter::Antialiasing | QPainter::SmoothPixmapTransform);

    // Since ImageBuffer is used mainly for Canvas, explicitly initialize
    // its painter's pen and brush with the corresponding canvas defaults
    // NOTE: keep in sync with CanvasRenderingContext2D::State
    QPen pen = m_painter->pen();
    pen.setColor(Qt::black);
    pen.setWidth(1);
    pen.setCapStyle(Qt::FlatCap);
    pen.setJoinStyle(Qt::SvgMiterJoin);
    pen.setMiterLimit(10);
    m_painter->setPen(pen);
    QBrush brush = m_painter->brush();
    brush.setColor(Qt::black);
    m_painter->setBrush(brush);
    m_painter->setCompositionMode(QPainter::CompositionMode_SourceOver);
}

}
