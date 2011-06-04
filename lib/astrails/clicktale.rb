require 'active_support/all'
require 'action_view'
require 'astrails/clicktale/controller'
require 'astrails/clicktale/helper'

module Astrails
  module Clicktale

    S3_CONFIG = YAML.load_file(Rails.root.join('config', 's3.yml'))[Rails.env].symbolize_keys
    
    def self.init
      ActionController::Base.append_view_path(File.dirname(__FILE__) + "/../../app/views") if ActionController::Base.respond_to?(:append_view_path)
      ActionController::Base.send(:include, Astrails::Clicktale::Controller)
      ActionView::Base.send(:include, Astrails::Clicktale::Helper)
      unless AWS::S3::Base.connected?
        AWS::S3::Base.establish_connection!(:access_key_id => S3_CONFIG[:access_key_id],
                                            :secret_access_key => S3_CONFIG[:secret_access_key])
      end
    end

    CONFIG = HashWithIndifferentAccess.new
    begin
      conffile = File.join(RAILS_ROOT, "config", "clicktale.yml")
      conf = YAML.load(File.read(conffile))
      CONFIG.merge!(conf[RAILS_ENV])
    rescue
      puts "*" * 50
      puts "#{conffile} can not be loaded:"
      puts $!
      puts "*" * 50
    end

  end
end
