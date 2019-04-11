
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
    binding.pry
    if user.trackers.where(end_time: nil).exists?
      t = user.trackers.where(end_time: nil).first
      t.update_attribute(:end_time, DateTime.now)
      tracked_total = 
      return "Sucessfully Clocked out at: #{t.end_time}!\nYou spent a total of #{}"
    else
      t = Tracker.new(user_id: user.id, start_time: DateTime.now)
      t.save
      return "The clock started ticking at: #{t.start_time}!"
    end
  end

  def self.get_time(params, user)
    binding.pry
  end

  def self.get_all_time(params, user)
    binding.pry
  end

  def self.restart(params, user)
    binding.pry
  end
end