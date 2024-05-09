#include "BasicWindowTool.h"
#include <QGuiApplication>
#include <QOperatingSystemVersion>
#include <QScreen>
#include <QMouseEvent>
#include <QQuickItem>
#include <QtGlobal>
#include <qpa/qplatformintegration.h>

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
    frameless = false;
    if (window) {
        frameless = !!(window->flags() & Qt::FramelessWindowHint);
        connect(window, &QWindow::windowStateChanged, this, &BasicWindowTool::onWindowStateChange, Qt::QueuedConnection);
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

void BasicWindowTool::showMax()
{
    if (!window) {
        return;
    }
    if (!frameless) {
        window->showMaximized();
        return;
    }
#if defined(Q_OS_WIN32)
    window->showMaximized();
    if (window->screen()) {
        // 无边框副屏的时候遮盖了任务栏，重置下显示区域
        // TODO 窗口状态或者屏幕状态等变化后需要重新判断，不然会再次覆盖任务栏
        auto &&rect = window->screen()->availableGeometry();
        ::SetWindowPos((HWND)window->winId(), HWND_TOP, rect.x(), rect.y(), rect.width(), rect.height(), SWP_SHOWWINDOW);
    }
#else
    window->showMaximized();
#endif
}

void BasicWindowTool::showMin()
{
    if (!window) {
        return;
    }
    if (!frameless) {
        window->showMaximized();
        return;
    }
#if defined(Q_OS_WIN32)
    // showMin 后部分条件下会显示不出来，改用 win api
    // 如：辅助屏点最大化按钮->任务栏最小化然后还原->点最小化按钮->点任务栏图标无法还原
    // 如果 win 也在这里 setFlag 仍然会有 bug
    ::ShowWindow((HWND)window->winId(), SW_SHOWMINIMIZED);
#elif defined(Q_OS_MACOS)
    // framless 时 macos 不能最小化
    window->setFlag(Qt::FramelessWindowHint, false);
    window->showMinimized();
#else
    window->showMinimized();
#endif
}

void BasicWindowTool::showNormal()
{
    if (!window) {
        return;
    }
    window->showNormal();
}

void BasicWindowTool::activeWindow()
{
    if (!window) {
        return;
    }
    window->requestActivate();
}

void BasicWindowTool::moveToCenter(QWindow *target)
{
    if (!window) {
        return;
    }
    QScreen *cur_screen = nullptr;
    if (target) {
        // 目标窗口的屏幕
        cur_screen = target->screen();
    } else if (window && window->transientParent()) {
        // 父窗口的屏幕
        cur_screen = window->transientParent()->screen();
    } else if (qApp->focusWindow()) {
        // 焦点窗口的屏幕
        cur_screen = qApp->focusWindow()->screen();
    } else {
        // 当前窗口默认屏幕
        cur_screen = window->screen();
    }
    if (!cur_screen) {
        // 主屏幕
        cur_screen = qApp->primaryScreen();
    }
    if (cur_screen) {
        // 根据屏幕 rect 计算窗口居中位置
        QRect rc(0, 0, window->width(), window->height());
        auto &&available = cur_screen->availableGeometry();
        rc.moveCenter(available.center());
        // qDebug()<<rc.y()<<available.top()<<rc<<available<<frameMargins()<<cur_screen;
        window->setGeometry(rc);
    }
}

qreal BasicWindowTool::windowDevicePixelRatio(QWindow *win)
{
    if (!win)
        return 1.0;
    QScreen *cur_screen = win->screen();
    // qDebug()<<__FUNCTION__<<cur_screen;
    if (cur_screen) {
        // 逻辑 dpi (logicalBaseDpi().first) 默认值 win 96/ mac 72
        const QDpi base_dpi = cur_screen->handle()->logicalBaseDpi();
        const QDpi logic_dpi = QPlatformScreen::overrideDpi(cur_screen->handle()->logicalDpi());
        const qreal ratio = qreal(logic_dpi.first) / qreal(base_dpi.first);
        // qDebug()<<__FUNCTION__<<ratio;
        return ratio;
    }
    return 1.0;
}

bool BasicWindowTool::enableTransparent()
{
#if defined(Q_OS_WIN32)
    if (QOperatingSystemVersion::current().majorVersion() <= 7) {
        // win7 可能不能正常显示透明
        return false;
    }
#endif
    return true;
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

void BasicWindowTool::classBegin()
{
    auto obj = parent();
    while (obj)
    {
        if (auto win = qobject_cast<QQuickWindow *>(obj))
        {
            // 此时窗口还没完成初始化，没法获取完整属性
            // 默认 show 之后才更新 screen，提前 create 更新 screen
            // 但是因为属性还没初始化，create 后窗口默认按 120 初始化，导致 show 时没居中
            // 所以 show 时重置下 rect
            win->create();
            // classBegin 调用了 create，导致颜色表达式绑定切换到 transparent 会呈黑色，值绑定则正常
            // classBegin 设置 transparent 会导致初始化被阻塞时渲染异常，所以放到 componentComplete 进行
            win->setColor(Qt::white);
            setWindow(win);
            break;
        }
        obj = obj->parent();
    }
}

void BasicWindowTool::componentComplete()
{
    if (!window) {
        return;
    }
    frameless = !!(window->flags() & Qt::FramelessWindowHint);
    // classBegin 设置 transparent 会导致初始化被阻塞时渲染异常，所以放到 componentComplete 进行
    if (frameless) {
        window->setColor(Qt::transparent);
    }
    // auto obj = parent();
    // while (obj)
    // {
    //     if (obj->inherits("QQuickRootItem"))
    //     {
    //         if (auto root = qobject_cast<QQuickItem *>(obj))
    //         {
    //             if (auto win = root->window() && win->screen())
    //             {
    //             }
    //             break;
    //         }
    //     }
    //     obj = obj->parent();
    // }
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
    setDevicePixelRatio(windowDevicePixelRatio(window));
}

void BasicWindowTool::onWindowStateChange(Qt::WindowState windowState)
{
    if (!(windowState & Qt::WindowMinimized)) {
        return;
    }
    if (!frameless) {
        return;
    }
#if defined(Q_OS_WIN32)
#elif defined(Q_OS_MACOS)
    // 从任务栏弹出的时候又去掉边框
    window->setFlag(Qt::FramelessWindowHint, true);
#else
#endif
}
