#include "mediaplayer.h"



MediaPlayer::MediaPlayer(QObject *parent) : QObject(parent)
{


    player = new QMediaPlayer;
    player->setVolume(50);

    playlist = new QMediaPlaylist;
    new_playlist = new QMediaPlaylist;
    QDir directory("/home/kenshin/Music");

    tracks = directory.entryList(QStringList()<<"*.mp3",QDir::Files);

    QDir dir("/home/kenshin/Music");
    list_of_playlists = directory.entryList(QStringList()<<"*.m3u",QDir::Files);

    foreach(QString track,tracks)
    {
        playlist->addMedia(QUrl::fromLocalFile("/home/kenshin/Music/"+track));

    }

    playlist->setCurrentIndex(0);
    player->setPlaylist(playlist);
    playlist->setPlaybackMode(QMediaPlaylist::Sequential);

    connect(player,&QMediaPlayer::durationChanged,this,&MediaPlayer::durationChanged);
    connect(player,&QMediaPlayer::positionChanged,this,&MediaPlayer::positionChanged);



}

QStringList MediaPlayer::get_track_list()
{
    return tracks;
}

int MediaPlayer::getIndex()
{
    return playlist->currentIndex();
}

void MediaPlayer::on_track_selected(int index)
{
    playlist->setCurrentIndex(index);
}

void MediaPlayer::on_create_playlist_clicked(QString name,int track_index)
{
    QString play_name = "/home/kenshin/Music/"+name;



    QString track_name = tracks[track_index];

    qDebug()<<new_playlist->addMedia(QUrl::fromLocalFile("/home/kenshin/Music/"+track_name));
    qDebug() << new_playlist->save(QUrl::fromLocalFile(play_name+".m3u"),"m3u");
    list_of_playlists.append(name+".m3u");
    qDebug()<<list_of_playlists;
    emit playlist_list_received();

}

void MediaPlayer::load_playlist(int playlist_index)
{
    QString play_name = "/home/kenshin/Music/"+list_of_playlists[playlist_index];
    new_playlist->load(QUrl::fromLocalFile(play_name),"m3u");

    qDebug()<<"entered load" << play_name;

   disp_playlist_tracks(play_name);

    new_playlist->setCurrentIndex(0);
    player->setPlaylist(new_playlist);
    new_playlist->setPlaybackMode(QMediaPlaylist::Sequential);

}

QStringList MediaPlayer::get_playlist_tracks()
{
    return playlist_tracks;

}

QStringList MediaPlayer::get_playlist_list()
{


    return list_of_playlists;
}

void MediaPlayer::on_track_selected_playlist(int index)
{
    new_playlist->setCurrentIndex(index);
}

void MediaPlayer::on_track_checkbox_checked(int index)
{
    track_check_state.append(index);
}

void MediaPlayer::create_playlist_add_multiple(QString name)
{
    QString play_name = "/home/kenshin/Music/"+name;
    for(int i=0; i < track_check_state.length(); i++)
    {
         qDebug()<<new_playlist->addMedia(QUrl::fromLocalFile("/home/kenshin/Music/"+tracks[track_check_state[i]]));
    }
    qDebug() << new_playlist->save(QUrl::fromLocalFile(play_name+".m3u"),"m3u");
    list_of_playlists.append(name+".m3u");
    disp_playlist_tracks(play_name);
    qDebug()<<list_of_playlists;
    emit playlist_list_received();
    track_check_state.clear();
}

void MediaPlayer::on_home_clicked()
{
    player->setPlaylist(playlist);
    playlist->setCurrentIndex(0);

}

void MediaPlayer::existing_playlist_add_multiple(int index)
{

    QString play_name = "/home/kenshin/Music/"+list_of_playlists[index];
    for(int i=0; i < track_check_state.length(); i++)
    {
         qDebug()<<new_playlist->addMedia(QUrl::fromLocalFile("/home/kenshin/Music/"+tracks[track_check_state[i]]));
    }
    qDebug() << new_playlist->save(QUrl::fromLocalFile(play_name),"m3u");
    disp_playlist_tracks(play_name);

    track_check_state.clear();
}

void MediaPlayer::disp_playlist_tracks(QString play_name)
{
    QFile file(play_name);
    if(!file.open(QIODevice::ReadOnly|QIODevice::Text))
        return;
    qDebug()<<"File open";
    QTextStream in(&file);
    while(!in.atEnd()){
        QString line = in.readLine();
        int pos = 24;
        qDebug()<<line.right(pos);
        playlist_tracks.append(line.right(pos));

    }
  file.close();
  qDebug()<<playlist_tracks;
  emit list_created();
}



void MediaPlayer::play()
{
    player->play();
}

void MediaPlayer::pause()
{
    player->pause();
}

void MediaPlayer::next()
{
    playlist->next();
}

void MediaPlayer::previous()
{
    playlist->previous();
}

void MediaPlayer::on_seekbar_sliderMoved(int position)
{
    player->setPosition(position);
}

void MediaPlayer::on_volume_sliderMoved(int value)
{
    player->setVolume(value);
}

void MediaPlayer::mute(bool check)
{
    player->setMuted(check);

}

void MediaPlayer::on_shuffle_clicked(bool checked)
{
    if(checked)
        playlist->setPlaybackMode(QMediaPlaylist::Random);
    else
        playlist->setPlaybackMode(QMediaPlaylist::Sequential);

}

void MediaPlayer::on_repeat_clicked(bool checked)
{
    if(checked)
        playlist->setPlaybackMode(QMediaPlaylist::CurrentItemInLoop);
    else
        playlist->setPlaybackMode(QMediaPlaylist::Sequential);
}




