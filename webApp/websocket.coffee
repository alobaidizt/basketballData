ioServer     = require('socket.io')

io = new ioServer(7000, {serverClient: false})

io.on 'connection', (socket) ->
  console.log('a user connected')

module.exports = io
