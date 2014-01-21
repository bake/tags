io      = require('socket.io').listen 61225,
	log: false
twitter = require 'twitter'
twit    = new twitter
	consumer_key: ''
	consumer_secret: ''
	access_token_key: ''
	access_token_secret: ''

io.sockets.on 'connection', (socket) ->
	socket.on 'query', (query) ->
		if query isnt ''
			twit.stream 'statuses/filter', { track: query }, (stream) ->
				stream.on 'data', (tweet) ->
					if tweet.user isnt undefined
						io.sockets.emit 'tweet',
							id_str: tweet.id_str
							text: tweet.text
							user:
								screen_name: tweet.user.screen_name

				socket.on 'destroy', =>
					stream.destroy()
