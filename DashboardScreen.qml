import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: dashboardRoot
    color: "#F0F4F0"

    property string userRole: "salesman"
    property string activeTab: userRole === "salesman" ? "Products" : "Store"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        SidebarNavigation {
            id: sidebar
            visible: userRole === "salesman"
            activeTab: dashboardRoot.activeTab
            onTabChanged: (tabName) => { dashboardRoot.activeTab = tabName }
            onLogoutRequested: { loader.pop() }
        }

        StackLayout {
            currentIndex: {
                if (userRole === "customer") return 6;
                if (activeTab === "ProductProfile") return 7;
                return ["Products", "Live Prices", "Users", "Customers", "Reports", "History"].indexOf(activeTab);
            }
            Layout.fillWidth: true
            Layout.fillHeight: true

            ProductManagementTab {
                onViewProductProfile: (productName) => {
                    profileView.productName = productName
                    dashboardRoot.activeTab = "ProductProfile"
                }
            }
            MarketPricesTab { }
            StaffManagementTab { }
            CustomerDirectoryTab { }
            AnalyticsReportsTab { }
            SalesHistoryTab { }
            CustomerStoreView {
                onLogoutRequested: { loader.pop() }
                onCheckoutSuccess: (saleId) => { statusPopup.openWithSale(saleId) }
            }
            ProductProfileView {
                id: profileView
                onBackRequested: dashboardRoot.activeTab = "Products"
            }
        }
    }


    OrderConfirmationPopup {
        id: statusPopup
    }
}
