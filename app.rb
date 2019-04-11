# app.rb
require 'sinatra'
require 'sinatra/activerecord'
require 'pry-byebug'

configure { set :server, :puma }
set :database, {adapter: "sqlite3", database: "slack-time-tracker.sqlite3"}

Dir["./models/*.rb"].each {|file| require file }

get '/' do
  "Hello! Slack Tracker is running!"
end

post '/slack/tracker' do
  content_type 'application/json'
  @user = User.find_by(slack_user_id: params[:user_id])
  create_user(params) if @user.nil?
  case params[:text]
  when ''
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
  when "restart"
    response_message = Tracker.restart(params, @user)
    response = {
      "response_type": "ephemeral",
      "text": "#{response_message}"
    }
    response.to_json
  when 'total'
    response_message = Tracker.get_all_time(params, @user)
    response = {
      "response_type": "ephemeral",
      "text": "#{response_message}"
    }
    response.to_json
  when 'help'
    response = {
      "response_type": "ephemeral",
      "text": "These are the command you can type:\n'/slacktracker' which will show the time spent on the current task\n'/slacktracker help' which show what you're currently seeing\n'/slacktracker start' which will start the tracker\n'/slacktracker stop' which will stop the tracker\n'/slacktracker restart' which will reset the tracker start time\n'/slacktracker total' which will tell you all of your tracked time"
    }.to_json
  else
  end
end

def create_user(params)
  @user = User.find_or_create_by(
    slack_user_id: params[:user_id],
    slack_team_id: params[:team_id],
  )
end