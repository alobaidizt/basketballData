ioServer = require('socket.io')

getIOServer = => @io
setupWebsocket = (server = null) =>
  if server?
    @io = ioServer(server)
  else
    @io = new ioServer(7000, {serverClient: false})

  @io.on 'connection', (socket) ->
    console.log('a user connected')

module.exports =
  getIOServer:      getIOServer
  setupWebsocket: setupWebsocket
