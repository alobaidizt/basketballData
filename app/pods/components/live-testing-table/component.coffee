`import Ember from 'ember'`

LiveTestingTableComponent = Ember.Component.extend

  actions:
    grabLink: (data) ->
      result = data
        .toString()
        .split(',')
        .toArray()[0]
        .toLowerCase()
        .replace("item ","")
      index = result - 1

      window.open(@get('linksArray')[index])

`export default LiveTestingTableComponent`
