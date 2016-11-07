Promise  = require("bluebird")
co       = Promise.coroutine
express      = Promise.promisifyAll(require('express'))
https        = require('https')
http         = require('http')
path         = require('path')
fs           = Promise.promisifyAll(require('fs'))
logger       = require('morgan')
bodyParser   = require('body-parser')
mongoose     = require('mongoose')
cookieParser = require('cookie-parser')
io           = require('./websocket')

app = express()
mongoose.connect('mongodb://localhost/webApp')

if app.get('env') == 'development'
  console.log('development')
else
  privateKey  = fs.readFileSync('server.key', 'utf8')
  certificate = fs.readFileSync('server.cert', 'utf8')

  credentials = {key: privateKey, cert: certificate}
  https.createServer(credentials, app).listen(443)

http.createServer(app).listen(3000)
console.log('starting to run')

io

routes = require('./routes/index')
api    = require('./routes/api')

allowCrossDomain = (req, res, next) ->
  res.header('Access-Control-Allow-Origin', '*')
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
  res.header('Access-Control-Allow-Headers', 'Content-Type, Accept, Authorization, Content-Length, X-Requested-With')

  if 'OPTIONS' == req.method
    res.sendStatus(200)
  else
    next()

app.use(logger('dev'))
app.use(bodyParser.json())
app.use(bodyParser.raw())
app.use(bodyParser.text())
app.use(bodyParser.urlencoded({ extended: false }))
app.use(cookieParser())
app.use(allowCrossDomain)
app.use(express.static(path.join(__dirname, 'public')))

app.use('/', routes)
app.use('/api', api)

app.use (req, res, next) ->
  err = new Error('Not Found')
  err.status = 404
  next(err)

if app.get('env') == 'development'
  app.use (err, req, res, next) ->
    res.status(err.status || 500)
    res.render('error',
      message: err.message
      error:   err
    )

app.use (err, req, res, next) ->
  res.status(err.status || 500)
  res.render 'error',
    message: err.message,
    error:   {}

module.exports = app
