#include "InventoryManager.h"  // Fixed: match actual filename casing
#include <QFile>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QDateTime>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>
#include <QNetworkCookieJar>

// ── Constructor ──────────────────────────────────────────────────────────────

InventoryManager::InventoryManager(QObject *parent)
    : QObject(parent), m_totalRevenue(0.0)
{
    m_networkManager = new QNetworkAccessManager(this);
    m_networkManager->setCookieJar(new QNetworkCookieJar(this));
    initDatabase();
    loadData(); // Load initial state from DB
}

void InventoryManager::initDatabase()
{
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName("agromart.db");

    if (!m_db.open()) {
        qDebug() << "Error: Connection with database failed" << m_db.lastError().text();
        return;
    }

    QSqlQuery query;
    
    // 1. Products table
    query.exec("CREATE TABLE IF NOT EXISTS products ("
               "id INTEGER PRIMARY KEY AUTOINCREMENT, "
               "name TEXT UNIQUE, "
               "unit TEXT DEFAULT 'kg', "
               "cost REAL DEFAULT 0.0, "
               "price REAL, "
               "stock REAL DEFAULT 0.0, "
               "image_path TEXT)");

    // 2. Customers table
    query.exec("CREATE TABLE IF NOT EXISTS customers ("
               "id INTEGER PRIMARY KEY AUTOINCREMENT, "
               "name TEXT, "
               "phone TEXT UNIQUE, "
               "password TEXT DEFAULT '1234', "
               "role TEXT DEFAULT 'customer', "
               "total_spent REAL DEFAULT 0.0, "
               "loyalty_points INTEGER DEFAULT 0)");

    // 3. Sales table
    query.exec("CREATE TABLE IF NOT EXISTS sales ("
               "id INTEGER PRIMARY KEY AUTOINCREMENT, "
               "customer_id INTEGER DEFAULT 0, "
               "items TEXT, "
               "total REAL, "
               "profit REAL DEFAULT 0.0, "
               "date TEXT)");

    // 4. Sale Items table
    query.exec("CREATE TABLE IF NOT EXISTS sale_items ("
               "id INTEGER PRIMARY KEY AUTOINCREMENT, "
               "sale_id INTEGER, "
               "product_name TEXT, "
               "quantity REAL, "
               "price REAL, "
               "cost REAL, "
               "FOREIGN KEY(sale_id) REFERENCES sales(id))");

    // 5. Waste Logs table (Shrinkage)
    query.exec("CREATE TABLE IF NOT EXISTS waste_logs ("
               "id INTEGER PRIMARY KEY AUTOINCREMENT, "
               "product_name TEXT, "
               "quantity REAL, "
               "reason TEXT, "
               "date TEXT)");

    // 6. Users table (Staff Management)
    query.exec("CREATE TABLE IF NOT EXISTS users ("
               "id INTEGER PRIMARY KEY AUTOINCREMENT, "
               "name TEXT, "
               "username TEXT UNIQUE, "
               "password TEXT DEFAULT '1234', "
               "role TEXT)");

    // 7. Market Prices table
    query.exec("CREATE TABLE IF NOT EXISTS market_prices ("
               "id INTEGER PRIMARY KEY AUTOINCREMENT, "
               "name TEXT UNIQUE, "
               "unit TEXT, "
               "min_price TEXT, "
               "max_price TEXT, "
               "avg_price TEXT)");

    // Insert default users if table is empty
    query.exec("SELECT COUNT(*) FROM users");
    if (query.next() && query.value(0).toInt() == 0) {
        query.exec("INSERT INTO users (name, username, password, role) VALUES ('Admin User', 'admin', '1234', 'admin')");
        query.exec("INSERT INTO users (name, username, password, role) VALUES ('Head Cashier', 'cashier', '1234', 'cashier')");
    }

    // Graceful migrations for existing databases from previous steps
    query.exec("ALTER TABLE products ADD COLUMN unit TEXT DEFAULT 'kg'");
    query.exec("ALTER TABLE customers ADD COLUMN total_spent REAL DEFAULT 0.0");
    query.exec("ALTER TABLE customers ADD COLUMN loyalty_points INTEGER DEFAULT 0");
    query.exec("ALTER TABLE sales ADD COLUMN customer_id INTEGER DEFAULT 0");

    // Fix old relative image paths from before the absolute path update
    QString absolutePrefix = QDir::current().absolutePath() + "/";
    query.prepare("UPDATE products SET image_path = ? || image_path WHERE image_path LIKE 'images/%'");
    query.addBindValue(absolutePrefix);
    query.exec();

    // Ensure directories exist
    QDir dir;
    if (!dir.exists("images")) dir.mkpath("images");
    if (!dir.exists("AgroMart_Bills")) dir.mkpath("AgroMart_Bills");
}

void InventoryManager::loadData()
{
    QSqlQuery query;

    // 1. Load Inventory
    m_inventory.clear();
    if (query.exec("SELECT name, unit, cost, price, stock, image_path FROM products")) {
        while (query.next()) {
            QVariantMap item;
            item["name"]       = query.value(0).toString();
            item["unit"]       = query.value(1).toString();
            item["cost"]       = query.value(2).toDouble();
            item["price"]      = query.value(3).toDouble();
            item["stock"]      = query.value(4).toDouble();
            item["image_path"] = query.value(5).toString();
            m_inventory.append(item);
        }
    }
    emit inventoryChanged();

    // 1.5 Load Users
    m_users.clear();
    if (query.exec("SELECT id, name, username, password, role FROM users")) {
        while (query.next()) {
            QVariantMap item;
            item["id"]       = query.value(0).toInt();
            item["name"]     = query.value(1).toString();
            item["username"] = query.value(2).toString();
            item["password"] = query.value(3).toString();
            item["role"]     = query.value(4).toString();
            m_users.append(item);
        }
    }
    emit usersChanged();

    // 2. Load Customers
    m_customers.clear();
    if (query.exec("SELECT id, name, phone, password, role, total_spent, loyalty_points FROM customers")) {
        while (query.next()) {
            QVariantMap item;
            item["id"]            = query.value(0).toInt();
            item["name"]          = query.value(1).toString();
            item["phone"]         = query.value(2).toString();
            item["password"]      = query.value(3).toString();
            item["role"]          = query.value(4).toString();
            item["total_spent"]    = query.value(5).toDouble();
            item["loyalty_points"] = query.value(6).toInt();
            m_customers.append(item);
        }
    }
    emit customersChanged();

    // 2.5 Load Market Prices
    m_marketPrices.clear();
    if (query.exec("SELECT name, unit, min_price, max_price, avg_price FROM market_prices")) {
        while (query.next()) {
            QVariantMap item;
            item["name"]      = query.value(0).toString();
            item["unit"]      = query.value(1).toString();
            
            // Clean price strings and convert to standard numbers for QML
            QString minStr = query.value(2).toString();
            QString maxStr = query.value(3).toString();
            QString avgStr = query.value(4).toString();
            
            QString nepaliDigits = "०१२३४५६७८९";
            QString englishDigits = "0123456789";
            for (int i = 0; i < 10; ++i) {
                minStr.replace(nepaliDigits.at(i), englishDigits.at(i));
                maxStr.replace(nepaliDigits.at(i), englishDigits.at(i));
                avgStr.replace(nepaliDigits.at(i), englishDigits.at(i));
            }
            minStr.remove(QRegularExpression("[^0-9.]"));
            maxStr.remove(QRegularExpression("[^0-9.]"));
            avgStr.remove(QRegularExpression("[^0-9.]"));
            
            item["min_price"] = minStr.toDouble();
            item["max_price"] = maxStr.toDouble();
            item["avg_price"] = avgStr.toDouble();
            m_marketPrices.append(item);
        }
    }
    emit marketPricesChanged();

    // 3. Load Sales History
    m_salesHistory.clear();
    if (query.exec("SELECT id, items, total, profit, date FROM sales ORDER BY id DESC")) {
        while (query.next()) {
            QVariantMap item;
            item["id"]     = query.value(0).toInt();
            item["items"]  = query.value(1).toString();
            item["total"]  = query.value(2).toDouble();
            item["profit"] = query.value(3).toDouble();
            item["date"]   = query.value(4).toString();
            m_salesHistory.append(item);
        }
    }
    emit historyChanged();
}

// ── Property: totalRevenue ────────────────────────────────────────────────────

double InventoryManager::totalRevenue() const
{
    QSqlQuery query("SELECT SUM(total) FROM sales");
    if (query.next()) {
        return query.value(0).toDouble();
    }
    return 0.0;
}

// ── Customer Management ───────────────────────────────────────────────────────

void InventoryManager::addCustomer(QString name, QString phone)
{
    if (name.isEmpty() || phone.isEmpty()) return;

    QSqlQuery query;
    query.prepare("INSERT INTO customers (name, phone) VALUES (?, ?)");
    query.addBindValue(name);
    query.addBindValue(phone);

    if (query.exec()) {
        loadData(); // Refresh list
    } else {
        qDebug() << "SQL Error (addCustomer):" << query.lastError().text();
    }
}

void InventoryManager::removeCustomer(int index)
{
    if (index >= 0 && index < m_customers.size()) {
        QString phone = m_customers[index].toMap()["phone"].toString();
        QSqlQuery query;
        query.prepare("DELETE FROM customers WHERE phone = ?");
        query.addBindValue(phone);
        if (query.exec()) loadData();
    }
}

void InventoryManager::editCustomerName(int index, QString newName)
{
    if (index >= 0 && index < m_customers.size() && !newName.isEmpty()) {
        QString phone = m_customers[index].toMap()["phone"].toString();
        QSqlQuery query;
        query.prepare("UPDATE customers SET name = ? WHERE phone = ?");
        query.addBindValue(newName);
        query.addBindValue(phone);
        if (query.exec()) loadData();
    }
}

void InventoryManager::resetCustomerPassword(int index, QString newPass)
{
    if (index >= 0 && index < m_customers.size()) {
        QString phone = m_customers[index].toMap()["phone"].toString();
        QSqlQuery query;
        query.prepare("UPDATE customers SET password = ? WHERE phone = ?");
        query.addBindValue(newPass.isEmpty() ? "1234" : newPass);
        query.addBindValue(phone);
        if (query.exec()) loadData();
    }
}

// ── User Management (Staff) ───────────────────────────────────────────────────

void InventoryManager::addUser(QString name, QString username, QString role)
{
    if (name.isEmpty() || username.isEmpty() || role.isEmpty()) return;

    QSqlQuery query;
    query.prepare("INSERT INTO users (name, username, role) VALUES (?, ?, ?)");
    query.addBindValue(name);
    query.addBindValue(username);
    query.addBindValue(role);

    if (query.exec()) {
        loadData();
    } else {
        qDebug() << "SQL Error (addUser):" << query.lastError().text();
    }
}

void InventoryManager::removeUser(int index)
{
    if (index >= 0 && index < m_users.size()) {
        QString username = m_users[index].toMap()["username"].toString();
        QSqlQuery query;
        query.prepare("DELETE FROM users WHERE username = ?");
        query.addBindValue(username);
        if (query.exec()) loadData();
    }
}

void InventoryManager::resetUserPassword(int index, QString newPass)
{
    if (index >= 0 && index < m_users.size()) {
        QString username = m_users[index].toMap()["username"].toString();
        QSqlQuery query;
        query.prepare("UPDATE users SET password = ? WHERE username = ?");
        query.addBindValue(newPass.isEmpty() ? "1234" : newPass);
        query.addBindValue(username);
        if (query.exec()) loadData();
    }
}

// ── Inventory Management ──────────────────────────────────────────────────────

void InventoryManager::addVegetable(QString name, QString unit, double cost, double price, double stock, QString imagePath)
{
    if (name.isEmpty()) return;

    QString localImage = copyImageToLocal(imagePath);

    QSqlQuery query;
    query.prepare("INSERT INTO products (name, unit, cost, price, stock, image_path) VALUES (?, ?, ?, ?, ?, ?)");
    query.addBindValue(name);
    query.addBindValue(unit);
    query.addBindValue(cost);
    query.addBindValue(price);
    query.addBindValue(stock);
    query.addBindValue(localImage);

    if (query.exec()) {
        loadData();
    } else {
        qDebug() << "SQL Error (addVegetable):" << query.lastError().text();
    }
}

void InventoryManager::removeVegetable(int index)
{
    if (index >= 0 && index < m_inventory.size()) {
        QString name = m_inventory[index].toMap()["name"].toString();
        QSqlQuery query;
        query.prepare("DELETE FROM products WHERE name = ?");
        query.addBindValue(name);
        if (query.exec()) loadData();
    }
}

void InventoryManager::updateStock(int index, double newStock)
{
    if (index >= 0 && index < m_inventory.size()) {
        QString name = m_inventory[index].toMap()["name"].toString();
        QSqlQuery query;
        query.prepare("UPDATE products SET stock = ? WHERE name = ?");
        query.addBindValue(qMax(0.0, newStock));
        query.addBindValue(name);
        if (query.exec()) loadData();
    }
}

void InventoryManager::decrementStock(QString itemName, double quantity)
{
    QSqlQuery query;
    query.prepare("UPDATE products SET stock = stock - ? WHERE name = ? AND stock >= ?");
    query.addBindValue(quantity);
    query.addBindValue(itemName);
    query.addBindValue(quantity);
    if (query.exec()) loadData();
}

void InventoryManager::logWaste(QString productName, double quantity, QString reason)
{
    QSqlQuery query;
    query.prepare("INSERT INTO waste_logs (product_name, quantity, reason, date) VALUES (?, ?, ?, ?)");
    query.addBindValue(productName);
    query.addBindValue(quantity);
    query.addBindValue(reason);
    query.addBindValue(QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm"));
    
    if (query.exec()) {
        // Also deduct from inventory
        decrementStock(productName, quantity);
        loadData();
    }
}

// ── Sales & History ───────────────────────────────────────────────────────────

int InventoryManager::processSale(QVariantList cartItems, double total, int customerId)
{
    m_db.transaction();

    double totalProfit = 0.0;
    QString itemsSummary;

    // First insert the sale to get its ID
    QSqlQuery saleQuery;
    saleQuery.prepare("INSERT INTO sales (customer_id, items, total, profit, date) VALUES (?, ?, ?, ?, ?)");
    saleQuery.addBindValue(customerId);
    saleQuery.addBindValue(""); // Will update later
    saleQuery.addBindValue(total);
    saleQuery.addBindValue(0.0); // Will update later
    saleQuery.addBindValue(QDateTime::currentDateTime().toString("yyyy-MM-dd HH:mm"));
    
    if (!saleQuery.exec()) {
        m_db.rollback();
        return -1;
    }
    
    int saleId = saleQuery.lastInsertId().toInt();

    // Process each item
    for (const QVariant &v : cartItems) {
        QVariantMap item = v.toMap();
        QString name = item["name"].toString();
        double qty = item["qty"].toDouble(); // Support weights
        double price = item["price"].toDouble();
        
        // Get cost from products table
        double cost = 0.0;
        QSqlQuery costQuery;
        costQuery.prepare("SELECT cost FROM products WHERE name = ?");
        costQuery.addBindValue(name);
        if (costQuery.exec() && costQuery.next()) {
            cost = costQuery.value(0).toDouble();
        }

        double itemProfit = (price - cost) * qty;
        totalProfit += itemProfit;
        itemsSummary += QString::number(qty) + "x " + name + " ";

        // Insert sale_item
        QSqlQuery itemQuery;
        itemQuery.prepare("INSERT INTO sale_items (sale_id, product_name, quantity, price, cost) VALUES (?, ?, ?, ?, ?)");
        itemQuery.addBindValue(saleId);
        itemQuery.addBindValue(name);
        itemQuery.addBindValue(qty);
        itemQuery.addBindValue(price);
        itemQuery.addBindValue(cost);
        itemQuery.exec();
    }

    // Update the sale with summary and profit
    QSqlQuery updateQuery;
    updateQuery.prepare("UPDATE sales SET items = ?, profit = ? WHERE id = ?");
    updateQuery.addBindValue(itemsSummary.trimmed());
    updateQuery.addBindValue(totalProfit);
    updateQuery.addBindValue(saleId);
    updateQuery.exec();

    // Loyalty Points Logic: 1 point for every 10 Rs spent
    if (customerId > 0) {
        int pointsGained = qFloor(total / 10.0);
        QSqlQuery loyaltyQuery;
        loyaltyQuery.prepare("UPDATE customers SET total_spent = total_spent + ?, loyalty_points = loyalty_points + ? WHERE id = ?");
        loyaltyQuery.addBindValue(total);
        loyaltyQuery.addBindValue(pointsGained);
        loyaltyQuery.addBindValue(customerId);
        loyaltyQuery.exec();
    }

    m_db.commit();
    loadData();
    return saleId;
}

void InventoryManager::clearHistory()
{
    QSqlQuery query("DELETE FROM sales");
    if (query.exec()) loadData();
}

QString InventoryManager::getTopSellingProduct()
{
    // A more accurate top selling product calculation using SQL
    QSqlQuery query("SELECT items FROM sales");
    QMap<QString, int> counts;
    while (query.next()) {
        QString items = query.value(0).toString();
        // Simple heuristic: look for "Name" in "Qtyx Name"
        QStringList parts = items.split(" ");
        for (int i = 1; i < parts.size(); i += 2) {
            counts[parts[i]]++;
        }
    }

    QString top;
    int max = 0;
    for (auto it = counts.begin(); it != counts.end(); ++it) {
        if (it.value() > max) {
            max = it.value();
            top = it.key();
        }
    }
    return top.isEmpty() ? "None" : top;
}

QVariantList InventoryManager::getCustomerHistory(int customerId)
{
    QVariantList list;
    QSqlQuery query;
    query.prepare("SELECT date, items, total FROM sales WHERE customer_id = ? ORDER BY id DESC LIMIT 5");
    query.addBindValue(customerId);
    
    if (query.exec()) {
        while (query.next()) {
            QVariantMap map;
            map["date"] = query.value(0).toString();
            map["items"] = query.value(1).toString();
            map["total"] = query.value(2).toDouble();
            list.append(map);
        }
    }
    return list;
}

// ── Authentication ────────────────────────────────────────────────────────────

QString InventoryManager::authenticate(const QString &email, const QString &password)
{
    QSqlQuery query;
    query.prepare("SELECT role FROM users WHERE username = ? AND password = ?");
    query.addBindValue(email);
    query.addBindValue(password);
    
    if (query.exec() && query.next()) {
        QString role = query.value(0).toString();
        // Map staff roles to UI navigation
        // If role is 'admin', they see the admin dashboard ("salesman"). 
        // If 'cashier', they see the POS view ("customer").
        if (role == "admin") return "salesman";
        if (role == "cashier") return "customer";
        return role;
    }
    return ""; 
}

// ── Advanced Features ─────────────────────────────────────────────────────────

QString InventoryManager::generateBillPDF(int saleId)
{
    QSqlQuery query;
    query.prepare("SELECT total, date, items FROM sales WHERE id = ?");
    query.addBindValue(saleId);
    if (!query.exec() || !query.next()) return "Sale not found";

    QString dateStr = query.value(1).toString();
    double total = query.value(0).toDouble();
    QString items = query.value(2).toString();

    QString safeDate = dateStr;
    safeDate.replace(":", "-").replace(" ", "_");
    QString filename = QDir::currentPath() + "/AgroMart_Bills/Bill_" + QString::number(saleId) + "_" + safeDate + ".pdf";

    QPdfWriter writer(filename);
    writer.setPageSize(QPageSize(QPageSize::A5));
    writer.setResolution(300);

    QPainter painter(&writer);
    painter.setFont(QFont("Arial", 20, QFont::Bold));
    painter.drawText(100, 500, "AgroMart Official Bill");

    painter.setFont(QFont("Arial", 12));
    painter.drawText(100, 1000, "Receipt #: " + QString::number(saleId));
    painter.drawText(100, 1300, "Date: " + dateStr);

    painter.drawLine(100, 1500, 4000, 1500);

    painter.setFont(QFont("Arial", 14, QFont::Bold));
    painter.drawText(100, 1800, "Items Purchased:");
    
    painter.setFont(QFont("Arial", 12));
    QStringList lines = items.split(" ", Qt::SkipEmptyParts);
    int y = 2200;
    for (int i = 0; i < lines.size(); i += 2) {
        if (i+1 < lines.size()) {
            painter.drawText(100, y, lines[i] + " " + lines[i+1]);
            y += 300;
        }
    }

    painter.drawLine(100, y, 4000, y);
    painter.setFont(QFont("Arial", 16, QFont::Bold));
    painter.drawText(100, y + 400, "Total: $" + QString::number(total, 'f', 2));

    painter.end();
    return "Saved: " + filename;
}

QVariantList InventoryManager::getMonthlyRevenue()
{
    QVariantList list;
    // Format date from "yyyy-MM-dd HH:mm" to "yyyy-MM"
    QSqlQuery query("SELECT substr(date, 1, 7) as month, SUM(total) as revenue, SUM(profit) as profit FROM sales GROUP BY month ORDER BY month DESC");
    while (query.next()) {
        QVariantMap map;
        map["month"] = query.value(0).toString();
        map["revenue"] = query.value(1).toDouble();
        map["profit"] = query.value(2).toDouble();
        list.append(map);
    }
    return list;
}

QVariantMap InventoryManager::getProductPerformance(QString productName)
{
    QVariantMap map;
    map["name"] = productName;
    
    QSqlQuery query;
    query.prepare("SELECT SUM(quantity), SUM((price - cost) * quantity) FROM sale_items WHERE product_name = ?");
    query.addBindValue(productName);
    
    if (query.exec() && query.next()) {
        map["unitsSold"] = query.value(0).toInt();
        map["totalProfit"] = query.value(1).toDouble();
    } else {
        map["unitsSold"] = 0;
        map["totalProfit"] = 0.0;
    }
    
    // Get stock and cost from products table
    QSqlQuery prodQuery;
    prodQuery.prepare("SELECT stock, cost, price, image_path FROM products WHERE name = ?");
    prodQuery.addBindValue(productName);
    if (prodQuery.exec() && prodQuery.next()) {
        map["stock"] = prodQuery.value(0).toInt();
        map["cost"] = prodQuery.value(1).toDouble();
        map["price"] = prodQuery.value(2).toDouble();
        map["imagePath"] = prodQuery.value(3).toString();
    }
    
    return map;
}

QString InventoryManager::copyImageToLocal(QString sourcePath)
{
    if (sourcePath.isEmpty()) return "";

    // If it's a file URI from QML, clean it up
    if (sourcePath.startsWith("file:///")) {
        sourcePath = sourcePath.mid(8); // Windows
    } else if (sourcePath.startsWith("file://")) {
        sourcePath = sourcePath.mid(7); // Linux/Mac
    }

    QFileInfo info(sourcePath);
    QString fileName = QString::number(QDateTime::currentMSecsSinceEpoch()) + "_" + info.fileName();
    QString absoluteImagePath = QDir::current().absoluteFilePath("images/" + fileName);
    
    QDir dir("images");
    if (!dir.exists()) dir.mkpath(".");

    if (QFile::copy(sourcePath, absoluteImagePath)) {
        return absoluteImagePath;
    }
    return sourcePath; // Fallback to original if copy fails
}


// ── Kalimati Market Data Integration ────────────────────────────────────────

void InventoryManager::fetchMarketPrices()
{
    // First, hit the language switcher to set the session to English
    QNetworkRequest langReq(QUrl("https://kalimatimarket.gov.np/lang/en"));
    QNetworkReply *langReply = m_networkManager->get(langReq);
    
    connect(langReply, &QNetworkReply::finished, this, [this, langReply]() {
        langReply->deleteLater();
        
        // Then, fetch the actual prices using the new session cookie
        QNetworkRequest priceReq(QUrl("https://kalimatimarket.gov.np/price"));
        QNetworkReply *priceReply = m_networkManager->get(priceReq);
        connect(priceReply, &QNetworkReply::finished, this, [this, priceReply]() {
            onMarketPricesFetched(priceReply);
        });
    });
}

void InventoryManager::onMarketPricesFetched(QNetworkReply *reply)
{
    if (reply->error() == QNetworkReply::NoError) {
        QString html = QString::fromUtf8(reply->readAll());
        
        // Extract the table rows using a robust string approach
        int tableStart = html.indexOf("id=\"commodityPriceParticular\"");
        if (tableStart != -1) {
            int tbodyStart = html.indexOf("<tbody>", tableStart);
            int tbodyEnd = html.indexOf("</tbody>", tbodyStart);
            
            if (tbodyStart != -1 && tbodyEnd != -1) {
                QString tbodyHtml = html.mid(tbodyStart, tbodyEnd - tbodyStart);
                
                m_db.transaction();
                // Clear old prices
                QSqlQuery("DELETE FROM market_prices").exec();
                
                QSqlQuery insertQuery;
                insertQuery.prepare("INSERT INTO market_prices (name, unit, min_price, max_price, avg_price) "
                                    "VALUES (?, ?, ?, ?, ?)");
                
                int rowStart = 0;
                while ((rowStart = tbodyHtml.indexOf("<tr>", rowStart)) != -1) {
                    int rowEnd = tbodyHtml.indexOf("</tr>", rowStart);
                    if (rowEnd == -1) break;
                    
                    QString rowHtml = tbodyHtml.mid(rowStart, rowEnd - rowStart);
                    
                    QStringList cells;
                    int tdStart = 0;
                    while ((tdStart = rowHtml.indexOf("<td>", tdStart)) != -1) {
                        int tdEnd = rowHtml.indexOf("</td>", tdStart);
                        if (tdEnd == -1) break;
                        QString cellText = rowHtml.mid(tdStart + 4, tdEnd - tdStart - 4).trimmed();
                        cells.append(cellText);
                        tdStart = tdEnd + 5;
                    }
                    
                    if (cells.size() >= 5) {
                        insertQuery.addBindValue(cells[0]); // name
                        insertQuery.addBindValue(cells[1]); // unit
                        insertQuery.addBindValue(cells[2]); // min_price
                        insertQuery.addBindValue(cells[3]); // max_price
                        insertQuery.addBindValue(cells[4]); // avg_price
                        insertQuery.exec();
                    }
                    
                    rowStart = rowEnd + 5;
                }
                m_db.commit();
                loadData(); // Reload UI list
            }
        }
    } else {
        qDebug() << "Failed to fetch market prices:" << reply->errorString();
    }
    reply->deleteLater();
}

void InventoryManager::syncInventoryPrices()
{
    m_db.transaction();
    QSqlQuery query("SELECT name, min_price, avg_price FROM market_prices");
    
    QSqlQuery updateQuery;
    updateQuery.prepare("UPDATE products SET cost = ?, price = ? WHERE name = ?");
    
    while (query.next()) {
        QString name = query.value(0).toString();
        
        // Clean price strings
        QString minStr = query.value(1).toString();
        QString avgStr = query.value(2).toString();
        
        // Convert Nepali numbers to standard digits
        QString nepaliDigits = "०१२३४५६७८९";
        QString englishDigits = "0123456789";
        for (int i = 0; i < 10; ++i) {
            minStr.replace(nepaliDigits.at(i), englishDigits.at(i));
            avgStr.replace(nepaliDigits.at(i), englishDigits.at(i));
        }
        
        minStr.remove(QRegularExpression("[^0-9.]"));
        avgStr.remove(QRegularExpression("[^0-9.]"));
        
        double minPrice = minStr.toDouble();
        double avgPrice = avgStr.toDouble();
        
        if (avgPrice > 0) {
            updateQuery.addBindValue(minPrice); // Cost is min price
            updateQuery.addBindValue(avgPrice); // Selling price is avg price
            updateQuery.addBindValue(name);
            updateQuery.exec();
        }
    }
    m_db.commit();
    loadData(); // Refresh UI inventory
}
