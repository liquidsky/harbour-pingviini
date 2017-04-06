import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic



Page {
    id: page
    property var locale: Qt.locale()
    property bool loadStarted: false

    function pullData(){
        var msg = {
            'action': 'statuses_homeTimeline',
            'model' : Logic.modelTL,
            'mode'  : "prepend",
            'conf'  : Logic.getConfTW()
        };
        worker.sendMessage(msg);

        var msg2 = {
            'action': 'statuses_mentionsTimeline',
            'model' : Logic.modelMN,
            'mode'  : "prepend",
            'conf'  : Logic.getConfTW()
        };
        worker.sendMessage(msg2);
    }
    Timer {
        interval: 2*1000; running: true; repeat: true
        onTriggered: {
            //pullData()


            Logic.modelTL.append(Logic.parseTweet(Logic.tweet1))
            Logic.modelTL.append(Logic.parseTweet(Logic.tweet2))
        }
    }


    Button {
        text:"Pull"
        onClicked: function(){
            // pullData()

        }
    }

    WorkerScript {
        id: worker
        source: "../lib/Worker.js"
        onMessage: myText.text = messageObject.reply
    }

    Component.onCompleted: {
        console.log("Splash Conf!")

        var obj = {};
        Logic.mediator.installTo(obj);
        obj.subscribe('confLoaded', function(){
            console.log(typeof arguments)
            console.log('confLoaded');
            //console.log(JSON.stringify(Logic.conf))
            //console.log(JSON.stringify(Logic.getConfTW()))

            //pullData()
            pageStack.pushAttached(Qt.resolvedUrl("FirstPage.qml"), {})
        });


    }


}


