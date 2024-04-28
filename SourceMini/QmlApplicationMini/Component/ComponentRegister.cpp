#include "ComponentRegister.h"
#include <QCoreApplication>
#include <QQmlEngine>
#include <QQmlContext>
#include <QUrl>
#include "BasicWindowTool.h"

void Component::registerQml(QQmlEngine */*engine*/)
{
    qmlRegisterType<BasicWindowTool>("Cute.Component", 1, 0, "BasicWindowTool");
}
