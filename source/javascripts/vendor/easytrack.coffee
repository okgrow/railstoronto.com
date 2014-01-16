# Dependencies:
# jQuery
# jQuery.appear: https://github.com/bas2k/jquery.appear/
# Analytics.js: https://github.com/segmentio/analytics.js

# TODO allow parameters in data-track descriptions
# TODO use coffescript for loop instead of jquery each

addStringTrimPolyfill = ->
  if typeof String::trim isnt "function"
    String::trim = ->
      @replace /^\s+|\s+$/g, ""

setupEvents = () -> 
  # track when elements are clicked or submitted
  $('[data-track]').each (i, el) -> 
    $el = $(el)
    descriptions = parseDescriptions(el, 'data-track')
    if $el.is('form')
      # On forms we record the event on submit
      $el.submit -> 
        # record a submit event for each event description
        for d in descriptions
          event = "submit: #{d}"
          track(event)

      # Set the name tag if the form contains an email address.
      $el.submit -> 
        if @.email && @.email.value
          console.log("identifying as #{@.email.value}") if log_tracking?
          analytics.identify(@.email.value) 

    else if $el.is('a') && isExternalLink($el.attr('href'))
      # On external links we record the event on click, but we cancel the
      # original navigation and wait 250 ms to give the tracking calls a better
      # chance at completing before the page unloads
      # Unfortunately this breaks "command-click" navigation where the user
      # expects the page to load in a different tab.
      # TODO investigate to find a better solution
      $el.click (e) ->
        # wait 250ms before navigating
        e.preventDefault()
        window.setTimeout("window.location.href='" + @.href + "'", 250)

        # record a click event for each event description given
        for d in descriptions
          event = "click: #{d}"
          track(event)
    else
      # On any other element we record the event on click
      $el.click (e) ->
        # record a click event for each event description given
        for d in descriptions
          event = "click: #{d}"
          track(event)

  # track when elements come into view
  $('[data-track-seen]').each (i, el) -> 
    $el = $(el)
    $el.appear ->
      for d in parseDescriptions(el, 'data-track-seen')
        track("seen: #{d}")

recordVisitEvent = () ->
  event = "visit"
  params = {"page": window.location.pathname}
  track(event, params)

# parse out multiple strings separated by '|' in the given attribute of the given element
parseDescriptions = (el, attr) -> 
  descriptions = $(el).attr(attr).split('|')
  return (d.trim() for d in descriptions)

window.isExternalLink = (url) ->
  return false unless url
  return url.indexOf('#') != 0

track = (event, params) ->
  console.log("recording event: \"#{event}\"", "params:", params) if log_tracking?
  analytics.track(event, params)

$(document).ready ->
  unless disable_tracking?
    addStringTrimPolyfill()
    setupEvents()
    recordVisitEvent()
