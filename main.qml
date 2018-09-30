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



    Player{
        id:player
        onDurationChanged: {
            seekbar.maximumValue = duration
            time = duration;
            s = time/1000;
            min = s/60;
            sec = s%60;
            duration_field.text = min+":"+sec
            track_list.currentIndex = player.index
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
                text:modelData
            }

            MouseArea{

                anchors.fill:parent
                onClicked: player.on_track_selected(track_list_index)

            }

        }
    }

    Flickable{

        Row{
            id:row

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
            ListView {
                id: track_list_checkbox

                x: 73
                y: 366
                width: 30
                height: 160
                focus: true
                clip: true
                visible: true
                model:checkModel
                property int check_count

                delegate:


                    CheckBox{
                    id:checkDelegate
                    text:""
                    height:15
                    activeFocusOnPress: true
                    clip: false
                    checked:false

                    property int check_index:index
                    onClicked:{
                        checkbox_state:true
                        track_list_checkbox.check_count++
                        console.log(track_list_checkbox.check_count)

                        player.on_track_checkbox_checked(check_index)
                        console.log(check_index)
                    }
                }


            }


        }
    }





    /*checkbox */
    ListModel {
        id: checkModel

        Component.onCompleted: {
            for (var i = 0; i < track_list.count; i++) {
                append(createListElement());
            }
        }

        function createListElement() {
            return {

                text:""

            };
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
            width: parent.width
            color: "lightblue"

        }
    }


    Component{
        id:custom_delegateName
        Item{


            width:parent.width
            height:15
            property int track_list_index:index


            Text{
                text:modelData
            }

            MouseArea{
                id:custom_mouseArea


                anchors.fill:parent
                onClicked:
                {
                    console.log(custom_list_view.view_flag)

                    if(!custom_list_view.view_flag&&!playlist_options.existing_option_pressed)
                    {
                        custom_list_view.view_flag++
                        player.load_playlist(index)
                        custom_list_view.model = player.new_track_list

                    }
                    else if (custom_list_view.view_flag && !playlist_options.existing_option_pressed)
                    {
                        player.on_track_selected_playlist(index)
                    }
                    else if(!custom_list_view.view_flag && playlist_options.existing_option_pressed)
                    {
                        player.existing_playlist_add_multiple(index)
                        custom_list_view.model = player.new_track_list
                    }

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

                    custom_list_view.model = player.playlist_list
                    playlist_options.existing_option_pressed = 1
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
            if(!track_list_checkbox.check_count)
            {
                player.on_create_playlist_clicked(playlist_name.text,current_media_index)
                custom_list.append({"Text":playlist_name.text})
            }
            else
            {
                player.create_playlist_add_multiple(playlist_name.text)
                custom_list.append({"Text":playlist_name.text})

            }

        }

        TextInput{
            id:playlist_name
            text: "Enter name"
        }
    }

    Button {
        id: home
        x: 46
        y: 31
        text: qsTr("Home")
        onClicked:
        {
            custom_list_view.view_flag = 0
            custom_list_view.model = player.playlist_list
            player.on_home_clicked()


        }
    }



}



















