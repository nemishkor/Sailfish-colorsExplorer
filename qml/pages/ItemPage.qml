import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.XmlListModel 2.0
import QtQuick.LocalStorage 2.0
import ImageGenerator 1.0

Page {
    id: page

    // START params for push page in pageStack

    // required fields for all content
    property string type;
    property string category;

    // propertis for opening item from ListPage
    property string id; // its id for search via api for palettes and patterns
    property string tittle;
    property string userName; // its id for search via api for lovers only
    property string numViews;
    property string numVotes;
    property string numComments;
    property string numHearts;
    property string dateCreated;
    property string hex; // its id for search via api for colors only
    property string red;
    property string blue;
    property string green;
    property string hue;
    property string saturation;
    property string value;
    property string description;
    property string url;
    property string imageUrl;
    property string badgeUrl;
    property string apiUrl;
    // propertis for open from only lovers listPage
    property string dateRegistered;
    property string dateLastActive;
    property string rating;
    property string numColors;
    property string numPalettes;
    property string numPatterns;
    property string numCommentsMade;
    property string numLovers;
    property string numCommentsOnProfile;

    // for One and Random types
    property string path: '/';

    property bool addToHistory: true;

    // END params for push page in pageStack

    property string dataURI;

    property var randomHistory: new Array();
    property int randomAction;
    property int currentRandomHistoryIndex: -1;

    XmlListModel{
        id: listModel
        query: path
        XmlRole {name: "id"; query: "id/string()"}
        XmlRole {name: "title"; query: "title/string()"}
        XmlRole {name: "userName"; query: "userName/string()"}
        XmlRole {name: "numViews"; query: "numViews/string()"}
        XmlRole {name: "numVotes"; query: "numVotes/string()"}
        XmlRole {name: "numComments"; query: "numComments/string()"}
        XmlRole {name: "numHearts"; query: "numHearts/string()"}
        XmlRole {name: "rank"; query: "rank/string()"}
        XmlRole {name: "dateCreated"; query: "dateCreated/string()"}
        XmlRole {name: "hex"; query: "hex/string()"}
        XmlRole {name: "red"; query: "rgb/red/string()"}
        XmlRole {name: "blue"; query: "rgb/blue/string()"}
        XmlRole {name: "green"; query: "rgb/green/string()"}
        XmlRole {name: "hue"; query: "hsv/hue/string()"}
        XmlRole {name: "saturation"; query: "hsv/saturation/string()"}
        XmlRole {name: "value"; query: "hsv/value/string()"}
        XmlRole {name: "description"; query: "description/string()"}
        XmlRole {name: "url"; query: "url/string()"}
        XmlRole {name: "imageUrl"; query: "imageUrl/string()"}
        XmlRole {name: "badgeUrl"; query: "badgeUrl/string()"}
        XmlRole {name: "apiUrl"; query: "apiUrl/string()"}
        XmlRole {name: "dateRegistered"; query: "dateRegistered/string()"}
        XmlRole {name: "dateLastActive"; query: "dateLastActive/string()"}
        XmlRole {name: "rating"; query: "rating/string()"}
        XmlRole {name: "numColors"; query: "numColors/string()"}
        XmlRole {name: "numPalettes"; query: "numPalettes/string()"}
        XmlRole {name: "numPatterns"; query: "numPatterns/string()"}
        XmlRole {name: "numCommentsMade"; query: "numCommentsMade/string()"}
        XmlRole {name: "numLovers"; query: "numLovers/string()"}
        XmlRole {name: "numCommentsOnProfile"; query: "numCommentsOnProfile/string()"}
        onStatusChanged: {
            // update page on load new xml
            if(status == XmlListModel.Ready){
                console.log('status == XmlListModel.Ready')
                if(count == 1){
                    console.log('count == 1')
                    // UI
                    id = listModel.get(0).id
                    category = category
                    tittle = listModel.get(0).title
                    userName = listModel.get(0).userName
                    numViews = listModel.get(0).numViews
                    numVotes = listModel.get(0).numVotes
                    numComments = listModel.get(0).numComments
                    numHearts = listModel.get(0).numHearts
                    dateCreated = listModel.get(0).dateCreated
                    hex = listModel.get(0).hex
                    red = listModel.get(0).red
                    blue = listModel.get(0).blue
                    green = listModel.get(0).green
                    hue = listModel.get(0).hue
                    saturation = listModel.get(0).saturation
                    value = listModel.get(0).value
                    description = listModel.get(0).description
                    url = listModel.get(0).url
                    imageUrl = listModel.get(0).imageUrl
                    badgeUrl = listModel.get(0).badgeUrl
                    apiUrl = listModel.get(0).apiUrl
                    dateRegistered = listModel.get(0).dateRegistered
                    dateLastActive = listModel.get(0).dateLastActive
                    rating = listModel.get(0).rating
                    numColors = listModel.get(0).numColors
                    numPalettes = listModel.get(0).numPalettes
                    numPatterns = listModel.get(0).numPatterns
                    numCommentsMade = listModel.get(0).numCommentsMade
                    numLovers = listModel.get(0).numLovers
                    numCommentsOnProfile = listModel.get(0).numCommentsOnProfile

                    // UX
                    loadingModel.visible = false
                    if(type === "lovers"){
                        console.log("type === lovers")
                        column.visible = false
                        columnLovers.visible = true
                    } else {
                        console.log("type != lovers")
                        column.visible = true
                        columnLovers.visible = false
                    }

                    if(category != "One") {
                        // history (local)
                        if(randomAction == -1){ // if open prev color in history
                            if(randomHistory[currentRandomHistoryIndex - 1])
                                currentRandomHistoryIndex--
                        }
                        if(randomAction == 0){ // if search random color when you open not latest color from history
                            currentRandomHistoryIndex = randomHistory.length
                            var tmp = randomHistory;
                            tmp.push(getIdField())
                            randomHistory = tmp
                            // history (global)
                            addRow(type, getIdField())
                        }
                        if(randomAction == 1){ // if open next color in history or search random
                            currentRandomHistoryIndex++
                        }
                    }
                    searchFavorites()
                }
            }
        }
    }

    function typeConvert(){
        return type.substr(0, type.length - 1)
    }

    function getIdField(){
        if(type === "colors")
            return hex
        if(type === "lovers")
            return userName
        else
            return id
    }

    function loadXml(){
        var id;
        var type
        if(category === "One"){
            type = typeConvert()
            id = getIdField()
        } else { // else Random page
            if(randomAction == 1){ // if open next item in history
                type = typeConvert()
                id = randomHistory[currentRandomHistoryIndex + 1]
            }
            if(randomAction == -1){ // if open prev item in history
                type = typeConvert()
                id = randomHistory[currentRandomHistoryIndex - 1]
            } else { // else search new random
                type = page.type
                id = "random"
            }
        }
        dataURI = "http://www.colourlovers.com/api/" + type + "/" + id
        console.log(dataURI)
        console.log("!")
        var req = new XMLHttpRequest();
        req.open("get", dataURI);
        req.send();
        req.onreadystatechange = function () {
            if (req.readyState === XMLHttpRequest.DONE) {
                if (req.status === 200) {
                    listModel.xml = req.responseText;
                    listModel.reload();
                } else {
                    console.log("HTTP request failed", req.status)
                    loadLbl.text = "HTTP request failed\nRequest status " + req.status + "\nCheck your Internet connection"
                }
            }
        }
    }

    function debug(){
        console.log("---");
        console.log("randomAction=" + randomAction);
        console.log("currentRandomHistoryIndex=" + currentRandomHistoryIndex);
        console.log("randomHistory.length=" + randomHistory.length);
        for(var i = 0; i < randomHistory.length; i++)
            console.log("randomHistory[" + i + "]=" + randomHistory[i]);
    }


    // START history logic

    function initDb() {
        var db = LocalStorage.openDatabaseSync("ColorsExplorerDB", "1.0", "", 1000000);
        db.transaction(
            function(tx) {
                tx.executeSql("CREATE TABLE IF NOT EXISTS History(id INTEGER PRIMARY KEY, type TEXT, identifier TEXT)")
                tx.executeSql("CREATE TABLE IF NOT EXISTS Favorites(id INTEGER PRIMARY KEY, type TEXT, identifier TEXT)")
            }
        )
    }

    function addRow(newType, newId) {
        var db = LocalStorage.openDatabaseSync("ColorsExplorerDB", "1.0", "", 1000000);
        db.transaction(
            function(tx) {
                tx.executeSql("CREATE TABLE IF NOT EXISTS History(id INTEGER PRIMARY KEY, type TEXT, identifier TEXT)")
                tx.executeSql("INSERT INTO History VALUES(null, '" + newType + "','" + newId + "')");
            }
        )
    }

    function setFavorites(checked) {
        var identifier
        if(type == "lovers")
            identifier = userName
        else
            if(type == "palettes" || type == "patterns")
                identifier = id
            else // else colors
                identifier = hex
        console.log('setFavorites(' + type + ', ' + identifier + ', ' + checked + ')')
        var db = LocalStorage.openDatabaseSync("ColorsExplorerDB", "1.0", "", 1000000)
        db.transaction(
            function(tx) {
                if(checked === 1)
                    tx.executeSql("INSERT INTO Favorites VALUES(null, '" + type + "','" + identifier + "')")
                else
                    tx.executeSql("DELETE FROM Favorites WHERE identifier='" + identifier + "' AND type='" + type + "'")
            }
        )
    }

    function searchFavorites() {
        var db = LocalStorage.openDatabaseSync("ColorsExplorerDB", "1.0", "", 1000000)
        db.transaction(
            function(tx) {
                var identifier
                if(type == "lovers")
                    identifier = userName
                else
                    if(type == "palettes" || type == "patterns")
                        identifier = id
                    else // else colors
                        identifier = hex
                tx.executeSql("CREATE TABLE IF NOT EXISTS Favorites(id INTEGER PRIMARY KEY, type TEXT, identifier TEXT)")
                var rs = tx.executeSql("SELECT * FROM Favorites WHERE identifier='" + identifier + "'")
                if(rs.rows.length > 0)
                    favIcon.chacked = 1
                else
                    favIcon.chacked = 0
            }
        )
    }

    function getRandom(){
        randomAction = 0
        loadXml()
    }

    function getOne(){
        loadXml()
    }

    // END history logic

    Component.onCompleted: {
        initDb
        if(category == "Random"){ // load random item
            getRandom()
        } else { // load item using identifier (hex, userName or id)
            if(category == "One")
                getOne()
            else { // open from list
                searchFavorites()
                if(addToHistory)
                    addRow(type, getIdField())
            }
        }
    }

    ProgressBar {
        id: loadingModel
        visible: (category === "Random" || category === "One") ? true : false
        width: parent.width
        height: 50
        indeterminate: true
        label: qsTr("Loading")
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        Label{
            id: loadLbl
            anchors.top: parent.bottom
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: TextEdit.WordWrap
        }
    }

    SilicaFlickable {
        id: listView
        anchors.fill: parent
        contentHeight: column.height

        ImageGenerator{
            id: imageGenerator
        }

        PullDownMenu{
            MenuItem {
                visible: (mainImage.status === Image.Ready) ? true : false
                text: qsTr("Save to gallery")
                onClicked: {
                    var dialog = pageStack.push("../dialogs/SizeDialog.qml", {
                                                    screenWidth: page.width,
                                                    screenHeight: page.height,
                                                    originalWidth: mainImage.sourceSize.width,
                                                    originalHeight: mainImage.sourceSize.height,
                                                    fileName: tittle,
                                                })
                    dialog.accepted.connect(function() {
                        imageGenerator.saveImage(imageUrl, dialog.fileName, dialog.imgWidth, dialog.imgHeight, dialog.blacken, dialog.overlayColor, dialog.overlayOpacity)
                    })
                }
            }
            MenuItem {
                text: qsTr("View original link")
                onClicked: {
                    Qt.openUrlExternally(url);
                }
            }
        }

        Column{
            id: column
            width: parent.width
            visible: (category === "Random" || type === 'lovers') ? false : true
            spacing: Theme.paddingMedium
            anchors.bottomMargin: Theme.paddingLarge
            PageHeader {
                anchors.rightMargin: favIcon.width + Theme.paddingSmall
                anchors.right: parent.right
                id: columnTitle
                title: tittle
                IconButton {
                    id: favIcon
                    anchors.left: parent.right
                    anchors.leftMargin: Theme.paddingSmall
                    width: 80
                    height: 80
                    anchors.verticalCenter: parent.verticalCenter
                    icon.source: (chacked == 0) ? "image://theme/icon-m-favorite" : "image://theme/icon-m-favorite-selected"
                    property int chacked: -1; // when searching in local base -1
                    visible: (chacked != -1) ? true : false
                    onClicked: {
                        if(chacked == 0)
                            chacked++
                        else
                            chacked--
                        setFavorites(chacked)
                    }
                }
            }
            Item{
                visible: (category == "Random") ? true : false
                width: page.width / 9 * 7
                height: 80
                anchors.leftMargin: page.width / 9
                anchors.left: parent.left
                IconButton {
                    id: btnPrev
                    icon.source: "image://theme/icon-m-back?" + (pressed
                                 ? Theme.highlightColor
                                 : Theme.primaryColor)
                    enabled: (randomHistory[currentRandomHistoryIndex - 1]) ? true : false
                    onClicked: {
                        loadingModel.visible = true
                        randomAction = -1
                        loadXml()
                        column.visible = false
                    }
                    anchors.right: btnReload.left
                    anchors.rightMargin: Theme.paddingSmall
                }
                Button{
                    id: btnReload
                    text: qsTr("Next random")
                    onClicked: {
                        loadingModel.visible = true
                        randomAction = 0
                        loadXml()
                        column.visible = false
                    }
                    preferredWidth: Theme.buttonWidthMedium
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                IconButton {
                    id: btnNext
                    icon.source: "image://theme/icon-m-forward?" + (pressed
                                 ? Theme.highlightColor
                                 : Theme.primaryColor)
                    enabled: (randomHistory[currentRandomHistoryIndex + 1] && currentRandomHistoryIndex != -1) ? true : false
                    onClicked: {
                        loadingModel.visible = true
                        randomAction = 1
                        loadXml()
                        column.visible = false
                    }
                    anchors.left: btnReload.right
                    anchors.leftMargin: Theme.paddingSmall
                }
            }
            Image{
                id: mainImage
                source: imageUrl
                width: parent.width
                height: parent.width / sourceSize.width * sourceSize.height
                fillMode: Image.Tile
            }

            ComboBox {
                Image{
                    id: imageFillMode
                    width: sourceSize.width; height: parent.height - 2 * Theme.paddingSmall
                    fillMode: Image.PreserveAspectFit
                    horizontalAlignment: Image.AlignRight
                    source: "qrc:/iconPrefix/tile.png"
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.paddingLarge
                    anchors.topMargin: Theme.paddingSmall
                }
                visible: (type == "colors") ? false : true
                label: qsTr("Image size: ")
                currentIndex: 0
                width: parent.width
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("tile")
                        onClicked: {
                            mainImage.fillMode = Image.Tile
                            mainImage.width = mainImage.parent.width
                            mainImage.x = 0
                            imageFillMode.source = "qrc:/iconPrefix/tile.png"
                        }
                    }
                    MenuItem {
                        text: qsTr("original")
                        onClicked: {
                            mainImage.fillMode = Image.PreserveAspectFit
                            mainImage.width = mainImage.sourceSize.width
                            mainImage.x = (mainImage.parent.width - mainImage.sourceSize.width) / 2
                            imageFillMode.source = "qrc:/iconPrefix/original.png" }
                    }
                    MenuItem {
                        text: qsTr("fill")
                        onClicked: {
                            mainImage.fillMode = Image.PreserveAspectFit
                            mainImage.width = mainImage.parent.width
                            mainImage.x = 0
                            imageFillMode.source = "qrc:/iconPrefix/fit.png" }
                    }
                }
            }

            Rectangle{
                color: "transparent"
                width: parent.width
                y: Theme.paddingSmall
                height: 139
                Rectangle{
                    color: "transparent"
                    id: heartsRect
                    width: parent.width / 4
                    anchors.left: parent.left
                    height: parent.height
                    Image{
                        anchors.verticalCenter: parent.verticalCenter
                        id: heartsImage
                        source: "qrc:/iconPrefix/icon-launcher-people.png"
                        width: parent.width
                        height: sourceSize.height
                        fillMode: Image.PreserveAspectFit
                        Rectangle{
                            width: heartsLblCount.width + 10
                            height: heartsLblCount.height
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            radius: 8
                            color: "#80ffffff"
                            Label{
                                id: heartsLblCount
                                x: 5
                                color: "#000000"
                                horizontalAlignment: Text.AlignHCenter
                                text: numHearts
                            }
                        }
                    }
                    Label{
                        id: heartsLbl
                        anchors.top: heartsImage.bottom
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                        text: qsTr("Hearts")
                    }
                }
                Rectangle{
                    color: "transparent"
                    id: voteRect
                    width: parent.width / 4
                    anchors.left: heartsRect.right
                    height: parent.height
                    Image{
                        anchors.verticalCenter: parent.verticalCenter
                        id: voteImage
                        source: "qrc:/iconPrefix/icon-vote.png"
                        width: parent.width
                        height: 86
                        fillMode: Image.PreserveAspectFit
                        Rectangle{
                            width: votesLblCount.width + 10
                            height: votesLblCount.height
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            radius: 8
                            color: "#80ffffff"
                            Label{
                                id: votesLblCount
                                x: 5
                                color: "#000000"
                                horizontalAlignment: Text.AlignHCenter
                                text: numVotes
                            }
                        }
                    }
                    Label{
                        anchors.top: voteImage.bottom
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width
                        text: qsTr("Votes")
                    }
                }
                Rectangle{
                    color: "transparent"
                    id: viewsRect
                    width: parent.width / 4
                    anchors.left: voteRect.right
                    height: parent.height
                    Image{
                        anchors.verticalCenter: parent.verticalCenter
                        id: viewsImage
                        source: "qrc:/iconPrefix/icon-view.png"
                        width: parent.width
                        height: 86
                        fillMode: Image.PreserveAspectFit
                        Rectangle{
                            width: viewsLblCount.width + 10
                            height: viewsLblCount.height
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            radius: 8
                            color: "#80ffffff"
                            Label{
                                id: viewsLblCount
                                x: 5
                                color: "#000000"
                                horizontalAlignment: Text.AlignHCenter
                                text: numViews
                            }
                        }
                    }
                    Label{
                        anchors.top: viewsImage.bottom
                        font.pixelSize: 18
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Views")
                    }
                }
                Rectangle{
                    color: "transparent"
                    width: parent.width / 4
                    anchors.left: viewsRect.right
                    height: parent.height
                    Image{
                        anchors.verticalCenter: parent.verticalCenter
                        id: commentImage
                        source: "qrc:/iconPrefix/icon-launcher-messaging.png"
                        width: parent.width
                        height: 86
                        fillMode: Image.PreserveAspectFit
                        Rectangle{
                            width: comLblCount.width + 10
                            height: comLblCount.height
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 4
                            anchors.horizontalCenter: parent.horizontalCenter
                            radius: 8
                            color: "#80ffffff"
                            Label{
                                id: comLblCount
                                x: 5
                                color: "#000000"
                                horizontalAlignment: Text.AlignHCenter
                                text: numComments
                            }
                        }
                    }
                    Label{
                        anchors.top: commentImage.bottom
                        font.pixelSize: 18
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        text: qsTr("Comments")
                    }
                }
            }

            SectionHeader{
                text: qsTr("Description")
                visible: (description === "") ? false : true
            }

            Label{
                visible: (description === "") ? false : true
                width: parent.width - 2 * Theme.paddingMedium
                x: Theme.paddingMedium
                text: description
                horizontalAlignment: Text.AlignLeft
                //truncationMode: truncationMode.Fade
                color: Theme.secondaryHighlightColor
                wrapMode: Text.WordWrap
                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        parent.wrapMode = Text.Wrap
                    }
                }
            }

            Rectangle{
                visible: (type == "colors") ? true : false
                width: parent.width
                height: (Theme.paddingSmall * 6) + Theme.paddingMedium + rgbHeader.height + redInd.height + greenInd.height + blueInd.height + hsvHeader.height + hueInd.height + satInd.height + valInd.height
                color: "transparent"
                SectionHeader {
                    id: rgbHeader
                    text: qsTr("RGB")
                }
                // RED INDICATOR
                Rectangle{
                    id: redInd
                    color: "transparent"
                    border.color: "#8ec4de"
                    border.width: 1
                    height: 25
                    radius: 8
                    anchors.top: rgbHeader.bottom
                    anchors.topMargin: Theme.paddingSmall
                    x: Theme.paddingLarge
                    width: parent.width - 2 * Theme.paddingLarge
                    Rectangle{
                        radius: 8
                        color: "#f44336"
                        width: parent.width * red / 255
                        anchors.left: parent.left
                        height: parent.height
                        Label{
                            font.pixelSize: 24
                            anchors.fill: parent
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: red
                            anchors.leftMargin: (red < 10) ? (red + 20) : 0
                        }
                    }
                }
                // GREEN INDICATOR
                Rectangle{
                    id: greenInd
                    color: "transparent"
                    border.color: "#8ec4de"
                    border.width: 1
                    height: 25
                    anchors.topMargin: Theme.paddingSmall
                    anchors.top: redInd.bottom
                    radius: 8
                    y: 15
                    x: Theme.paddingLarge
                    width: parent.width - 2 * Theme.paddingLarge
                    Rectangle{
                        radius: 8
                        color: "#4caf50"
                        width: parent.width * green / 255
                        anchors.left: parent.left
                        height: parent.height
                        Label{
                            font.pixelSize: 24
                            anchors.fill: parent
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: green
                            anchors.leftMargin: (green < 10) ? (green + 20) : 0
                        }
                    }
                }
                // BLUE INDICATOR
                Rectangle{
                    id: blueInd
                    color: "transparent"
                    border.color: "#8ec4de"
                    border.width: 1
                    radius: 8
                    height: 25
                    anchors.topMargin: Theme.paddingSmall
                    anchors.top: greenInd.bottom
                    x: Theme.paddingLarge
                    width: parent.width - 2 * Theme.paddingLarge
                    Rectangle{
                        radius: 8
                        color: "#2196f3"
                        width: parent.width * blue / 255
                        anchors.left: parent.left
                        height: parent.height
                        Label{
                            font.pixelSize: 24
                            anchors.fill: parent
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: blue
                            anchors.leftMargin: (blue < 10) ? (blue + 20) : 0
                        }
                    }
                }
                SectionHeader {
                    id: hsvHeader
                    text: qsTr("HSV")
                    anchors.topMargin: Theme.paddingSmall
                    anchors.bottomMargin: Theme.paddingSmall
                    anchors.top: blueInd.bottom
                }
                // HUE INDICATOR
                Rectangle{
                    id: hueInd
                    color: "transparent"
                    border.color: "#8ec4de"
                    border.width: 1
                    radius: 8
                    x: Theme.paddingLarge
                    width: parent.width - 2 * Theme.paddingLarge
                    height: 32
                    anchors.topMargin: Theme.paddingSmall
                    anchors.bottomMargin: Theme.paddingSmall
                    anchors.top: hsvHeader.bottom
                    Rectangle{
                        radius: 8
                        rotation: 90
                        gradient: Gradient{
                            GradientStop{ position: 0.0; color: "red" }
                            GradientStop{ position: 0.15; color: "magenta" }
                            GradientStop{ position: 0.30; color: "blue" }
                            GradientStop{ position: 0.45; color: "cyan" }
                            GradientStop{ position: 0.70; color: "green" }
                            GradientStop{ position: 0.85; color: "yellow" }
                            GradientStop{ position: 1.0; color: "red" }
                        }
                        height: parent.width * hue / 360
                        width: 32
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: parent.width * hue / 360 / 2 - 16
                        anchors.topMargin: -1 * parent.width * hue / 360 / 2 + 16
                        Label{
                            id: hueIndLbl
                            font.pixelSize: 22
                            anchors.fill: parent
                            rotation: 270
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTr("hue ") + hue
                            anchors.leftMargin: (hue < 50) ? (hue + 50) : 0
                            color: (hue < 50) ? "white" : "black"
                        }
                    }
                }
                // SATURATION INDICATOR
                Rectangle{
                    id: satInd
                    color: "transparent"
                    border.color: "#8ec4de"
                    border.width: 1
                    radius: 8
                    x: Theme.paddingLarge
                    width: parent.width - 2 * Theme.paddingLarge
                    height: 32
                    anchors.topMargin: Theme.paddingSmall
                    anchors.bottomMargin: Theme.paddingSmall
                    anchors.top: hueInd.bottom
                    Rectangle{
                        radius: 8
                        rotation: 270
                        gradient: Gradient{
                            GradientStop{ position: 0.0; color: "#808080" }
                            GradientStop{ position: 1.0; color: "#" + hex }
                        }
                        height: parent.width * saturation / 100
                        width: 32
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: parent.width * saturation / 100 / 2 - 16
                        anchors.topMargin: -1 * parent.width * saturation / 100 / 2 + 16
                        Label{
                            id: satIndLbl
                            font.pixelSize: 22
                            anchors.fill: parent
                            rotation: 90
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            anchors.leftMargin: (saturation < 25) ? (saturation + 25) : 0
                            color: (saturation < 25) ? "white" : "black"
                            text: qsTr("saturation ") + saturation
                        }
                    }
                }
                // VALUE INDICATOR
                Rectangle{
                    id: valInd
                    color: "transparent"
                    border.color: "#8ec4de"
                    border.width: 1
                    radius: 8
                    x: Theme.paddingLarge
                    width: parent.width - 2 * Theme.paddingLarge
                    height: 32
                    anchors.topMargin: Theme.paddingSmall
                    anchors.bottomMargin: Theme.paddingSmall
                    anchors.top: satInd.bottom
                    Rectangle{
                        radius: 8
                        rotation: 270
                        gradient: Gradient{
                            GradientStop{ position: 0.0; color: "#000000" }
                            GradientStop{ position: 0.5; color: "#" + hex }
                            GradientStop{ position: 1.0; color: "#fff" }
                        }
                        height: parent.width * value / 100
                        width: 32
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: parent.width * value / 100 / 2 - 16
                        anchors.topMargin: -1 * parent.width * value / 100 / 2 + 16
                        Label{
                            id: valIndLbl
                            font.pixelSize: 22
                            anchors.fill: parent
                            rotation: 90
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                            //anchors.leftMargin: (value < 50) ? (value + 50) : 0
                            color: (value < 50) ? "white" : "black"
                            text: qsTr("value ") + value
                        }
                    }
                }
            }


            SectionHeader {
                text: qsTr("Details")
            }

            Row{
                height: userNameLbl.height
                width: parent.width - 2 * Theme.paddingMedium;
                x: Theme.paddingMedium;

                Label{
                    id: userNameLbl
                    text: qsTr("User name: ")
                }
                Label{
                    text: userName
                    color: Theme.secondaryColor
                    MouseArea{
                        anchors.fill: parent
                        onClicked: pageStack.push(Qt.resolvedUrl("ItemPage.qml"), {
                                                      userName: userName,
                                                      category: "One",
                                                      type: "lovers",
                                                      path: "/lovers/lover"})
                    }
                }
            }

            Row{
                height: hexLbl.height
                width: parent.width - 2 * Theme.paddingMedium;
                x: Theme.paddingMedium;
                visible: (type == "colors") ? true : false
                Label{
                    id: hexLbl
                    text: qsTr("hex: #")
                }
                Label{
                    text: hex
                    color: Theme.secondaryColor
                }
            }

            Row{
                height: createdLbl.height
                width: parent.width - 2 * Theme.paddingMedium;
                x: Theme.paddingMedium;
                Label{
                    id: createdLbl
                    text: qsTr("Created: ")
                }
                Label{
                    text: dateCreated
                    color: Theme.secondaryColor
                }
            }

            Row{
                height: idLbl.height
                width: parent.width - 2 * Theme.paddingMedium;
                x: Theme.paddingMedium;
                Label{
                    id: idLbl
                    text: qsTr("id: ")
                }
                Label{
                    text: id
                    color: Theme.secondaryColor
                }
            }

            /*
            Button {
                text: "Open image in browser"
                anchors.horizontalCenter: parent.horizontalCenter
                preferredWidth: Theme.buttonWidthMedium
                onClicked: {
                    Qt.openUrlExternally(imageUrl);
                }
            }


            Button {
                text: "Open badge in browser"
                anchors.horizontalCenter: parent.horizontalCenter
                preferredWidth: Theme.buttonWidthMedium
                onClicked: {
                    Qt.openUrlExternally(badgeUrl);
                }
            }


            Button {
                text: "Open api url in browser"
                anchors.horizontalCenter: parent.horizontalCenter
                preferredWidth: Theme.buttonWidthMedium
                onClicked: {
                    Qt.openUrlExternally(apiUrl);
                }
            }*/
        }

        Column{
            id: columnLovers
            visible: (type === 'lovers') ? true : false
            width: parent.width
            spacing: Theme.paddingMedium
            anchors.bottomMargin: Theme.paddingLarge

            PageHeader {
                title: userName
            }

            SectionHeader {
                text: qsTr("Details")
            }

            Row{
                height: dateRegLbl.height
                width: parent.width - 2 * Theme.paddingMedium;
                x: Theme.paddingMedium;
                Label{
                    id: dateRegLbl
                    text: qsTr("Date registered: ")
                }
                Label{
                    text: dateRegistered
                    color: Theme.secondaryColor
                }
            }

            Row{
                height: dateLastActiveLbl.height
                width: parent.width - 2 * Theme.paddingMedium;
                x: Theme.paddingMedium;
                Label{
                    id: dateLastActiveLbl
                    text: qsTr("Date last active: ")
                }
                Label{
                    text: dateLastActive
                    color: Theme.secondaryColor
                }
            }

            Row{
                height: ratingLbl.height
                width: parent.width - 2 * Theme.paddingMedium;
                x: Theme.paddingMedium;
                Label{
                    id: ratingLbl
                    text: qsTr("Rating: ")
                }
                Label{
                    text: rating
                    color: Theme.secondaryColor
                }
            }

            Row{
                height: numColorsLbl.height
                width: parent.width - 2 * Theme.paddingMedium;
                x: Theme.paddingMedium;
                Label{
                    id: numColorsLbl
                    text: qsTr("Num colors: ")
                }
                Label{
                    text: numColors
                    color: Theme.secondaryColor
                }
            }

            Row{
                height: numPalettesLbl.height
                width: parent.width - 2 * Theme.paddingMedium;
                x: Theme.paddingMedium;
                Label{
                    id: numPalettesLbl
                    text: qsTr("Num palettes: ")
                }
                Label{
                    text: numPalettes
                    color: Theme.secondaryColor
                }
            }

            Row{
                height: numPatternsLbl.height
                width: parent.width - 2 * Theme.paddingMedium;
                x: Theme.paddingMedium;
                Label{
                    id: numPatternsLbl
                    text: qsTr("Num patterns: ")
                }
                Label{
                    text: numPatterns
                    color: Theme.secondaryColor
                }
            }

            Row{
                height: numCommentsMadeLbl.height
                width: parent.width - 2 * Theme.paddingMedium;
                x: Theme.paddingMedium;
                Label{
                    id: numCommentsMadeLbl
                    text: qsTr("Num comments made: ")
                }
                Label{
                    text: numCommentsMade
                    color: Theme.secondaryColor
                }
            }

            Row{
                height: numLoversLbl.height
                width: parent.width - 2 * Theme.paddingMedium;
                x: Theme.paddingMedium;
                Label{
                    id: numLoversLbl
                    text: qsTr("Num lovers: ")
                }
                Label{
                    text: numLovers
                    color: Theme.secondaryColor
                }
            }

            Row{
                height: numCommentsOnProfileLbl.height
                width: parent.width - 2 * Theme.paddingMedium;
                x: Theme.paddingMedium;
                Label{
                    id: numCommentsOnProfileLbl
                    text: qsTr("Num comments on profile: ")
                }
                Label{
                    text: numCommentsOnProfile
                    color: Theme.secondaryColor
                }
            }
        }


        VerticalScrollDecorator {}
    }
}





