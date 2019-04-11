require 'time_difference'
class Tracker < ActiveRecord::Base
  belongs_to :user


  def self.start(params, user)
    if user.trackers.where(end_time: nil).exists?
      return "It looks like you're alredy on the clock!\nStarting at #{user.trackers.where(end_time: nil).first.start_time}!"
    else
      t = Tracker.new(user_id: user.id, start_time: DateTime.now)
      t.save
      return "The clock started ticking at: #{t.start_time}!"
    end
  end

  def self.stop(params, user)
    if user.trackers.where(end_time: nil).exists?
      t = user.trackers.where(end_time: nil).first
      t.update_attribute(:end_time, DateTime.now)
      tracked_total = TimeDifference.between(t.start_time, t.end_time).humanize
      return "Sucessfully Clocked out at: #{t.end_time}!\nTime Spent: #{tracked_total}."
    else
      t = Tracker.new(user_id: user.id, start_time: DateTime.now)
      t.save
      return "The clock started ticking at: #{t.start_time}!"
    end
  end

  def self.get_time(params, user)
    if user.trackers.where(end_time: nil).exists?
      t = user.trackers.where(end_time: nil).last
      return "You've been working for: #{TimeDifference.between(t.start_time, DateTime.now).humanize}\nType \"/slacktracker stop\" to stop tracking your time."
    else
      return "Looks like you're not tracking anything!\nType \"/slacktracker start\" to start tracking your time."
    end
  end

  def self.get_all_time(params, user)
    array_of_trackers = user.trackers.where.not(end_time: nil)
    seconds = 0
    array_of_trackers.each do |t|
      seconds += TimeDifference.between(t.start_time, t.end_time).in_seconds
    end
    if user.trackers.where(end_time: nil).exists?
      tracker = user.trackers.where(end_time: nil).last
      seconds += TimeDifference.between(tracker.start_time, DateTime.now).in_seconds
      return "The total of all of your tracked time is: #{Time.at(seconds).utc.strftime("%H:%M:%S")}\nYou're still on the clock from when you started tracking at: #{tracker.start_time}."
    else
      return "The total of all of your tracked time is: #{Time.at(seconds).utc.strftime("%H:%M:%S")}"
    end
  end

  def self.restart(params, user)
    if user.trackers.where(end_time: nil).exists?
      t = user.trackers.where(end_time: nil).last
      t.update_attribute(:start_time, DateTime.now)
      return "Restarting the clock at a start time of: #{t.start_time}!"
    else
      return "There is nothing to restart!"
    end
  end
end