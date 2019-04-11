# app.rb
require 'sinatra'
require 'sinatra/activerecord'
require 'pry-byebug'

configure { set :server, :puma }
set :database, {adapter: "sqlite3", database: "slack-time-tracker.sqlite3"}

Dir["./models/*.rb"].each {|file| require file }

get '/' do
  # @users = User.all
  {:hello => 'person!'}.to_json
end

post '/slack/tracker' do
  content_type 'application/json'
  @user = User.find_by(slack_user_id: params[:user_id])
  create_user(params) if @user.nil?
  case params[:text]
  when ""
    response_message = Tracker.get_time(params, @user)
    response = {
      "response_type": "ephemeral",
      "text": "#{response_message}"
    }
    response.to_json
  when "start"
    response_message = Tracker.start(params, @user)
    response = {
      "response_type": "ephemeral",
      "text": "#{response_message}"
    }
    response.to_json
  when "stop"
    response_message = Tracker.stop(params, @user)
    response = {
      "response_type": "ephemeral",
      "text": "#{response_message}"
    }
    response.to_json
  when "help"
    response_message = Tracker.help(params, @user)
    response = {
      "response_type": "ephemeral",
      "text": "See help below!",
      "attachments": [
          {
              "text":"Partly cloudy today and tomorrow"
          }
      ]
    }
    response.to_json
  else
  end
end

def create_user(params)
  @user = User.find_or_create_by(
    slack_user_id: params[:user_id],
    slack_team_id: params[:team_id],
  )
end