// Developed by: Bigyan Bhaila, Ayush Prajapati and Rujan Shrestha
// 3rd Year Computer Science Students, Khwopa Engineering College
// Project: AgroMart - A Smart Inventory Management System for Vegetable Sellers


#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include "InventoryManager.h"  // Fixed: match actual filename casing

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Basic");

    // 1. Create the backend singleton exposed to QML
    InventoryManager inventory;

    QQmlApplicationEngine engine;

    // 2. Expose the backend to QML so all screens can access
    //    vegetableList, salesHistory, customerList, and all Q_INVOKABLE methods.
    engine.rootContext()->setContextProperty("inventoryManager", &inventory);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    // 3. Load the root QML file from the AgroMart module
    engine.loadFromModule("AgroMart", "Main");

    return app.exec();
}
