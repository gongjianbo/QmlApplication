#include "BasicImageTool.h"
#include <QImageReader>
#include <QSvgRenderer>
#include <QFile>
#include <QtMath>
#include <QDebug>

BasicImageTool::BasicImageTool(QObject *parent)
    : QObject{parent}
{

}

QUrl BasicImageTool::getSource() const
{
    return source;
}

void BasicImageTool::setSource(const QUrl &url)
{
    if (source == url) {
        return;
    }
    source = url;
    emit sourceChanged();
    updateImplicit();
    updatePainted();
}

QUrl BasicImageTool::getPath() const
{
    return path;
}

void BasicImageTool::setPath(const QUrl &url)
{
    if (path == url) {
        return;
    }
    path = url;
    emit pathChanged();
}

qreal BasicImageTool::getDevicePixelRatio() const
{
    return devicePixelRatio;
}

void BasicImageTool::setDevicePixelRatio(qreal ratio)
{
    if (qFuzzyCompare(devicePixelRatio, ratio)) {
        return;
    }
    devicePixelRatio = ratio;
    emit devicePixelRatioChanged();
    updatePainted();
}

QSize BasicImageTool::urlSize(const QUrl &url)
{
    auto &&src_path = urlToLocalFileOrQrc(url);
    if (src_path.endsWith(".svg")) {
        QSvgRenderer svg(src_path);
        return svg.defaultSize();
    } else if (!src_path.isEmpty()) {
        QImageReader img(src_path);
        return img.size();
    } else {
        return QSize(0, 0);
    }
}

QString BasicImageTool::urlToLocalFileOrQrc(const QUrl& url)
{
    if (url.scheme().compare(QLatin1String("qrc"), Qt::CaseInsensitive) == 0) {
        if (url.authority().isEmpty())
            return QLatin1Char(':') + url.path();
        return QString();
    }

#if defined(Q_OS_ANDROID)
    else if (url.scheme().compare(QLatin1String("assets"), Qt::CaseInsensitive) == 0) {
        if (url.authority().isEmpty())
            return url.toString();
        return QString();
    } else if (url.scheme().compare(QLatin1String("content"), Qt::CaseInsensitive) == 0) {
        return url.toString();
    }
#endif

    return url.toLocalFile();
}

QString BasicImageTool::findAtNxFile(const QString &baseFileName, qreal targetDevicePixelRatio,
                                     qreal *sourceDevicePixelRatio)
{
    if (targetDevicePixelRatio <= 1.0)
        return baseFileName;

    static bool disableNxImageLoading = !qEnvironmentVariableIsEmpty("QT_HIGHDPI_DISABLE_2X_IMAGE_LOADING");
    if (disableNxImageLoading)
        return baseFileName;

    int dotIndex = baseFileName.lastIndexOf(QLatin1Char('.'));
    if (dotIndex == -1) { /* no dot */
        dotIndex = baseFileName.size(); /* append */
    } else if (dotIndex >= 2 && baseFileName[dotIndex - 1] == QLatin1Char('9')
               && baseFileName[dotIndex - 2] == QLatin1Char('.')) {
        // If the file has a .9.* (9-patch image) extension, we must ensure that the @nx goes before it.
        dotIndex -= 2;
    }

    QString atNxfileName = baseFileName;
    atNxfileName.insert(dotIndex, QLatin1String("@2x"));
    // Check for @Nx, ..., @3x, @2x file versions,
    for (int n = qMin(qCeil(targetDevicePixelRatio), 9); n > 1; --n) {
        atNxfileName[dotIndex + 1] = QLatin1Char('0' + n);
        if (QFile::exists(atNxfileName)) {
            if (sourceDevicePixelRatio)
                *sourceDevicePixelRatio = n;
            return atNxfileName;
        }
    }

    return baseFileName;
}

void BasicImageTool::updateImplicit()
{
    // 获取图片默认宽高
    QSize size = urlSize(source);
    implicitWidth = size.width();
    implicitHeight = size.height();
    emit implicitChanged();
}

void BasicImageTool::updatePainted()
{
    // 获取 @2x 大图路径
    auto &&src_path = urlToLocalFileOrQrc(source);
    QUrl x_url = source;
    if (src_path.endsWith(".svg") || src_path.isEmpty()) {
    } else {
        int index = src_path.lastIndexOf(QLatin1Char('@'));
        qreal dpr = -1;
        if (index > 0 && index + 3 < src_path.size()) {
            if (src_path[index + 1].isDigit()
                && src_path[index + 2] == QLatin1Char('x')
                && src_path[index + 3] == QLatin1Char('.')) {
                dpr = src_path[index + 1].digitValue();
            }
        }
        if (dpr < 0) {
            QString x_path = findAtNxFile(src_path, devicePixelRatio, &dpr);
            if (x_path != src_path) {
                if (source.toString().startsWith("qrc")) {
                    x_url = QUrl("qrc" + x_path);
                } else {
                    x_url = QUrl::fromLocalFile(x_path);
                }
            }
        }
    }
    // qDebug()<<"path"<<x_url;
    setPath(x_url);
    // 实际图片宽高
    if (src_path.endsWith(".svg")) {
        paintedWidth = qFloor(implicitWidth * devicePixelRatio);
        paintedHeight = qFloor(implicitHeight * devicePixelRatio);
    } else {
        QSize size = urlSize(x_url);
        paintedWidth = size.width();
        paintedHeight = size.height();
    }
    emit paintedChanged();
}
