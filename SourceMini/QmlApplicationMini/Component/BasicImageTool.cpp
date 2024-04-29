#include "BasicImageTool.h"

BasicImageTool::BasicImageTool(QObject *parent)
    : QObject{parent}
{}

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
    updateInfo();
    updatePath();
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
    updatePath();
}

void BasicImageTool::updateInfo()
{

}

void BasicImageTool::updatePath()
{

}
