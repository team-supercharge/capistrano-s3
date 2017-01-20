module Capistrano
  module S3
    module Defaults
      DEFAULTS = {
        :deployment_path      => proc { Dir.pwd.gsub("\n", "") + "/public" },
        :bucket_write_options => { :acl => :public_read },
        :region               => 'us-east-1',
        :redirect_options     => {},
        :only_gzip            => false,
        :invalidations        => [],
        :exclusions           => []
      }

      def self.populate(context, set_method)
        DEFAULTS.each do |key, value|
          value = value.is_a?(Proc) ? value.call : value
          context.send(set_method, key, value)
        end
      end
    end
  end
end
