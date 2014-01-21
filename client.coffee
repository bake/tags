window.onload = ->
	query     = document.querySelector 'input[type="text"]'
	speed     = document.querySelector 'input[type="range"]'
	displayed = document.querySelector 'input[type="number"]'
	canvas    = 
		s: document.querySelector 'canvas.sec'
		m: document.querySelector 'canvas.min'

	if window.localStorage['query'] isnt undefined
		query.value = window.localStorage['query']

	if window.localStorage['speed'] isnt undefined
		speed.value = window.localStorage['speed']

	if window.localStorage['displayed'] isnt undefined
		displayed.value = window.localStorage['displayed']

	tweets    =
		s: []
		m: []
	series    =
		s: new TimeSeries()
		m: new TimeSeries()
	chart     =
		s: new SmoothieChart
			millisPerPixel: speed.value
		m: new SmoothieChart
			millisPerPixel: speed.value
			timestampFormatter: SmoothieChart.timeFormatter
	socket    = io.connect 'http://localhost:61225/'
	list      = document.querySelector 'ul'
	options   =
		lineWidth: 4
		strokeStyle: 'rgba(0, 255, 0, 1)'

	canvas.s.width = window.innerWidth
	canvas.m.width = window.innerWidth

	chart.s.addTimeSeries series.s, options
	chart.m.addTimeSeries series.m, options

	chart.s.streamTo canvas.s, 1000
	chart.m.streamTo canvas.m, 10000

	socket.emit 'query', window.localStorage['query']

	socket.on 'tweet', (tweet) ->
		tweets.s.push tweet
		tweets.m.push tweet

		list.innerHTML = '<li>@<a href="https://twitter.com/' +
			tweet.user.screen_name + '/status/' +
			tweet.id_str + '" target="_blanc">' +
			tweet.user.screen_name + '</a>: ' +
			tweet.text + '</li>' +
			list.innerHTML
		list.removeChild tweet for tweet, index in document.querySelectorAll 'ul li:nth-child(n+' + (parseInt(displayed.value) + 1) + ')'

	updateSeconds = =>
		series.s.append new Date().getTime(), tweets.s.length
		tweets.s = []

	updateMinutes = =>
		series.m.append new Date().getTime(), tweets.m.length
		tweets.m = []

	setInterval updateSeconds, 1000
	setInterval updateMinutes, 10000

	query.onchange = (event) ->
		window.localStorage['query'] = event.target.value

		#if new Date().getTime() - event.target.getAttribute 'data-last-modified' > 6000
		socket.emit 'destroy'
		socket.emit 'query', event.target.value

		#event.target.setAttribute 'data-last-modified', new Date().getTime()

	displayed.onchange = (event) ->
		window.localStorage['displayed'] = event.target.value

	speed.onchange = (event) ->
		window.localStorage['target'] = event.target.value

		chart.s.options.millisPerPixel = event.target.value
		chart.m.options.millisPerPixel = event.target.value
