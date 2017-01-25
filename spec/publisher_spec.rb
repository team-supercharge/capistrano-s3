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
      Capistrano::S3::Publisher.publish!('s3.amazonaws.com', 'abc', '123', 'mybucket.amazonaws.com', './spec/sample', 'cf123', [], [], false, {})
    end

    it "publish only gzip files when option is enabled" do
      AWS::S3::Client::V20060301.any_instance.expects(:put_object).times(4)
      Capistrano::S3::Publisher.publish!('s3.amazonaws.com', 'abc', '123', 'mybucket.amazonaws.com', 'spec/sample', 'cf123', [], [], true, {})
    end

    context "invalidations" do
      it "publish all files with invalidations" do
        AWS::S3::Client::V20060301.any_instance.expects(:put_object).times(8)
        AWS::CloudFront::Client::V20141106.any_instance.expects(:create_invalidation).once

        Capistrano::S3::Publisher.publish!('s3.amazonaws.com', 'abc', '123', 'mybucket.amazonaws.com', 'spec/sample/', 'cf123', ['*'], [], false, {})
      end

      it "publish all files without invalidations" do
        AWS::S3::Client::V20060301.any_instance.expects(:put_object).times(8)
        AWS::CloudFront::Client::V20141106.any_instance.expects(:create_invalidation).never

        Capistrano::S3::Publisher.publish!('s3.amazonaws.com', 'abc', '123', 'mybucket.amazonaws.com', './spec/sample/', 'cf123', [], [], false, {})
      end
    end

    context "exclusions" do
      it "exclude one files" do
        AWS::S3::Client::V20060301.any_instance.expects(:put_object).times(7)

        exclude_paths = ['fonts/cantarell-regular-webfont.svg']
        Capistrano::S3::Publisher.publish!('s3.amazonaws.com', 'abc', '123', 'mybucket.amazonaws.com', 'spec/sample', 'cf123', [], exclude_paths, false, {})
      end

      it "exclude multiple files" do
        AWS::S3::Client::V20060301.any_instance.expects(:put_object).times(6)

        exclude_paths = ['fonts/cantarell-regular-webfont.svg', 'fonts/cantarell-regular-webfont.svg.gz']
        Capistrano::S3::Publisher.publish!('s3.amazonaws.com', 'abc', '123', 'mybucket.amazonaws.com', 'spec/sample', 'cf123', [], exclude_paths, false, {})
      end

      it "exclude directory" do
        AWS::S3::Client::V20060301.any_instance.expects(:put_object).times(0)

        exclude_paths = ['fonts/**/*']
        Capistrano::S3::Publisher.publish!('s3.amazonaws.com', 'abc', '123', 'mybucket.amazonaws.com', 'spec/sample', 'cf123', [], exclude_paths, false, {})
      end
    end


  end
end
