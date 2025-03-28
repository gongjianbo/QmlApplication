#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QOperatingSystemVersion>
#include <QUrl>
#include <QFont>
#include <QWKQuick/qwkquickglobal.h>
#include "BasicWindowTool.h"

int main(int argc, char *argv[])
{
    qputenv("QML2_IMPORT_PATH", "");
#if defined(Q_OS_WIN32)
    if (QOperatingSystemVersion::current().majorVersion() <= 7) {
        qputenv("QT_ANGLE_PLATFORM", "d3d9");
    }
    QCoreApplication::setAttribute(Qt::AA_UseOpenGLES);
#endif
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
    QCoreApplication::setAttribute(Qt::AA_DisableHighDpiScaling);
    // QQuickWindow::setTextRenderType(QQuickWindow::NativeTextRendering);
    // Make sure alpha channel is requested, QWindowKit special effects on Windows depends on it.
    QQuickWindow::setDefaultAlphaBuffer(true);

    QApplication app(argc, argv);

    QFont font;
#if defined(Q_OS_WIN32)
    font.setFamily("Microsoft YaHei");
#elif defined(Q_OS_MACOS)
    font.setFamily("PingFang SC");
#endif
    font.setPixelSize(12);
    app.setFont(font);

    qmlRegisterType<BasicWindowTool>("GongJianBo", 1, 0, "BasicWindowTool");

    QQmlApplicationEngine engine;
    QWK::registerTypes(&engine);
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
