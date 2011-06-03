require 'aws/s3'

module Astrails
  module Clicktale
    module Controller

      def self.included(base)
        base.class_eval do
          @@clicktale_options = {}
          after_filter :clicktaleize
          helper_method :clicktale_enabled?
          helper_method :clicktale_config
          helper_method :clicktale_path
          helper_method :clicktale_url
        end
        base.send(:extend, ClassMethods)
      end

      module ClassMethods
        def clicktale(opts = {})
          @@clicktale_options = opts
        end
      end

      def clicktale(opts = {})
        @clicktale_options = opts
      end

      def clicktaleize
        AWS::S3::S3Object.store(clicktale_path, render_to_string, S3_CONFIG[:bucket])
      end

      def clicktale_enabled?
        @clicktale_enabled ||= clicktale_config[:enabled] && request.format.try(:html?) && request.get?
      end

      def clicktale_config
        @clicktale_config ||= Astrails::Clicktale::CONFIG.merge(@@clicktale_options || {}).merge(@clicktale_options || {})
      end


      protected

      def clicktale_cache_token(extra = "")
        @clicktale_cache_token ||= Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join + extra)
      end

      def clicktale_path
        @clicktale_path ||= "/clicktale/#{clicktale_cache_token}.html"
      end

      def clicktale_url
        @clicktale_url ||= AWS::S3::S3Object.url_for(clicktale_path, S3_CONFIG[:bucket]).html_safe
      end

    end
  end
end
