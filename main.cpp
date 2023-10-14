#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQuick>
#include "fileOperations.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    qmlRegisterType<FileOperations>("FileOperations", 1, 0, "FileOperations");
    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/Writeboard/Main.qml"_qs);
    engine.load(url);
    return app.exec();
}