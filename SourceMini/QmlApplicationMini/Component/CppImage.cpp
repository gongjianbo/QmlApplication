#include "CppImage.h"
#include <QImageReader>
#include <QSvgRenderer>
#include <QFile>
#include <QPainter>
#include <QtMath>
#include <QDebug>
#include "BasicImageTool.h"

CppImage::CppImage(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{

}

QUrl CppImage::getSource() const
{
    return source;
}

void CppImage::setSource(const QUrl &url)
{
    if (source == url) {
        return;
    }
    source = url;
    emit sourceChanged();
    update();
}

qreal CppImage::getDevicePixelRatio() const
{
    return devicePixelRatio;
}

void CppImage::setDevicePixelRatio(qreal ratio)
{
    if (qFuzzyCompare(devicePixelRatio, ratio)) {
        return;
    }
    devicePixelRatio = ratio;
    emit devicePixelRatioChanged();
    update();
}

void CppImage::paint(QPainter *painter)
{
    painter->fillRect(boundingRect(), Qt::white);
    auto &&src_path = BasicImageTool::urlToLocalFileOrQrc(source);
    if (src_path.endsWith(".svg")) {
        QImage image;
        {
            QSvgRenderer svg(src_path);
            image = QImage(svg.defaultSize() * devicePixelRatio, QImage::Format_ARGB32);
            image.fill(Qt::white);
            QPainter p(&image);
            svg.render(&p);
        }
        painter->drawImage(0, 0, image);
    } else if (!src_path.isEmpty()) {
        QImageReader img(src_path);
        QImage image = img.read();
        image = image.scaled(image.size() * devicePixelRatio, Qt::KeepAspectRatio, Qt::SmoothTransformation);
        painter->drawImage(0, 0, image);
    }
}
