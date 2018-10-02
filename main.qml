import QtQuick 2.6
import QtQuick.Window 2.2
import mediaplayer 1.0
import QtQuick.Controls 1.5
import QtQuick.Dialogs 1.2
import QtQml.Models 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.4

Window {
    id:root
    visible: true
    width: 950
    height: 800
    title: qsTr("Media Player")

    property int time;
    property int s;
    property int min;
    property int sec;
    property bool checkbox_state: false
    property int view:0



    Player{
        id:player
        onDurationChanged: {
            seekbar.maximumValue = duration
            time = duration;
            s = time/1000;
            min = s/60;
            sec = s%60;
            duration_field.text = min+":"+sec

            if(player.selected_playlist)
            {
                custom_list_view.currentIndex = player.index
                track_count.text = (custom_list_view.currentIndex+1)+"/"+player.count
            }
            else
            {
            track_list.currentIndex = player.index
            track_count.text = (track_list.currentIndex+1)+"/"+player.count
            }
            console.log("Song change",player.index)
            console.log("Current index",track_list.currentIndex)



        }
        onPositionChanged: {
            seekbar.value = position
            time = position;
            s = time/1000;
            min = s/60;
            sec = s%60;
            position_field.text = min+":"+sec
        }

    }

    Button {
        id: play
        x: 135
        y: 256
        text:checked? qsTr("Pause"):qsTr("Play")
        checkable: true
        onClicked: if(checked)
                   {

                       player.play()
                   }
                   else
                   {

                       player.pause()
                   }

    }


    Button {
        id: next
        x: 214
        y: 256
        text: qsTr("Next")
        onClicked: player.next()
    }


    Button {
        id: previous
        x: 55
        y: 256
        text: qsTr("Previous")
        onClicked: player.previous()
    }

    Slider {
        id: seekbar
        x: 46
        y: 203
        width: 259
        height: 34
        // onValueChanged: player.on_seekbar_sliderMoved(value)
        MouseArea{
            anchors.fill:parent

            onClicked: player.on_seekbar_sliderMoved((seekbar.maximumValue*mouseX)/seekbar.width)
        }

    }

    Text {
        id: duration_field
        x: 260
        y: 176
        width: 45
        height: 13

        font.pixelSize: 12

    }

    Slider {
        id: volume_slider
        x: 380
        y: 88
        width: 18
        height: 101
        orientation: Qt.Vertical
        maximumValue: 100
        minimumValue: 0
        onValueChanged: player.on_volume_sliderMoved(value)

    }

    Button {
        id: mute
        x: 349
        y: 208
        text:checked? qsTr("Unmute"):qsTr("Mute")
        checkable: true
        onClicked: player.mute(checked)
    }

    Text {
        id: position_field
        x: 214
        y: 176
        width: 45
        height: 13
        font.pixelSize: 12
    }

    Button {
        id: repeat
        x: 46
        y: 104
        text: checked? qsTr("Repeat off"):qsTr("Repeat")
        checkable: true
        onClicked:if(checked)
                  {
                      player.on_repeat_clicked(checked)
                      shuffle.enabled = false
                  }
                  else
                  {
                      player.on_repeat_clicked(checked)
                      shuffle.enabled = true
                  }
    }



    Button {
        id: shuffle
        x: 184
        y: 104
        text: checked? qsTr("Shuffle off"):qsTr("Shuffle")
        checkable: true
        onClicked:if(checked)
                  {
                      player.on_shuffle_clicked(checked)
                      repeat.enabled = false
                  }
                  else
                  {
                      player.on_shuffle_clicked(checked)
                      repeat.enabled = true
                  }

    }


    /*all songs list*/

    Component{
        id:delegateName
        Item{
            width:parent.width
            height:15
            property int track_list_index:index

            Text{
                id:track_title
                x:20
                text:modelData
            }
            CheckBox{
                id:track_check_box
                checked: false
                onClicked: {
                    if(checked)
                    {
                        player.on_track_checkbox_checked(track_list_index)
                    }
                }
            }

            MouseArea{

                anchors.fill:track_title
                onClicked: {

                    track_list.currentIndex = track_list_index
                    player.on_track_selected(track_list_index)

                }

            }

        }
    }


    ListView {
        id: track_list

        x: 104
        y: 366
        width: 300
        height: 160
        anchors.bottomMargin: 202
        anchors.leftMargin: 475
        anchors.rightMargin: 35
        anchors.topMargin: 78
        focus: true
        clip: true
        model: player.track_list

        delegate:delegateName


        highlightFollowsCurrentItem: true

        highlight: Rectangle {
            width: parent.width
            color: "lightblue"

        }

    }






    /* Custom playlist listview*/

    ListModel {
        id: custom_list
        dynamicRoles: true


    }

    ListView {
        id: custom_list_view


        x: 505
        y: 88
        width: 300
        height: 160
        anchors.bottomMargin: 202
        anchors.leftMargin: 475
        anchors.rightMargin: 35
        anchors.topMargin: 78
        focus: true
        clip: true
        model:player.playlist_list

        delegate:custom_delegateName
        property int view_flag:0

        highlightFollowsCurrentItem: true
        highlight: Rectangle {
            width: 300
            color: "lightblue"

        }
    }


    Component{
        id:custom_delegateName
        Item{
            width:parent.width
            height:15
            property int custom_index:index
            Text{
                id:custom_text
                x:20
                text:modelData
            }
            CheckBox{
                id:custom_checkbox
                checked:false
                onClicked:{
                    if(checked)
                    {
                        player.on_track_checkbox_checked(custom_index)
                    }
                }

            }
            MouseArea{
                anchors.fill:custom_text
                onClicked: {
                    custom_list_view.currentIndex = custom_index
                    player.on_track_selected(custom_list_view.currentIndex)

                }
                onDoubleClicked: {
                    player.load_playlist(custom_list_view.currentIndex)
                    custom_text.x = 20
                    custom_list_view.model = player.new_track_list
                    player.selected_playlist(custom_index)

                    //console.log("View changed",root.view)


                }
            }


        }
    }



    /*Add button*/

    Button {
        id: add
        x: 505
        y: 433
        text: qsTr("Add")
        onClicked:playlist_options.popup()
        Menu{
            id:playlist_options
            property int existing_option_pressed:0
            MenuItem{
                text: "Create new playlist"
                onTriggered: create_new_playlist.open()
            }
            MenuItem{
                text: "Existing playlist"
                onTriggered: {
                    player.existing_playlist_add_multiple(custom_list_view.currentIndex)
                }

            }
        }
    }

    Dialog {
        id: create_new_playlist

        title: "Create new playlist"
        standardButtons: StandardButton.Save | StandardButton.Cancel
        property int current_media_index: track_list.currentIndex


        onAccepted: {

            player.create_playlist_add_multiple(playlist_name.text)
            custom_list.append({"Text":playlist_name.text})

        }

        TextInput{
            id:playlist_name
            text: "Enter name"
        }
    }

    Button {
        id: home
        x: 46
        y: 29
        text: qsTr("Home")
        onClicked: {
            custom_list_view.model = player.playlist_list
            player.on_home_clicked()
            view = 0
            player.clear_selected_playlist()
            //console.log("view changed",root.view)
        }
    }

    Button {
        id: discard_playlist
        x: 777
        y: 17
        text: qsTr("Delete")

        onClicked: {

            if(!player.selected_playlist)
            {
                player.delete_playlist()
                custom_list_view.model = player.playlist_list
            }
            else
            {

                player.delete_track()
                custom_list_view.model = player.new_track_list
            }
        }
    }

    Label {
        id: track_count
        x: 46
        y: 180
        width: 29
        height: 17
        text: qsTr("")
    }


}



















