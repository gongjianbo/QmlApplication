#pragma once
#include <QObject>
#include <QUrl>

/**
 * @brief 获取图片的宽高、查找 x 倍大图
 * @author 龚建波
 * @date 2024-04-29
 */
class BasicImageTool : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ getSource WRITE setSource NOTIFY sourceChanged FINAL)
    Q_PROPERTY(QUrl path READ getPath NOTIFY pathChanged FINAL)
    Q_PROPERTY(qreal devicePixelRatio READ getDevicePixelRatio WRITE setDevicePixelRatio NOTIFY devicePixelRatioChanged FINAL)
    Q_PROPERTY(int implicitWidth MEMBER implicitWidth NOTIFY implicitChanged FINAL)
    Q_PROPERTY(int implicitHeight MEMBER implicitHeight NOTIFY implicitChanged FINAL)
    Q_PROPERTY(int paintedWidth MEMBER paintedWidth NOTIFY paintedChanged FINAL)
    Q_PROPERTY(int paintedHeight MEMBER paintedHeight NOTIFY paintedChanged FINAL)
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

    // 获取 url 图片宽高
    static QSize urlSize(const QUrl &url);
    // url 转 string，判断是否为 qrc 资源路径
    static QString urlToLocalFileOrQrc(const QUrl& url);
    // 找 x 倍路径
    static QString findAtNxFile(const QString &baseFileName, qreal targetDevicePixelRatio, qreal *sourceDevicePixelRatio);

signals:
    void sourceChanged();
    void pathChanged();
    void devicePixelRatioChanged();
    void implicitChanged();
    void paintedChanged();

private:
    // 更新 source 后重置图片宽高
    void updateImplicit();
    // 更新比例后更新对应 x 倍路径
    void updatePainted();

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
    // path 图片宽高
    int paintedWidth{ 0 };
    int paintedHeight{ 0 };
};
