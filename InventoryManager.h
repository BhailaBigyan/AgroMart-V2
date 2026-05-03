#ifndef INVENTORYMANAGER_H
#define INVENTORYMANAGER_H

#include <QObject>
#include <QVariantList>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

#include <QPdfWriter>
#include <QPainter>
#include <QDir>
#include <QFile>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>

/**
 * @class InventoryManager
 * @brief Core backend for AgroMart POS system.
 *
 * Exposed to QML via rootContext as "inventoryManager".
 * Manages inventory, sales history, staff users, and customers.
 * All data is persisted to an SQLite database.
 */
class InventoryManager : public QObject
{
    Q_OBJECT

    // ── Properties exposed to QML ──────────────────────────────────────────
    Q_PROPERTY(QVariantList vegetableList READ vegetableList NOTIFY inventoryChanged)
    Q_PROPERTY(QVariantList salesHistory  READ salesHistory  NOTIFY historyChanged)
    Q_PROPERTY(QVariantList userList      READ userList      NOTIFY usersChanged)
    Q_PROPERTY(QVariantList customerList  READ customerList  NOTIFY customersChanged)
    Q_PROPERTY(QVariantList marketPrices  READ marketPrices  NOTIFY marketPricesChanged)
    Q_PROPERTY(double       totalRevenue  READ totalRevenue  NOTIFY historyChanged)

public:
    explicit InventoryManager(QObject *parent = nullptr);

    // ── Property Getters ───────────────────────────────────────────────────
    QVariantList vegetableList() const { return m_inventory; }
    QVariantList salesHistory()  const { return m_salesHistory; }
    QVariantList userList()      const { return m_users; }
    QVariantList customerList()  const { return m_customers; }
    QVariantList marketPrices()  const { return m_marketPrices; }
    double       totalRevenue()  const;

    // ── Inventory & Sales (callable from QML) ─────────────────────────────
    Q_INVOKABLE void    addVegetable(QString name, QString unit, double cost, double price, double stock, QString imagePath);
    Q_INVOKABLE void    removeVegetable(int index);
    Q_INVOKABLE void    updateStock(int index, double newStock);
    Q_INVOKABLE void    decrementStock(QString itemName, double quantity);
    Q_INVOKABLE void    logWaste(QString productName, double quantity, QString reason);

    
    // Updated to accept an array of items and a customer ID for loyalty points
    Q_INVOKABLE int     processSale(QVariantList cartItems, double total, int customerId = 0);
    Q_INVOKABLE void    clearHistory();
    Q_INVOKABLE QString getTopSellingProduct();
    Q_INVOKABLE QVariantList getCustomerHistory(int customerId);

    // ── Advanced Features ─────────────────────────────────────────────────
    Q_INVOKABLE QString generateBillPDF(int saleId);
    Q_INVOKABLE QVariantList getMonthlyRevenue();
    Q_INVOKABLE QVariantMap getProductPerformance(QString productName);
    Q_INVOKABLE QString copyImageToLocal(QString sourcePath);

    // ── Kalimati Market Data Integration ──────────────────────────────────
    Q_INVOKABLE void fetchMarketPrices();
    Q_INVOKABLE void syncInventoryPrices();

    // ══ Authentication ══════════════════════════════════════════════════
    /**
     * @brief Validates user credentials and returns the assigned role.
     * @return "salesman", "customer", or "" if invalid.
     */
    Q_INVOKABLE QString authenticate(const QString &email, const QString &password);

    // ── Customer & User Management (callable from QML) ────────────────────
    Q_INVOKABLE void    addCustomer(QString name, QString phone);
    Q_INVOKABLE void    removeCustomer(int index);
    Q_INVOKABLE void    editCustomerName(int index, QString newName);
    Q_INVOKABLE void    resetCustomerPassword(int index, QString newPass);

    Q_INVOKABLE void    addUser(QString name, QString username, QString role);
    Q_INVOKABLE void    removeUser(int index);
    Q_INVOKABLE void    resetUserPassword(int index, QString newPass);

signals:
    void inventoryChanged();
    void historyChanged();
    void usersChanged();
    void customersChanged();
    void marketPricesChanged();

private slots:
    void onMarketPricesFetched(QNetworkReply *reply);

private:
    void initDatabase();
    void loadData();
    QVariantList m_inventory;
    QVariantList m_salesHistory;
    QVariantList m_users;
    QVariantList m_customers;
    QVariantList m_marketPrices;
    double       m_totalRevenue;
    QSqlDatabase m_db;
    QNetworkAccessManager *m_networkManager;
};


#endif // INVENTORYMANAGER_H
