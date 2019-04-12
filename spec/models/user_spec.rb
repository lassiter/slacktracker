require File.expand_path '../../spec_helper.rb', __FILE__

RSpec.describe User, :type => :model do
  subject { described_class.new }

  it "is valid with valid attributes" do
    subject.slack_team_id = "Anything"
    subject.slack_user_id = "Anything"
    expect(subject).to be_valid
  end

  it "is not valid without a team id" do
    subject.slack_team_id = "Anything"
    expect(subject).to_not be_valid
  end

  it "is not valid without a user id" do
    subject.slack_user_id = "Anything"
    expect(subject).to_not be_valid
  end
end