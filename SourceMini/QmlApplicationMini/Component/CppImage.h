#pragma once
#include <QQuickPaintedItem>
#include <QImage>

/**
 * @brief 测试在 C++ 中加载图片并缩放
 */
class CppImage : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ getSource WRITE setSource NOTIFY sourceChanged FINAL)
    Q_PROPERTY(qreal devicePixelRatio READ getDevicePixelRatio WRITE setDevicePixelRatio NOTIFY devicePixelRatioChanged FINAL)
public:
    explicit CppImage(QQuickItem *parent = nullptr);

    // 图片的路径
    QUrl getSource() const;
    void setSource(const QUrl &url);

    // 屏幕的缩放比
    qreal getDevicePixelRatio() const;
    void setDevicePixelRatio(qreal ratio);

    void paint(QPainter *painter) override;

signals:
    void sourceChanged();
    void devicePixelRatioChanged();

private:
    // 图片的路径
    QUrl source;
    // 屏幕的缩放比
    qreal devicePixelRatio{ 1.0 };
};
