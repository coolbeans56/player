#ifndef MEDIAPLAYER_H
#define MEDIAPLAYER_H

#include <QObject>
#include <QMediaPlayer>
#include <QMediaPlaylist>
#include <QDir>
#include <QMediaMetaData>
#include <QQuickView>
#include <QQmlContext>
#include <QFile>

class MediaPlayer : public QObject
{
    Q_PROPERTY(int count READ get_playlist_track_count  NOTIFY countChanged)
    Q_PROPERTY(int playlist_selected READ get_selected_playlist)
    Q_PROPERTY(QStringList playlist_list READ get_playlist_list NOTIFY playlist_list_received)
    Q_PROPERTY(QStringList new_track_list READ get_playlist_tracks NOTIFY list_created)
    Q_PROPERTY(QStringList track_list READ get_track_list )
    Q_PROPERTY(int index READ getIndex)
    Q_OBJECT
public:
    explicit MediaPlayer(QObject *parent = nullptr);




signals:
    void durationChanged(qint64 duration);
    void positionChanged(qint64 position);
    void list_created();
    void playlist_list_received();
    void countChanged();



public slots:
    void play();
    void pause();
    void next();
    void previous();
    void on_seekbar_sliderMoved(int position);
    void on_volume_sliderMoved(int value);
    void mute(bool check);
    void on_shuffle_clicked(bool checked);
    void on_repeat_clicked(bool checked);

    QStringList get_track_list();
    int getIndex();
    void on_track_selected(int index);
    //void on_create_playlist_clicked(QString name,int track_index);
    void load_playlist(int playlist_index);
    QStringList get_playlist_tracks();
    QStringList get_playlist_list();
    //void on_track_selected_playlist(int index);
    void on_track_checkbox_checked(int index);
    void create_playlist_add_multiple(QString name);
    void on_home_clicked();
    void existing_playlist_add_multiple(int index);
    void disp_playlist_tracks(QString play_name);
    void delete_playlist();
    void delete_track();

    void selected_playlist(int index);
    void clear_selected_playlist();
    int get_selected_playlist();
    int get_playlist_track_count();



private:

    QMediaPlayer *player;
    QMediaPlaylist *playlist;
    QMediaPlaylist *new_playlist;
    QStringList tracks;
    QStringList list_of_playlists;
    QStringList playlist_tracks;
    QList<int> track_check_state;
    int playlist_index;



};

#endif // MEDIAPLAYER_H
