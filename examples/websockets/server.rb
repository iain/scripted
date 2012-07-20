require 'sinatra'
require 'coffee-script'
require 'sass'

Tilt.register Tilt::ERBTemplate, 'handlebars'

helpers do
  def handlebars(name)
    partial = render :handlebars, :"_#{name}"
    "<script type='text/x-handlebars'>#{partial}</script>"
  end
end

error do
  <<-HTML
    <h1>HALP!</h1>
    <p>The shit hit the fan in such a way that I don't know what to do.</p>
    <p>The error message: #{request.env['sinatra.error'].message}</p>
  HTML
end

get "/" do
  erb :index
end

get '/app.js' do
  coffee :app
end

get '/style.css' do
  sass :style
end
