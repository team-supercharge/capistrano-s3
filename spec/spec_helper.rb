require 'capistrano/s3/publisher'
require 'mocha/api'

AWS.stub!

RSpec.configure do |config|
  config.mock_framework = :mocha
end