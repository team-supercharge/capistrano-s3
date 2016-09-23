require 'spec_helper'

describe Capistrano::S3::Publisher do
  before do
    @root = File.expand_path('../', __FILE__)
    publish_file = Capistrano::S3::Publisher::LAST_PUBLISHED_FILE
    FileUtils.rm(publish_file) if File.exist?(publish_file)
  end

  context "on publish!" do
    it "publish all files" do
      AWS::S3::Client::V20060301.any_instance.expects(:put_object).times(8)

      path = File.join(@root, 'sample')
      Capistrano::S3::Publisher.publish!('s3.amazonaws.com', 'abc', '123', 'mybucket.amazonaws.com', path, false, {})
    end

    it "publish only gzip files when option is enabled" do
      AWS::S3::Client::V20060301.any_instance.expects(:put_object).times(4)

      path = File.join(@root, 'sample')
      Capistrano::S3::Publisher.publish!('s3.amazonaws.com', 'abc', '123', 'mybucket.amazonaws.com', path, true, {})
    end
  end
end
