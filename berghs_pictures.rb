require 'sinatra'
require 'instagram'

enable :sessions

CALLBACK_URL = "http://localhost:4567/oauth/callback"
BERGHS_SCHOOL_OF_COMMUNICATION = {
  id: 590635,
  latitude: 59.336326,
  longitude: 18.063649
}

Instagram.configure do |config|
  config.client_id = "8895c5c94ed54c05800781b45df53d7f"
  config.client_secret = "62692f53ec2841698eb3a3c4a4332d17"
end

get "/" do
  '<a href="/oauth/connect">Connect with Instagram</a>'
end

get "/oauth/connect" do
  redirect Instagram.authorize_url(redirect_uri: CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], redirect_uri: CALLBACK_URL)
  session[:access_token] = response.access_token
  redirect "/dashboard"
end

get "/dashboard" do
  puts "Using access token: #{session[:access_token]}"
  client = Instagram.client(access_token: session[:access_token])
  media = client.location_recent_media(BERGHS_SCHOOL_OF_COMMUNICATION[:id])

  html = "<h1>Berghs-tastic media</h1>"
  media.each do |medium|
    html << '<p style="float: left; border: 1px solid gray; padding: 0.25em">'
    html << "<img src='#{medium.images.thumbnail.url}'><br>"
    html << '</p>'
  end
  html
end
