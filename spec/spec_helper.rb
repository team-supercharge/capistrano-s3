require 'capistrano/s3/publisher'
require 'mocha/api'

Aws.config[:stub_responses] = true

RSpec.configure do |config|
  config.mock_framework = :mocha
end
