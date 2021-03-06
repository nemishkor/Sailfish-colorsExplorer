import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import QtQuick.XmlListModel 2.0


Page {
    // START for stats section
    property int currentStatsLoad: 0;

    function loadStats(category){
        var dataURI = "http://www.colourlovers.com/api/stats/" + category
        var req = new XMLHttpRequest()
        req.open("get", dataURI)
        req.send()
        req.onreadystatechange = function () {
            if (req.readyState === XMLHttpRequest.DONE) {
                if (req.status === 200) {
                    statsModel.xml = req.responseText
                    currentStatsLoad++
                    statsModel.reload()
                } else {
                    console.log("HTTP request failed", req.status)
                    loadLbl.text = "HTTP request failed\nRequest status " + req.status + "\nCheck your Internet connection"
                }
            }
        }
    }

    // START HISTORY AND FAVORITES

    // START RELOAD LAST SECTION WHEN PAGE BACK
    property bool innactive: false;

    onStatusChanged: {
        if (status == 0){
            innactive = true
        }
        if(innactive && status === 2){
            table = 'History'
            lastViwed()
            innactive = false
        }
    }
    // END RELOAD LAST SECTION WHEN PAGE BACK

    property string currentType;
    property string dataURI;
    property string table: 'History';

    function lastViwed(){
        var db = LocalStorage.openDatabaseSync("ColorsExplorerDB", "1.0", "", 1000000)
        db.transaction(
            function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS  ' + table + '(id INTEGER PRIMARY KEY, type TEXT, identifier TEXT)')
                var rs = tx.executeSql('SELECT * FROM ' + table + ' Orders ORDER BY id DESC LIMIT 1')
                if(rs.rows.length > 0){
                    console.log('rs.rows.length > 0')
                    if(rs.rows.item(0).type === 'colors')
                        currentType = 'color'
                    if(rs.rows.item(0).type === 'lovers')
                        currentType = 'lover'
                    if(rs.rows.item(0).type === 'patterns')
                        currentType = 'pattern'
                    if(rs.rows.item(0).type === 'palettes')
                        currentType = 'palette'
                    var req = new XMLHttpRequest()
                    dataURI = "http://www.colourlovers.com/api/" + currentType + "/" + rs.rows.item(0).identifier
                    req.open("get", dataURI);
                    req.send();
                    req.onreadystatechange = function () {
                        if (req.readyState === XMLHttpRequest.DONE) {
                            if (req.status === 200) {
                                console.log("req.status === 200")
                                xmlModel.xml = req.responseText;
                                xmlModel.reload();
                            } else {
                                console.log("HTTP request failed", req.status)
                            }
                        }
                    }
                    // UI
                    if(table === 'History'){
                        lastProgressCircle.visible = true
                        historyLastLbl.font.pixelSize = Theme.fontSizeLarge
                        historyLastLbl.text = qsTr("Last\nviewed")
                    } else {
                        lastFavoriteProgressCircle.visible = true
                        favoriteLastLbl.font.pixelSize = Theme.fontSizeLarge
                        favoriteLastLbl.text = qsTr("Last\nfavorite")
                    }
                } else {
                    if(table === 'History'){
                        lastProgressCircle.visible = false
                        historyLastLbl.font.pixelSize = Theme.fontSizeMedium
                        historyLastLbl.text = qsTr("Last\nviewed") + qsTr("\nHistory is empty")
                    } else {
                        lastFavoriteProgressCircle.visible = false
                        favoriteLastLbl.font.pixelSize = Theme.fontSizeMedium
                        favoriteLastLbl.text = qsTr("Last\nfavorite") + qsTr("\nFavorites is empty")
                    }
                    if(table === 'History') {
                        table = 'Favorites'
                        lastViwed()
                    }
                }
            }
        )
    }
    ListModel{
        id: listModel
    }
    XmlListModel{
        id: xmlModel
        query: '/' + currentType + 's/' + currentType
        XmlRole {name: "id"; query: "id/string()"}
        XmlRole {name: "title"; query: "title/string()"}
        XmlRole {name: "userName"; query: "userName/string()"}
        XmlRole {name: "numViews"; query: "numViews/string()"}
        XmlRole {name: "numVotes"; query: "numVotes/string()"}
        XmlRole {name: "imageUrl"; query: "imageUrl/string()"}
        onStatusChanged: {
            // update page on load new xml
            if(status == XmlListModel.Ready){
                if(count == 1){
                    if(currentType === 'lover'){
                        if(table === 'History'){
                            lastImage.fillMode = Image.PreserveAspectFit
                            lastImage.source = "image://theme/icon-l-people"
                        } else {
                            lastFavoriteImage.fillMode = Image.PreserveAspectFit
                            lastFavoriteImage.source = "image://theme/icon-l-people"
                        }
                    } else {
                        if(table === 'History'){
                            lastImage.fillMode = Image.Tile
                            lastImage.source = xmlModel.get(0).imageUrl
                        } else {
                            lastFavoriteImage.fillMode = Image.Tile
                            lastFavoriteImage.source = xmlModel.get(0).imageUrl
                        }
                    }
                }
                if(table === 'History'){
                    table = 'Favorites'
                    lastViwed()
                } else
                    xml = ''
            }
        }
    }

    // END HISTORY AND FAVORITES

    XmlListModel{
        id: statsModel
        query: "/stats"
        XmlRole {name: "total"; query: "total/string()"}
        onStatusChanged: {
            if(status == XmlListModel.Ready){
                switch(currentStatsLoad){
                case 1:
                    totalColorsLbl.text += get(0).total
                    loadStats("palettes")
                    break;
                case 2:
                    totalPalettesLbl.text += get(0).total
                    loadStats("patterns")
                    break;
                case 3:
                    totalPatternsLbl.text += get(0).total
                    loadStats("lovers")
                    break;
                case 4:
                    totalLoversLbl.text += get(0).total
                    break;
                }
            }
        }
    }
    // END for stats section

    Component.onCompleted: {
        loadStats("colors")
        lastViwed()
    }

    id: coverPage
    orientation: orientation.All

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        PullDownMenu{
            MenuItem{
                text: qsTr("About")
                onClicked: pageStack.push("AboutPage.qml")
            }
            MenuItem{
                text: qsTr("History")
                onClicked: pageStack.push("HistoryPage.qml")
            }
            MenuItem{
                text: qsTr("Favorites")
                onClicked: pageStack.push("FavoritesPage.qml")
            }
        }

        Column {
            id: column
            width: parent.width

            PageHeader {
                title: qsTr("Colors explorer")
            }

            Image{
                fillMode: Image.TileHorizontally
                source: "qrc:/main/colors-bg.png"
                width: parent.width
                height: 1
            }

            // CATEGORIES -----------------------------------------------

            SectionHeader{
                text: qsTr("Categories")
            }

            ComboBox {
                id: colorsMenuItem
                Image{
                    width: parent.width; height: parent.height - 2 * Theme.paddingSmall
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignRight
                    source: "qrc:/main/preview-category-color.png"
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingLarge
                    anchors.topMargin: Theme.paddingSmall
                }
                label: qsTr("Colors")
                currentIndex: -1
                width: parent.width
                onCurrentIndexChanged: { _clearCurrent() }
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("New")
                        onClicked: {
                            pageStack.push("ListPage.qml", {
                                               type: "colors",
                                               path: "/colors/color",
                                               category: "New",
                                               titlePage: qsTr("New colors"), })
                        }
                    }
                    MenuItem {
                        text: qsTr("Top")
                        onClicked: {
                            pageStack.push("ListPage.qml", {
                                               type: "colors",
                                               path: "/colors/color",
                                               category: "Top",
                                               titlePage: qsTr("Top colors"), })
                        }
                    }
                    MenuItem {
                        text: qsTr("Random")
                        onClicked: {
                            pageStack.push("ItemPage.qml", {
                                               type: "colors",
                                               path: "/colors/color",
                                               category: "Random",
                                               titlePage: qsTr("Random color"), })
                        }
                    }
                }
            }

            ComboBox {
                id: palettesMenuItem
                Image{
                    width: parent.width; height: parent.height - 2 * Theme.paddingSmall
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignRight
                    source: "qrc:/main/preview-category.png"
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingLarge
                    anchors.topMargin: Theme.paddingSmall
                }
                label: qsTr("Palettes")
                currentIndex: -1
                width: parent.width
                onCurrentIndexChanged: { _clearCurrent() }
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("New")
                        onClicked: {
                            pageStack.push("ListPage.qml", {
                                               type: "palettes",
                                               path: "/palettes/palette",
                                               heightDelegate: 220,
                                               category: "New",
                                               titlePage: qsTr("New palettes"), })
                        }
                    }
                    MenuItem {
                        text: qsTr("Top")
                        onClicked: {
                            pageStack.push("ListPage.qml", {
                                               type: "palettes",
                                               path: "/palettes/palette",
                                               heightDelegate: 220,
                                               category: "Top",
                                               titlePage: qsTr("Top palettes"), })
                        }
                    }
                    MenuItem {
                        text: qsTr("Random")
                        onClicked: {
                            pageStack.push("ItemPage.qml", {
                                               type: "palettes",
                                               path: "/palettes/palette",
                                               category: "Random",
                                               titlePage: qsTr("Random palette"), })
                        }
                    }
                }
            }

            ComboBox {
                id: patternsMenuItem
                Image{
                    width: parent.width; height: parent.height - 2 * Theme.paddingSmall
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignRight
                    source: "qrc:/main/preview-category-patterns.png"
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingLarge
                    anchors.topMargin: Theme.paddingSmall
                }
                label: qsTr("Patterns")
                currentIndex: -1
                width: parent.width
                onCurrentIndexChanged: { _clearCurrent() }
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("New")
                        onClicked: {
                            pageStack.push("ListPage.qml", {
                                               type: "patterns",
                                               path: "/patterns/pattern",
                                               heightDelegate: 220,
                                               category: "New",
                                               titlePage: qsTr("New patterns"), })
                        }
                    }
                    MenuItem {
                        text: qsTr("Top")
                        onClicked: {
                            pageStack.push("ListPage.qml", {
                                               type: "patterns",
                                               path: "/patterns/pattern",
                                               heightDelegate: 220,
                                               category: "Top",
                                               titlePage: qsTr("Top patterns"), })
                        }
                    }
                    MenuItem {
                        text: qsTr("Random")
                        onClicked: {
                            pageStack.push("ItemPage.qml", {
                                               type: "patterns",
                                               path: "/patterns/pattern",
                                               category: "Random",
                                               titlePage: qsTr("Random pattern"), })
                        }
                    }
                }
            }

            ComboBox {
                id: loversMenuItem
                label: qsTr("Lovers")
                currentIndex: -1
                width: parent.width
                onCurrentIndexChanged: { _clearCurrent() }
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("New")
                        onClicked: {
                            pageStack.push("ListPage.qml", {
                                               type: "lovers",
                                               path: "/lovers/lover",
                                               category: "New",
                                               titlePage: qsTr("New lovers"), })
                        }
                    }
                    MenuItem {
                        text: qsTr("Top")
                        onClicked: {
                            pageStack.push("ListPage.qml", {
                                               type: "lovers",
                                               path: "/lovers/lover",
                                               category: "Top",
                                               titlePage: qsTr("Top lovers"), })
                        }
                    }
                }
            }

            // TOOLS -----------------------------------------------

            SectionHeader{
                text: qsTr("Tools")
            }
            BackgroundItem {
                width: parent.width
                Label {
                    id: firstName
                    text: qsTr("Color selector")
                    anchors.verticalCenter: parent.verticalCenter
                    x: Theme.horizontalPageMargin
                }
                onClicked: pageStack.push("ColorsSelectorPage.qml")
            }

            // HISTORY AND FAVORITES -------------------------------

            Rectangle{
                color: 'transparent'
                width: parent.width
                height: width / 2
                Rectangle{
                    color: 'transparent'
                    width: parent.width / 2
                    height: parent.height
                    anchors.left: parent.left
                    anchors.top: parent.top
                    ProgressCircle {
                        id: lastProgressCircle
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
                Image{
                    id: lastImage
                    width: parent.width / 2
                    height: parent.height
                    fillMode: Image.Tile
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    onProgressChanged: lastProgressCircle.value = progress
                    onStatusChanged: {
                        if(status == Image.Ready){
                            lastProgressCircle.visible = false
                        }
                    }
                    Rectangle{
                        color: "#6d3a3a"
                        gradient: Gradient {
                            GradientStop {
                                position: 0.00;
                                color: "#00ffffff";
                            }
                            GradientStop {
                                position: 0.10;
                                color: "#66000000";
                            }
                            GradientStop {
                                position: 0.13;
                                color: "#99000000";
                            }
                            GradientStop {
                                position: 0.88;
                                color: "#99000000";
                            }
                            GradientStop {
                                position: 0.9;
                                color: "#66000000";
                            }
                            GradientStop {
                                position: 1;
                                color: "#00ffffff";
                            }
                        }
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.topMargin: (parent.height - historyLastLbl.height) / 2 - Theme.paddingMedium
                        height: historyLastLbl.height + 2 * Theme.paddingMedium
                        width: parent.width
                    }

                    Label {
                        id: historyLastLbl
                        text: qsTr("Last\nviewed")
                        font.pixelSize: Theme.fontSizeExtraLarge
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.paddingSmall
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    IconButton{
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        icon.source: "image://theme/icon-m-clock"
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: pageStack.push("HistoryPage.qml")
                    }
                }
                Rectangle{
                    color: 'transparent'
                    width: parent.width / 2
                    height: parent.height
                    anchors.right: parent.right
                    anchors.top: parent.top
                    ProgressCircle {
                        id: lastFavoriteProgressCircle
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
                Image{
                    id: lastFavoriteImage
                    width: parent.width / 2
                    height: parent.height
                    anchors.left: lastImage.right
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    fillMode: Image.Tile
                    onProgressChanged: lastFavoriteProgressCircle.value = progress
                    onStatusChanged: {
                        if(status == Image.Ready){
                            lastFavoriteProgressCircle.visible = false
                        }
                    }
                    Rectangle{
                        color: "#6d3a3a"
                        gradient: Gradient {
                            GradientStop {
                                position: 0.00;
                                color: "#00ffffff";
                            }
                            GradientStop {
                                position: 0.10;
                                color: "#66000000";
                            }
                            GradientStop {
                                position: 0.13;
                                color: "#99000000";
                            }
                            GradientStop {
                                position: 0.88;
                                color: "#99000000";
                            }
                            GradientStop {
                                position: 0.9;
                                color: "#66000000";
                            }
                            GradientStop {
                                position: 1;
                                color: "#00ffffff";
                            }
                        }
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.topMargin: (parent.height - favoriteLastLbl.height) / 2 - Theme.paddingMedium
                        height: favoriteLastLbl.height + 2 * Theme.paddingMedium
                        width: parent.width
                    }

                    Label {
                        id: favoriteLastLbl
                        text: qsTr("Last\nfavorite")
                        font.pixelSize: Theme.fontSizeExtraLarge
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.paddingSmall
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    IconButton{
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        icon.source: "image://theme/icon-m-favorite"
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked: pageStack.push("FavoritesPage.qml")
                    }
                }
            }

            // STATS -----------------------------------------------

            SectionHeader{
                text: qsTr("Stats")
            }

            Label{
                id: totalColorsLbl
                text: qsTr("Total colors: ")
                color: Theme.secondaryColor
                x: Theme.horizontalPageMargin
            }

            Label{
                id: totalPalettesLbl
                text: qsTr("Total palettes: ")
                color: Theme.secondaryColor
                x: Theme.horizontalPageMargin
            }

            Label{
                id: totalPatternsLbl
                text: qsTr("Total patterns: ")
                color: Theme.secondaryColor
                x: Theme.horizontalPageMargin
            }

            Label{
                id: totalLoversLbl
                text: qsTr("Total lovers: ")
                color: Theme.secondaryColor
                x: Theme.horizontalPageMargin
            }

            Item{
                width: parent.width
                height: Theme.paddingLarge
            }

        }

        PushUpMenu{
            id: pushUpMenu
            MenuItem{
                text: qsTr("Create ambience")
                onClicked: pageStack.push(Qt.resolvedUrl("AmbiencesPage.qml"))
            }
        }

    }
}

