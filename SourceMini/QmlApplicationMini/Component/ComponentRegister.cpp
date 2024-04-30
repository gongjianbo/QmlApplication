#include "ComponentRegister.h"
#include <QCoreApplication>
#include <QQmlEngine>
#include <QQmlContext>
#include <QUrl>
#include "BasicWindowTool.h"
#include "BasicImageTool.h"
#include "CppImage.h"

void Component::registerQml(QQmlEngine */*engine*/)
{
    qmlRegisterType<BasicWindowTool>("Cute.Component", 1, 0, "BasicWindowTool");
    qmlRegisterType<BasicImageTool>("Cute.Component", 1, 0, "BasicImageTool");
    qmlRegisterType<CppImage>("Cute.Component", 1, 0, "CppImage");
}
