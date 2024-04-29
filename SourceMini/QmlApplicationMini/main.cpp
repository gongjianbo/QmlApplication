#include <QApplication>
#include <QOperatingSystemVersion>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QFont>
#include <QDebug>
#include "ComponentRegister.h"

int main(int argc, char *argv[])
{
    qputenv("QML2_IMPORT_PATH", "");
#if defined(Q_OS_WIN32)
    if (QOperatingSystemVersion::current().majorVersion() <= 7) {
        // 部分 Win7 ES 渲染有问题
        qputenv("QT_ANGLE_PLATFORM", "d3d9");
    }
    // ES 在低配置设备渲染问题比 Desktop 少一点
    QCoreApplication::setAttribute(Qt::AA_UseOpenGLES);
#endif
    // 关闭 Qt 缩放，手动给组件乘上缩放比例
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_DisableHighDpiScaling);
#else
    qputenv("QT_ENABLE_HIGHDPI_SCALING", "0");
#endif
    // 启用 Qt 自带缩放适配：EnableHighDpiScaling + PassThrough
    // QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    // QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
    QCoreApplication::setOrganizationName("GongJianBo");
    QCoreApplication::setOrganizationDomain("xxx.com");
    // QCoreApplication::setApplicationVersion("1.02.03.00");
    // QCoreApplication::setApplicationName("Qml Application Mini");

    // 文字渲染设置成 native，更接近平台默认效果
    QQuickWindow::setTextRenderType(QQuickWindow::NativeTextRendering);

    QApplication app(argc, argv);

    // 设置全局字体
    QFont font = app.font();
    font.setFamily("Microsoft YaHei");
    app.setFont(font);

    QQmlApplicationEngine engine;

    // 注册自定义组件
    Component::registerQml(&engine);

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
