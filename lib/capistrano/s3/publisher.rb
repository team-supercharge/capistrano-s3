require 'aws/s3'
require 'mime/types'
require 'fileutils'

module Capistrano
  module S3
    module Publisher
      LAST_PUBLISHED_FILE = '.last_published'

      def self.publish!(s3_endpoint, key, secret, bucket, deployment_path, distribution_id, invalidations, exclusions, only_gzip, extra_options)
        deployment_path_absolute = File.expand_path(deployment_path, Dir.pwd)
        s3 = self.establish_s3_client_connection!(s3_endpoint, key, secret)
        updated = false

        self.files(deployment_path_absolute, exclusions).each do |file|
          if !File.directory?(file)
            next if self.published?(file)
            next if only_gzip && self.has_gzipped_version?(file)

            path = self.base_file_path(deployment_path_absolute, file)
            path.gsub!(/^\//, "") # Remove preceding slash for S3

            self.put_object(s3, bucket, path, file, only_gzip, extra_options)
          end
        end

        # invalidate CloudFront distribution if needed
        if distribution_id && !invalidations.empty?
          cf = self.establish_cf_client_connection!(key, secret)

          cf.create_invalidation({
            :distribution_id => distribution_id,
            :invalidation_batch => {
              :paths => {
                :quantity => invalidations.count,
                :items => invalidations
              },
              :caller_reference => SecureRandom.hex
            }
          })
        end

        FileUtils.touch(LAST_PUBLISHED_FILE)
      end

      def self.clear!(s3_endpoint, key, secret, bucket)
        s3 = self.establish_s3_connection!(s3_endpoint, key, secret)
        s3.buckets[bucket].clear!

        FileUtils.rm(LAST_PUBLISHED_FILE)
      end

      private

        # Establishes the connection to Amazon S3
        def self.establish_connection!(klass, s3_endpoint, key, secret)
          # Send logging to STDOUT
          AWS.config(:logger => ::Logger.new(STDOUT))
          klass.new(
            :s3_endpoint => s3_endpoint,
            :access_key_id => key,
            :secret_access_key => secret
          )
        end

        def self.establish_cf_client_connection!(key, secret)
          self.establish_connection!(AWS::CloudFront::Client, nil, key, secret)
        end

        def self.establish_s3_client_connection!(s3_endpoint, key, secret)
          self.establish_connection!(AWS::S3::Client, s3_endpoint, key, secret)
        end

        def self.establish_s3_connection!(s3_endpoint, key, secret)
          self.establish_connection!(AWS::S3, s3_endpoint, key, secret)
        end

        def self.base_file_path(root, file)
          file.gsub(root, "")
        end

        def self.files(deployment_path, exclusions)
          Dir.glob("#{deployment_path}/**/*") - Dir.glob(exclusions.map { |e| "#{deployment_path}/#{e}" })
        end

        def self.published?(file)
          return false unless File.exists? LAST_PUBLISHED_FILE
          File.mtime(file) < File.mtime(LAST_PUBLISHED_FILE)
        end

        def self.put_object(s3, bucket, path, file, only_gzip, extra_options)
          base_name = File.basename(file)
          mime_type = mime_type_for_file(base_name)
          options   = {
            :bucket_name => bucket,
            :key         => path,
            :data        => open(file),
            :acl         => :public_read,
          }

          options.merge!(build_redirect_hash(path, extra_options[:redirect]))
          options.merge!(extra_options[:write] || {})

          if mime_type
            options.merge!(build_content_type_hash(mime_type))

            if mime_type.sub_type == "gzip"
              options.merge!(build_gzip_content_encoding_hash)
              options.merge!(build_gzip_content_type_hash(file, mime_type))

              # upload as original file name
              options.merge!(key: self.orig_name(path)) if only_gzip
            end
          end

          s3.put_object(options)
        end

        def self.build_redirect_hash(path, redirect_options)
          return {} unless redirect_options && redirect_options[path]

          { :website_redirect_location => redirect_options[path] }
        end

        def self.build_content_type_hash(mime_type)
          { :content_type => mime_type.content_type }
        end

        def self.build_gzip_content_encoding_hash
          { :content_encoding => "gzip" }
        end

        def self.has_gzipped_version?(file)
          File.exist?(self.gzip_name(file))
        end

        def self.build_gzip_content_type_hash(file, mime_type)
          orig_name = self.orig_name(file)
          orig_mime = mime_type_for_file(orig_name)

          return {} unless orig_mime && File.exist?(orig_name)

          { :content_type => orig_mime.content_type }
        end

        def self.mime_type_for_file(file)
          type = MIME::Types.type_for(file)
          (type && !type.empty?) ? type[0] : nil
        end

        def self.gzip_name(file)
          "#{file}.gz"
        end

        def self.orig_name(file)
          file.sub(/\.gz$/, "")
        end
    end
  end
end
