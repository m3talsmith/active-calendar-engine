require "cgi"
require "uri"
require "net/http"
require "net/https"
require "open-uri"
require "nkf"
require "time"
require "active_support"

Net::HTTP.version_1_2

module ActiveCalendarEngine
  class Base
    # -- Constants --
      AUTHENTICATION_SERVER = "www.google.com"
      AUTHENTICATION_PATH   = "/accounts/ClientLogin"
      CALENDAR_LIST_PATH    = "http://#{AUTHENTICATION_SERVER}/calendar/feeds/default/allcalendars/full"
    # --
    
    def initialize
      preferences
      session
    end
    
    private
      
      def preferences
        unless @google_credentials
          @google_credentials ||= YAML.load_file("#{File.dirname(__FILE__)}/../../config/google_credentials.yml").to_options!
        end
        return @google_credentials
      end
      
      def session
        unless @authenticated_session
          https = Net::HTTP.new(AUTHENTICATION_SERVER, 443)
          https.use_ssl = true
          https.verify_mode = OpenSSL::SSL::VERIFY_NONE

          head = {'Content-Type' => 'application/x-www-form-urlencoded'}

          https.start do |socket|
            response = socket.post(AUTHENTICATION_PATH, "Email=#{preferences[:email]}&Passwd=#{CGI.escape(preferences[:password])}&source=active-calendar-engine&service=cl", head)
            if response.body =~ /Auth=(.+)/
              @active_session = $1
            else
              raise AuthenticationFailed
            end
          end

        end
        return @athenticated_session
      end

  end
end