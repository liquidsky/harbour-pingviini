import QtQuick 2.0
import Sailfish.Silica 1.0
import "../lib/Logic.js" as Logic
import "./cmp/"

Page {
    property ListModel tweets;
    property string name : "";
    property string username : "";
    property string profileImage : "";
    property int user_id;
    property int statuses_count;
    property int friends_count;
    property int followers_count;
    property int favourites_count;
    property int count_moments;
    property string profile_background : "";
    property string location : "";
    property bool following : false;
    property bool muting: false;
    property bool detailsLoaded: false;


    WorkerScript {
        id: worker
        source: "../lib/Worker.js"
        onMessage: {
            console.log(JSON.stringify(messageObject))
            if(messageObject.key === "users_show" || messageObject.action === "friendships_destroy" || messageObject.action ===  "friendships_create"){
                name = messageObject.reply.name
                username = messageObject.reply.screen_name
                if (profileImage ==="")
                    profileImage = messageObject.reply.profile_image_url_https
                followers_count = messageObject.reply.followers_count
                friends_count = messageObject.reply.friends_count
                statuses_count = messageObject.reply.statuses_count
                favourites_count = messageObject.reply.favourites_count
                profile_background = messageObject.reply.profile_background_image_url_https
                location = messageObject.reply.location
                following= messageObject.reply.following
                muting = (messageObject.reply && messageObject.reply.muting ? messageObject.reply.muting : false )
                user_id = messageObject.reply.id

            }
        }
    }

    allowedOrientations: Orientation.All
    Component.onCompleted: {
        var msg = {
            'headlessAction': 'users_show',
            'params': {'screen_name': username},
            'conf'  : Logic.getConfTW()
        };
        worker.sendMessage(msg);
    }


    MyList {

        header: ProfileHeader {
            id: header
            bg: profile_background
            title: name
            description: '@'+username
            image: profileImage
        }
        model: ListModel {}
        action: "statuses_userTimeline"
        vars: { 'screen_name': '@'+username, "count":200}
        conf: Logic.getConfTW()
        width: parent.width
        anchors {
            top: parent.top
            bottom: expander.top
            left: parent.left
            right: parent.right
        }
        clip: true
        delegate: CmpTweet {tweet: model; miniDisplayMode: true}
    }

    ExpandingSectionGroup {
        id: expander
        //currentIndex: 0
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        ExpandingSection {
            title: qsTr("Summary")
            content.sourceComponent: Column {
                anchors.bottomMargin: Theme.paddingLarge
                CmpListItem {
                    visible: location != "" ? true : false
                    label: qsTr("Location")
                    value: location
                    onClicked: Qt.openUrlExternally("maps:0,0?q=google");

                }
                CmpListItem {
                    visible: followers_count ? true : false
                    label: qsTrId("Followers")
                    value: followers_count
                    onClicked: pageStack.push(Qt.resolvedUrl("Lists.qml"), {
                                                  action: "followers_list",
                                                  name: name,
                                                  username: username,
                                                  avatar: profileImage,
                                                  profileBg: profile_background,
                                                  description: '@'+username +' ' + qsTrId("followers")
                                              })
                }
                CmpListItem {
                    visible: friends_count ? true : false
                    label: qsTrId("Following")
                    value: friends_count
                    onClicked: pageStack.push(Qt.resolvedUrl("Lists.qml"), {
                                                  action: "friends_list",
                                                  name: name,
                                                  username: username,
                                                  avatar: profileImage,
                                                  profileBg: profile_background,
                                                  description: '@'+username +' ' + qsTrId("friends")
                                              })
                }
                CmpListItem {
                    visible: statuses_count ? true : false
                    enabled: false
                    label: qsTrId("Tweets")
                    value: statuses_count
                }
                CmpListItem {
                    visible: favourites_count ? true : false
                    enabled: false
                    label: qsTrId("Favourites")
                    value: favourites_count
                }
                Label {
                    text: " "
                }
                Column {
                    spacing: Theme.paddingMedium
                    anchors.horizontalCenter:     parent.horizontalCenter
                    Button {
                        id: btnFollow
                        text: (following ? qsTr("Unfollow") : qsTr("Follow"))
                        onClicked: {

                            var msg = {
                                'headlessAction': following ? "friendships_destroy" : "friendships_create",
                                                              'params': {'screen_name': username},
                                'conf'  : Logic.getConfTW()
                            };
                            worker.sendMessage(msg);
                            following = !following
                        }
                    }
                    Button {
                        id: btnBlock
                        text: muting  ?  qsTr("Unmute") : qsTr("Mute")
                        onClicked: {

                            var msg = {
                                'headlessAction': muting ? "mutes_users_destroy" : "mutes_users_create",
                                                           'params': {'screen_name': username},
                                'conf'  : Logic.getConfTW()
                            };
                            worker.sendMessage(msg);
                            muting = !muting
                        }
                    }



                }
                Label {
                    text: " "
                }
            }

        }
        /*ExpandingSection {
            title: "Tweets"

        }*/
    }



}
