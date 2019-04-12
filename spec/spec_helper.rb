# spec/spec_helper.rb
require 'rack/test'
require 'rspec'
require 'database_cleaner'
require 'timecop'

ENV['RACK_ENV'] = 'test'

require File.expand_path '../../app.rb', __FILE__

module RSpecMixin
  include Rack::Test::Methods
  def app() Sinatra::Application end
end

RSpec.configure do |config| 
  config.include RSpecMixin
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end
end