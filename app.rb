#!ruby
require 'faraday'
require 'sinatra'
require 'ringcentral_sdk'

# Enter config in .env file

client = RingCentralSdk::REST::Client.new
config = RingCentralSdk::REST::Config.new.load_dotenv
client.set_app_config config.app
client.authorize_user config.user

get '/' do
  'Simple Media Proxy'
end

get %r{/(([\w.]+)/restapi/v1.0/account/[\w]+/extension/[\w]+/message-store/[\w]+/content/[\w]+).mp3} do
  conn = Faraday.new(url: "https://#{params[:captures[1]]}") do |faraday|
    faraday.response :logger
    faraday.adapter  Faraday.default_adapter
  end

  url = "https://#{params[:captures][0]}?access_token=" + client.token.token.to_s
  res = conn.get url
  response.headers['Content-Type'] = res.headers['Content-Type']
  res.body
end

