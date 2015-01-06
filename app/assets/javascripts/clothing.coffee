logClothingInBackground = (element) ->
  element.style.backgroundColor = '#CCCCCC'
  $.ajax(url: element.href, type: 'POST').done ->
    element.style.backgroundColor = '#CCFFCC'
  return false

$ ->
  $("a.log-action").click (e) ->
    e.preventDefault()
    logClothingInBackground(this)
