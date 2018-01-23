# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/



$(document).on "turbolinks:load", ->
  $('#create_scan').submit (e) ->
    e.preventDefault()
    $('.scan_fieldset').attr('disabled', 'disabled')
    $('.loading-message').css('visibility', 'visible')
    $.post '/scans.json', {url: $('#scan_url').val() , authenticity_token: $('#authenticity_token').val() }, (data) ->
      uuid = data.uuid
      redirect_url = "/scans/" + uuid
      console.log(redirect_url)
      check_url = redirect_url + ".json"
      check_and_redirect = () ->
        $.get check_url, (data) ->
          if Array.isArray(data)
            window.location.href = redirect_url
      setInterval(check_and_redirect, 1000)

  return unless $('#word-count-chart').length > 0
  
  svg = d3.select('#word-count-chart')
  margin = 
    top: 20
    right: 20
    bottom: 30
    left: 40
  width = +svg.attr('width') - (margin.left) - (margin.right)
  height = +svg.attr('height') - (margin.top) - (margin.bottom)
  x = d3.scaleBand().rangeRound([
    0
    width
  ]).padding(0.1)
  y = d3.scaleLinear().rangeRound([
    height
    0
  ])
  g = svg.append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')')
  url = "/scans/" + $('#word-count-chart').data('id') + ".json"
  d3.json url, (error, data) ->
    if error
      throw error
    x.domain data.map((d) ->
      d.word
    )
    y.domain [
      0
      d3.max(data, (d) ->
        d.freq
      )
    ]
    g.append('g').attr('class', 'axis axis--x').attr('transform', 'translate(0,' + height + ')').call d3.axisBottom(x)
    g.append('g').attr('class', 'axis axis--y').call(d3.axisLeft(y).ticks(10)).append('text').attr('transform', 'rotate(-90)').attr('y', 6).attr('dy', '0.71em').attr('text-anchor', 'end').text 'Frequency'
    g.selectAll('.bar').data(data).enter().append('rect').attr('class', 'bar').attr('x', (d) ->
      x d.word
    ).attr('y', (d) ->
      y d.freq
    ).attr('width', x.bandwidth()).attr 'height', (d) ->
      height - y(d.freq)
    return