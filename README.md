# Berghs + Instagram = APIs

This is the tutorial for the Berghs School of Communication class on
using an API. In this tutorial we will use the Instagram API to find all
pictures taken at Berghs and display their thumbnails. If we have time
we will also link the hashtags to Twitter.

## Hello, world!

Most programming tutorials start off with a program that displays the message
"Hello, world", so let's stick with that tradition and start with a simple Web
site that just says "Hello, world". Once that's working we can expand it to
display Instagram photos using the API.

### Install the tools

Install the Sinatra Web framework. In your Terminal app, type:

    gem install sinatra

### Build the Web site

Open a text editor (if you don't have one, you can try
[SublimeText](http://www.sublimetext.com/2)) and write the following into a file
names `berghs_instagram.rb`:

    require "sinatra"

    get "/" do
      "Hello, world!"
    end

### Run it

Start your Web site server. In your Terminal app, type the following:

    ruby berghs_instagram.rb

Visit your Web site: [http://localhost:4567/](http://localhost:4567/)

## Logging in to Instagram

Congratulations! You just built your first Web site. Now that it's working,
let's extend it to use the Instgram API.

### Install the Instagram library

In your Terminal, type:

    gem install instagram

### Register your app with Instagram

Register your new app (Instagram calls this a Client) on the Instagram website:
[http://instagram.com/developer/clients/register/](http://instagram.com/developer/clients/register/)

    Application Name: Photos at Berghs by YOUR NAME
    Description: Pictures at and around Berghs.
    Website: http://localhost:4567/
    OAuth redirect_url: http://localhost:4567/oauth/callback

Save your client ID and client secret so you can use it from your
program later. In the Terminal app, type this:

    echo export INSTAGRAM_CLIENT_ID=YOUR_CLIENT_ID >> ~/.bashrc
    echo export INSTAGRAM_CLIENT_SECRET=YOUR_CLIENT_SECRET >> ~/.bashrc
    source ~/.bashrc

### Logging in to Instagram

Before we can get photos from the Instagram API, we need to ask the people
visiting our Web site to log in to their Instagram account and give our Web site
permission to access their information.

Edit your `berghs_instagram.rb` file so that it looks like this:

    require "sinatra"
    require "instagram"
    
    enable :sessions
    
    CALLBACK_URL = "http://localhost:4567/oauth/callback"
    
    Instagram.configure do |config|
      config.client_id = ENV['INSTAGRAM_CLIENT_ID']
      config.client_secret = ENV['INSTAGRAM_CLIENT_SECRET']
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
      "You have logged in"
    end

Run the server again to make sure that you can log in to your Instagram account.

## Displaying photos

Now we have all of the pieces in place to display photos from Instagram.

Edit your `berghs_instagram.rb` file one more time:

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
      config.client_id = ENV['INSTAGRAM_CLIENT_ID']
      config.client_secret = ENV['INSTAGRAM_CLIENT_SECRET']
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

Run the server again, and this time when you log in to your Instagram account
you should see beautiful photos taken at Berghs.
