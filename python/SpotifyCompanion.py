
import json
import spotipy
from spotipy.oauth2 import SpotifyOAuth

#export SPOTIPY_CLIENT_ID='your-spotify-client-id'
#export SPOTIPY_CLIENT_SECRET='your-spotify-client-secret'
#export SPOTIPY_REDIRECT_URI='your-app-redirect-url'

sp = spotipy.Spotify(auth_manager=SpotifyOAuth(
    client_id="",
    client_secret="",
    redirect_uri="http://localhost:3000",
    scope="user-library-read, playlist-modify-private, playlist-read-private"
    )
)

#results = sp.current_user_saved_tracks()

#current_user_saved_tracks_add

results = sp.current_user_saved_tracks(limit=50, offset=0, market='US')

""" def return_tracks(res):
    for idx, item in enumerate(res['items']):
        added_at = item[0]['added_at']
        print(added_at)
 """


def itterate_through_tracks(results):
    while results:
        for i, track in enumerate(results['items']):
            msg = {
                "added_at": track['added_at'],
                "track_id": track['track']['id'],
                "Track_Name": track['track']['name'],
                "artist": track['track']['artists'][0]['name']
            }
            print(msg)
        if results['next']:
            results = sp.next(results)
        else:
            results = None


def returnAllTracks(results):
    tracksArray = []
    while results:
        for i, track in enumerate(results['items']):
            tracksArray.append(track)
        if results['next']:
            results = sp.next(results)
        else:
            results = None
    return tracksArray


AllTracks = returnAllTracks(results)

sp.playlist_add_items('553HuHlbMTseqZ8pHZaK5c', AllTracks)

with open('LikedSongs.json', 'w') as f:
    json.dump(AllTracks, f)

PLAYLISTS = sp.current_user_playlists(limit=50, offset=0)


def MyPlaylists(PLAYLISTS):
    while PLAYLISTS:
        for i, list in enumerate(PLAYLISTS['items']):
            msg = {
                "added_at": list['added_at'],
                "track_id": list['track']['id'],
                "Track_Name": list['track']['name'],
                "artist": list['track']['artists'][0]['name']
            }
            print(list)

        if PLAYLISTS['next']:
            PLAYLISTS = sp.next(PLAYLISTS)
        else:
            PLAYLISTS = None


#playlists = sp.user_playlists('spotify')
#while playlists:
#    for i, playlist in enumerate(playlists['items']):
#        print("%4d %s %s" %
#              (i + 1 + playlists['offset'], playlist['uri'],  playlist['name']))
#    if playlists['next']:
#        playlists = sp.next(playlists)
#    else:
#        playlists = None


results = sp.current_user_saved_tracks()

TOTAL = results['total']
NEXT_URL = results['next']


def show_tracks(results):
    for item in results['items']:
        track_added_at = item['added_at']
        print(track_added_at)


show_tracks(results)


for item in results['items']:
    track = item['track']
    print(track)


# user playlists 
PLAYLISTS = sp.current_user_playlists(limit=50, offset=0)



# Add songs to playlist
# playlist_add_items(playlist_id, items, position=None)
# 553HuHlbMTseqZ8pHZaK5c
sp.playlist_add_items('553HuHlbMTseqZ8pHZaK5c', items)

for item in results['items']:
    track = item['track']
    # Note brackets around track['uri']
    print(track)
    #sp.playlist_add_items(playlist_id, [track['uri']])


def show_tracks(results):
    for idx in range(0, len(results['items']), 100):
        uris = [item['track']['uri'] for item in results['items'][idx:idx+100]]
        print(uris)
        #sp.playlist_add_items(playlist_id, uris)
        
        
        
        

