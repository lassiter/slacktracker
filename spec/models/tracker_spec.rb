require File.expand_path '../../spec_helper.rb', __FILE__

RSpec.describe Tracker, :type => :model do
  subject { described_class.new }

  it "is valid with valid attributes" do
    subject.start_time = DateTime.now
    subject.end_time = DateTime.now
    subject.user_id = 1
    expect(subject).to be_valid
  end

  it "is valid with valid start_time and user_id" do
    subject.start_time = DateTime.now
    subject.user_id = 1
    expect(subject).to be_valid
  end

  it "is not valid without start_time" do
    subject.end_time = DateTime.now
    subject.user_id = 1
    expect(subject).to_not be_valid
  end

  it "is not valid without user_id" do
    subject.start_time = DateTime.now
    subject.end_time = DateTime.now
    expect(subject).to_not be_valid
  end
end