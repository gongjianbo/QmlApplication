#include "BasicWindowTool.h"
#include <QGuiApplication>
#include <QOperatingSystemVersion>
#include <QScreen>
#include <QMouseEvent>
#include <QQuickItem>
#include <QtGlobal>
// gui-private
#include <qpa/qplatformintegration.h>
#include <cmath>

#if defined(Q_OS_WIN32)
#include <Windows.h>
#pragma comment(lib, "User32.lib")
#endif

BasicWindowTool::BasicWindowTool(QObject *parent)
    : QObject{parent}
{

}

QQuickWindow *BasicWindowTool::getWindow()
{
    return window;
}

void BasicWindowTool::setWindow(QQuickWindow *win)
{
    if (window == win) {
        return;
    }
    if (window) {
        window->disconnect(this);
        window->removeEventFilter(this);
    }
    window = win;
    if (window) {
        connect(window, &QWindow::screenChanged, this, &BasicWindowTool::onScreenChange, Qt::QueuedConnection);
        window->installEventFilter(this);
        onScreenChange(window->screen());
    }
    emit windowChanged();
}

qreal BasicWindowTool::getDevicePixelRatio() const
{
    return devicePixelRatio;
}

void BasicWindowTool::setDevicePixelRatio(qreal ratio)
{
    if (qFuzzyCompare(devicePixelRatio, ratio)) {
        return;
    }
    devicePixelRatio = ratio;
    emit devicePixelRatioChanged();
}

void BasicWindowTool::initWindow(int initWidth, int initHeight, bool sizeAdaptive)
{
    if (!window) {
        return;
    }
    int width = initWidth;
    int height = initHeight;
    QScreen *screen = windowDefaultScreen(window);
    if (!screen) {
        window->setWidth(width);
        window->setHeight(height);
        return;
    }
    QRectF area = screen->availableGeometry();
    qreal ratio = screenDevicePixelRatio(screen);
    if (sizeAdaptive) {
        // 更宽则按照高度适应，更高则按照宽度适应
        if (area.width() / area.height() > 1920 / 1080) {
            width = std::floor(initWidth / 1080 * area.height());
            height = std::floor(initHeight / 1080 * area.height());
        } else {
            width = std::floor(initWidth / 1920 * area.width());
            height = std::floor(initHeight / 1920 * area.width());
        }
    } else {
        // TODO initWidth/Height = 0 则根据内容计算宽高
        width = std::floor(initWidth * ratio);
        height = std::floor(initHeight * ratio);
    }
    if (width > std::floor(area.width() - 1)) {
        width = std::floor(area.width() - 1);
    }
    if (height > std::floor(area.height() - 1)) {
        height = std::floor(area.height() - 1);
    }
    // 先create创建窗口后就不会屏幕上往上偏移了
    window->create();
    window->setWidth(width);
    window->setHeight(height);
    calcRatio();
    moveToCenter();
}

void BasicWindowTool::moveToCenter(QWindow *target)
{
    if (!window) {
        return;
    }
    QScreen *screen = nullptr;
    if (target) {
        // 目标窗口的屏幕
        screen = target->screen();
    } else {
        screen = windowDefaultScreen(window);
    }
    if (screen) {
        // 根据屏幕 rect 计算窗口居中位置
        QRect rc(0, 0, window->width(), window->height());
        auto &&available = screen->availableGeometry();
        rc.moveCenter(available.center());
        // qDebug()<<rc.y()<<available.top()<<rc<<available<<frameMargins()<<screen;
        window->setGeometry(rc);
    }
}

QScreen *BasicWindowTool::windowDefaultScreen(QWindow *win)
{
    QScreen *screen = nullptr;
    if (win && win->transientParent()) {
        // 父窗口的屏幕
        screen = win->transientParent()->screen();
    } else if (qApp->focusWindow()) {
        // 焦点窗口的屏幕
        screen = qApp->focusWindow()->screen();
    } else {
        // 当前窗口默认屏幕
        screen = qApp->screenAt(QCursor::pos());
    }
    if (!screen) {
        // 主屏幕
        screen = qApp->primaryScreen();
    }
    return screen;
}

qreal BasicWindowTool::screenDevicePixelRatio(QScreen *screen)
{
    if (!screen)
        return 1.0;
    // 逻辑 dpi (logicalBaseDpi().first) 默认值 win 96/ mac 72
    const QDpi base_dpi = screen->handle()->logicalBaseDpi();
    const QDpi logic_dpi = QPlatformScreen::overrideDpi(screen->handle()->logicalDpi());
    const qreal ratio = qreal(logic_dpi.first) / qreal(base_dpi.first);
    // qDebug()<<__FUNCTION__<<ratio;
    return ratio;
}

QPoint BasicWindowTool::pos()
{
    return QCursor::pos();
}

void BasicWindowTool::setOverrideCursor(Qt::CursorShape shape)
{
    QGuiApplication::setOverrideCursor(QCursor(shape));
}

void BasicWindowTool::restoreOverrideCursor()
{
    QGuiApplication::restoreOverrideCursor();
}

bool BasicWindowTool::eventFilter(QObject *watched, QEvent *event)
{
    if (!window || watched != window) {
        return false;
    }
    if (event->type() == QEvent::MouseButtonPress) {
        // 点击空白处后编辑框等需要去掉焦点
        QMouseEvent *me = static_cast<QMouseEvent *>(event);
        // 点 Popup 或者有 ToolTip 的时候是不会进这里的
        // 如果过滤 qApp 的事件，直接 setFocus 会导致其他问题，比如下拉框焦点
        auto &&item = window->activeFocusItem();
        // contains 判断是否点击的当前焦点组件
        // 但是没考虑重合的情况
        if (item && item != window->contentItem() && !item->contains(item->mapFromScene(me->pos()))) {
            // 非当前组件就把前一个焦点去掉，点击空白处就能隐藏编辑框光标
            // 只设置 focus 不会影响 FocusScope 的 activeFocus 状态
            item->setFocus(false);
        }
    }
    return false;
}

void BasicWindowTool::onScreenChange(QScreen *screen)
{
    if (logicalRatioConnection) {
        disconnect(physicalRatioConnection);
        disconnect(logicalRatioConnection);
    }
    if (screen) {
        physicalRatioConnection = connect(screen, &QScreen::physicalDotsPerInchChanged, this, &BasicWindowTool::calcRatio);
        logicalRatioConnection = connect(screen, &QScreen::logicalDotsPerInchChanged, this, &BasicWindowTool::calcRatio);
        calcRatio();
    }
}

void BasicWindowTool::calcRatio()
{
    if (!window || !window->screen())
        return;
    setDevicePixelRatio(screenDevicePixelRatio(window->screen()));
}
