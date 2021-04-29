# discography-shelf

Give me a .txt file with your favorite albums and I'll display it in a Trello board.

## Installation

Just clone this repo and run the following commands (assuming you have ruby in your system):

```
bundle
ruby app.rb
```

## Configuration

Create a `.env` file to keep your configurations

```
TRELLO_API_KEY={your trello api key}
TRELLO_API_BASE_URI=https://api.trello.com/1
TRELLO_API_AUTH_URI=https://trello.com/1
TRELLO_API_SECRET={your trello api secret}
SPOTIFY_API_CLIENT_ID={your spotify api client id}
SPOTIFY_API_CLIENT_SECRET={your spotify api client secret}
SPOTIFY_API_BASE_URI=https://api.spotify.com/v1
SPOTIFY_API_AUTH_URI=https://accounts.spotify.com/api
```
