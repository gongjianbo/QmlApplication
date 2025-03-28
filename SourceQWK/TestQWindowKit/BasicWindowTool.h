#pragma once
#include <QObject>
#include <QCursor>
#include <QQuickWindow>

/**
 * @brief 窗口工具类
 * @author 龚建波
 * @date 2025-03-28
 * @details
 * 1.每个窗口对应一个 BasicWindowTool，以处理多屏不同设置的情况
 */
class BasicWindowTool : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QQuickWindow *window READ getWindow WRITE setWindow NOTIFY windowChanged FINAL)
    Q_PROPERTY(qreal devicePixelRatio READ getDevicePixelRatio WRITE setDevicePixelRatio NOTIFY devicePixelRatioChanged FINAL)
public:
    explicit BasicWindowTool(QObject *parent = nullptr);

    // 关联的窗口对象
    QQuickWindow *getWindow();
    void setWindow(QQuickWindow *win);

    // 窗口所在屏幕的缩放比
    qreal getDevicePixelRatio() const;
    void setDevicePixelRatio(qreal ratio);

    // 初始化窗口位置和大小
    Q_INVOKABLE void initWindow(int initWidth, int initHeight, bool sizeAdaptive);
    // 窗口移动到屏幕中心，如果指定了 target 窗口，则移动到 target 所在屏幕中心
    Q_INVOKABLE void moveToCenter(QWindow *target = nullptr);

    // 获取win初始化所在屏幕
    Q_INVOKABLE static QScreen *windowDefaultScreen(QWindow *win);
    // 获取屏幕缩放比
    Q_INVOKABLE static qreal screenDevicePixelRatio(QScreen *screen);

    // 鼠标光标全局位置 QCursor::pos
    Q_INVOKABLE static QPoint pos();
    // 设置鼠标光标形状 QGuiApplication::setOverrideCursor
    Q_INVOKABLE static void setOverrideCursor(Qt::CursorShape shape);
    // 恢复鼠标光标形状 QGuiApplication::restoreOverrideCursor
    // setOverrideCursor 和 restoreOverrideCursor 需要配对使用
    Q_INVOKABLE static void restoreOverrideCursor();

signals:
    void windowChanged();
    void devicePixelRatioChanged();

protected:
    bool eventFilter(QObject *watched, QEvent *event) override;

private:
    // 切换屏幕
    void onScreenChange(QScreen *screen);
    // 计算屏幕缩放比
    void calcRatio();

private:
    // 关联的窗口对象
    QQuickWindow *window{ nullptr };
    // 窗口所在屏幕的缩放比
    qreal devicePixelRatio{ 1.0 };
    // 分辨率变化的信号槽
    QMetaObject::Connection physicalRatioConnection;
    QMetaObject::Connection logicalRatioConnection;
};
