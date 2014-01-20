# Berghs + Instagram = APIs

This is the tutorial for the Berghs School of Communication class on
using an API. In this tutorial we will use the Instagram API to find all
pictures taken at Berghs and display their thumbnails. If we have time
we will also link the hashtags to Twitter.

## Register your app

Register your new app (Instagram calls this a Client).
http://instagram.com/developer/clients/register/

    Application Name: Photos at Berghs by YOUR NAME
    Description: Pictures at and around Berghs.
    Website: http://localhost:4567/
    OAuth redirect_url: http://localhost:4567/oauth/callback

Save your client ID and client secret so you can use it from your
program later. In the Terminal app, type this:

    echo export CLIENT_ID=YOUR_CLIENT_ID >> ~/.bashrc
    echo export CLIENT_SECRET=YOUR_CLIENT_SECRET >> ~/.bashrc
    . ~/.bashrc

# Install the tools

Install the Instagram library. In your Terminal app, type:

    gem install instagram
    gem install sinatra

# Build an app

Write your first Instagram Web application. Open SublimeText and write
the following into a file named `berghs_instagram.rb`:

    require "sinatra"
    require "instagram"
    
    enable :sessions
    
    CALLBACK_URL = "http://localhost:4567/oauth/callback"
    BERGHS_SCHOOL_OF_COMMUNICATION = {
      id: 590635,
      latitude: 59.336326,
      longitude: 18.063649
    }
    
    Instagram.configure do |config|
      config.client_id = ENV['CLIENT_ID']
      config.client_secret = ENV['CLIENT_SECRET']
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

# Run it

Start your server. In your Terminal app, type the following:

    ruby berghs_instagram.rb

Visit your Web site: http://localhost:4567/
