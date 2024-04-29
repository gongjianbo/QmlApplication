#pragma once
#include <QObject>
#include <QUrl>

/**
 * @brief 获取图片的宽高、查找x倍大图
 * @author 龚建波
 * @date 2021-04-29
 */
class BasicImageTool : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ getSource WRITE setSource NOTIFY sourceChanged FINAL)
    Q_PROPERTY(QUrl path READ getSource NOTIFY pathChanged FINAL)
    Q_PROPERTY(qreal devicePixelRatio READ getDevicePixelRatio WRITE setDevicePixelRatio NOTIFY devicePixelRatioChanged FINAL)
    Q_PROPERTY(int implicitWidth MEMBER implicitWidth NOTIFY infoChanged FINAL)
    Q_PROPERTY(int implicitHeight MEMBER implicitHeight NOTIFY infoChanged FINAL)
public:
    explicit BasicImageTool(QObject *parent = nullptr);

    // 图片的路径
    QUrl getSource() const;
    void setSource(const QUrl &url);

    // 根据缩放比找 x 倍大图路径
    QUrl getPath() const;
    void setPath(const QUrl &url);

    // 屏幕的缩放比
    qreal getDevicePixelRatio() const;
    void setDevicePixelRatio(qreal ratio);

signals:
    void sourceChanged();
    void pathChanged();
    void devicePixelRatioChanged();
    void infoChanged();

private:
    // 更新 source 后重置图片宽高
    void updateInfo();
    // 更新比例后更新对应 x 倍路径
    void updatePath();

private:
    // 图片的路径
    QUrl source;
    // 根据缩放比找 x 倍大图路径
    QUrl path;
    // 屏幕的缩放比
    qreal devicePixelRatio{ 1.0 };
    // source 图片默认宽高
    int implicitWidth{ 0 };
    int implicitHeight{ 0 };
};
