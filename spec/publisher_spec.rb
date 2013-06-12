require 'spec_helper'

describe Publisher do
  before do
    @root = File.expand_path('../', __FILE__)
    FileUtils.rm(Publisher::LAST_PUBLISHED_FILE) if File.exist?(Publisher::LAST_PUBLISHED_FILE)
  end

  context "on publish!" do
    it "publish all files" do
      AWS::S3::Client.any_instance.expects(:put_object).times(4)

      path = File.join(@root, 'sample')
      Publisher.publish!('s3.amazonaws.com', 'abc', '123', 'mybucket.amazonaws.com', path, {})
    end
  end
end