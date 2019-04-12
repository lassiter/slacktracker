# spec/app_spec.rb
require File.expand_path '../spec_helper.rb', __FILE__

describe "Slack Tracker Plain Text" do
  it "should allow accessing the home page" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to eq("Hello! Slack Tracker is running!")
  end
end

describe "Valid Slack Tracker Endpoint 'slack/tracker' " do
  before do
    @endpoint = "slack/tracker"
  end
  let(:valid_params_of_non_created_user) do
    {
      "token"=>"nRsdsD7swhrLsadasRrpYKQce",
      "team_id"=>"TXRFCN98K",
      "team_domain"=>"exampleteam",
      "channel_id"=>"CPKBW8SLL",
      "channel_name"=>"slack-apps",
      "user_id"=>"WJ2R5UXYZ",
      "user_name"=>"someusers",
      "command"=>"/slacktracker",
      "response_url"=>"https://hooks.slack.com/commands/TXRFCN98K/111111111111/blerg1231JSADKAS",
      "trigger_id"=>"324165646501.546465421132.5246501032498415"
    }
  end
  let(:valid_params_of_existing_user) do
    {
      "token"=>"nRsdsD7swhrLsadasRrpYKQce",
      "team_id"=>"TXRN98KFC",
      "team_domain"=>"exampleteam",
      "channel_id"=>"CPK8SLLBW",
      "channel_name"=>"slack-apps",
      "user_id"=>"UXYZWJ2R5",
      "user_name"=>"someusers",
      "command"=>"/slacktracker",
      "response_url"=>"https://hooks.slack.com/commands/TXRN98KFC/111111111111/blerg1231JSADKAS",
      "trigger_id"=>"324165646501.546465421132.5246501032498415"
    }
  end
  let(:invalid_params) do
    {
      "token"=>"nRsdsD7swhrLsadasRrpYKQce",
      "team_domain"=>"exampleteam",
      "channel_id"=>"CPK8SLLBW",
      "channel_name"=>"slack-apps",
      "user_name"=>"someusers",
      "command"=>"/slacktracker",
      "response_url"=>"https://hooks.slack.com/commands/TXRN98KFC/111111111111/blerg1231JSADKAS",
      "trigger_id"=>"324165646501.546465421132.5246501032498415"
    }
  end
  context 'User creation tests' do
    it 'creates a new user if they do not exist' do
      params = valid_params_of_non_created_user
      params[:text] = ""
      expect { post @endpoint, params }.to change(User, :count)
    end
    it 'does not create a new user if they do exist' do
      params = valid_params_of_existing_user
      params[:text] = ""
      User.find_or_create_by(slack_user_id: params["user_id"], slack_team_id: params["team_id"])
      expect { post @endpoint, params }.to_not change(User, :count)
    end
    it 'does not create a new user if params are invalid' do
      params = invalid_params
      params[:text] = ""
      expect { post @endpoint, params: params }.to_not change(User, :count)
      expect(last_response.status).to eq(400)
    end
    it 'does not create a new user if params are empty' do
      expect { post @endpoint, {} }.to_not change(User, :count)
      expect(last_response.status).to eq(400)
    end
  end
  context 'params[:text] is empty' do
    before(:each) do
      Tracker.delete_all
      @params = valid_params_of_existing_user
      @user = User.find_or_create_by(slack_user_id: @params["user_id"], slack_team_id: @params["team_id"])
      @params[:text] = ""
    end
    it 'inform tracker is not running' do
      post @endpoint, @params
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)["text"]).to eq("Looks like you're not tracking anything!\nType \"/slacktracker start\" to start tracking your time.")
    end
    it 'inform how to stop tracker and time since start' do
      @user.trackers.create(start_time: 50.minutes.ago)
      post @endpoint, @params
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)["text"]).to eq("You've been working for: 50 Minutes\nType \"/slacktracker stop\" to stop tracking your time.")
    end
  end
  context 'params[:text] is start' do
    before(:each) do
      Tracker.delete_all
      @params = valid_params_of_existing_user
      @user = User.find_or_create_by(slack_user_id: @params["user_id"], slack_team_id: @params["team_id"])
      @params[:text] = "start"
    end
    it 'start the tracker' do
      post @endpoint, @params
      expect(last_response.status).to eq(200)
      parsed_response = JSON.parse(last_response.body)["text"]
      expect(parsed_response).to include(@user.trackers.last.start_time.to_s)
      expect(parsed_response).to include("The clock started ticking at: ")
    end
    it 'the tracker is already running' do
      @user.trackers.create(start_time: 50.minutes.ago)
      post @endpoint, @params
      parsed_response = JSON.parse(last_response.body)["text"]
      expect(parsed_response).to include(@user.trackers.last.start_time.to_s)
      expect(parsed_response).to include("It looks like you're alredy on the clock!\nStarting at ")
    end
  end
  context 'params[:text] is stop' do
    before(:each) do
      Tracker.delete_all
      @params = valid_params_of_existing_user
      @user = User.find_or_create_by(slack_user_id: @params["user_id"], slack_team_id: @params["team_id"])
      @params[:text] = "stop"
    end
    it 'there is nothing to stop' do
      post @endpoint, @params
      expect(last_response.status).to eq(200)
      parsed_response = JSON.parse(last_response.body)["text"]
      expect(parsed_response).to eq("There is nothing to stop!\nType \"/slacktracker start\" to start tracking your time.")
    end
    it 'stop the tracker' do
      @user.trackers.create(start_time: 50.minutes.ago)
      post @endpoint, @params
      parsed_response = JSON.parse(last_response.body)["text"]
      tracker = @user.trackers.last
      expect(parsed_response).to include(TimeDifference.between(tracker.start_time, tracker.end_time).humanize)
      expect(parsed_response).to include(tracker.end_time.to_s)
      expect(parsed_response).to include("Sucessfully Clocked out at: ")
      expect(parsed_response).to include("Time Spent: ")
    end
  end
  context 'params[:text] is restart' do
    before(:each) do
      Tracker.delete_all
      @params = valid_params_of_existing_user
      @user = User.find_or_create_by(slack_user_id: @params["user_id"], slack_team_id: @params["team_id"])
      @params[:text] = "restart"
    end
    it 'there is nothing to restart' do
      post @endpoint, @params
      expect(last_response.status).to eq(200)
      parsed_response = JSON.parse(last_response.body)["text"]
      expect(parsed_response).to eq("There is nothing to restart!\nType \"/slacktracker start\" to start tracking your time.")
    end
    it 'restart the tracker' do
      first_instance_of_tracker = @user.trackers.create(start_time: 50.minutes.ago)
      post @endpoint, @params
      parsed_response = JSON.parse(last_response.body)["text"]
      tracker = @user.trackers.last
      expect(tracker.start_time).to_not eq(first_instance_of_tracker.start_time)
      expect(parsed_response).to include(tracker.start_time.to_s)
      expect(parsed_response).to include("Restarting the clock at a start time of: ")
    end
  end
  context 'params[:text] is total' do
    before(:each) do
      Tracker.delete_all
      @params = valid_params_of_existing_user
      @user = User.find_or_create_by(slack_user_id: @params["user_id"], slack_team_id: @params["team_id"])
      @params[:text] = "total"
    end
    it 'the tracker is active' do
      Timecop.freeze(DateTime.now) do
        # 60 * 60 * 2 = 7200
        t1 = @user.trackers.create(start_time: 3.hours.ago, end_time: 1.hours.ago)
        # 10 * 60 = 600
        t2 = @user.trackers.create(start_time: 10.minutes.ago)
        total_expected_seconds = 7800
        seconds = 0
        seconds += TimeDifference.between(t1.start_time, t1.end_time).in_seconds
        seconds += TimeDifference.between(t2.start_time, DateTime.now).in_seconds
        expect(seconds).to eq(total_expected_seconds)
        post @endpoint, @params
        tracker = @user.trackers.last
        expect(last_response.status).to eq(200)
        parsed_response = JSON.parse(last_response.body)["text"]
        expect(parsed_response).to eq("The total of all of your tracked time is: #{Time.at(seconds).utc.strftime("%H:%M:%S")}\nYou're still on the clock from when you started tracking at: #{tracker.start_time}.")
      end
    end
    it 'the tracker is inactive' do
      t1 = @user.trackers.create(start_time: 3.hours.ago, end_time: 1.hours.ago)
      seconds = 0
      seconds += TimeDifference.between(t1.start_time, t1.end_time).in_seconds
      post @endpoint, @params
      parsed_response = JSON.parse(last_response.body)["text"]
      expect(parsed_response).to eq("The total of all of your tracked time is: #{Time.at(seconds).utc.strftime("%H:%M:%S")}")
    end
  end
  context 'params[:text] is help' do
    before(:each) do
      Tracker.delete_all
      @params = valid_params_of_existing_user
      @params[:text] = "help"
    end
    it 'should explain the options' do
      post @endpoint, @params
      parsed_response = JSON.parse(last_response.body)["text"]
      expect(parsed_response).to eq("These are the command you can type:\n'/slacktracker' which will show the time spent on the current task\n'/slacktracker help' which show what you're currently seeing\n'/slacktracker start' which will start the tracker\n'/slacktracker stop' which will stop the tracker\n'/slacktracker restart' which will reset the tracker start time\n'/slacktracker total' which will tell you all of your tracked time")
    end
  end
end