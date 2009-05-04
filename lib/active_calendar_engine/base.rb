require "active_support"
require "active_calendar_engine/tools/accessor"

Net::HTTP.version_1_2

module ActiveCalendarEngine
  
  class Base
    extend Accessor
    include Accessor
    
    # -- Constants --
      AUTHENTICATION_SERVER = "https://www.google.com:443"
      AUTHENTICATION_PATH   = "/accounts/ClientLogin"
    # --
    
    # -- Default Accessors --
      attr_accessors :google_service, :google_feed
    # --
    
    class << self
      
      def find(*args)
        options = args.extract_options!
        find_or_setup_default_options(options)

        case args.first
        when :all
          response, data = get_authenticated_feed(@google_feed)
          @data = {:response => response, :data => data}
        end

        return @data ? @data : false
      end
      
      def has_google_options(*args)
        google_options(args.extract_options!)
      end
    end
    
    private
      class << self
        
        def google_options(options)
          options.each_pair do |key, value|
            instance_variable_set("@#{key}", value)
          end
        end
        
        def find_or_setup_default_options(options = nil)
          @google_service ||= nil
          @google_feed    ||= nil
          
          self.google_options options
        end
        
        def preferences
          unless @google_credentials
            @google_credentials ||= YAML.load_file("#{File.dirname(__FILE__)}/../../config/google_credentials.yml").to_options!
          end
          return @google_credentials
        end
        
        def session
          unless @authenticated_session
            secure_uri      = URI.parse(AUTHENTICATION_SERVER + AUTHENTICATION_PATH)
            secure_data     = \
              "accountType=HOSTED_OR_GOOGLE" \
              "&Email=#{preferences[:email]}" \
              "&Passwd=#{preferences[:password]}" \
              "&source=ActiveCalendarEngine-0001" \
              "&service=#{@google_service}"

            secure_headers  = {
              "Content-Type"    => "application/x-www-form-urlencoded",
              "Content-length"  => "#{secure_data.length + 1}",
              "GData-Version"   => "2"
            }
            
            https = Net::HTTP.new(secure_uri.host, secure_uri.port)
            https.use_ssl = true
            https.verify_mode = OpenSSL::SSL::VERIFY_NONE
            
            response = https.post(secure_uri.path, secure_data, secure_headers)
            
            if response.body =~ /Auth=(.+)/
              @authenticated_session = $1
            else
              raise \
                "Authentication Failed:\n" \
                "\tURI: #{secure_uri.host}#{secure_uri.path}\n"\
                "\tData: #{secure_data}\n" \
                "\tHeader: #{secure_headers}" \
                "\tResponse: #{response.message}"
            end

          end

          return @authenticated_session
        end
        
        def get_feed(uri = "", headers = {})
          
          uri = URI.parse(uri)
          
          unless @gsession_url && @gsession_id
            http = Net::HTTP.new(uri.host, uri.port)
            initial_response = http.get(uri.path, headers)

            if initial_response.body =~ /The document has moved <A HREF=\"(.+)\?gsessionid=(.+)\">here<\/A>./
              @gsession_url = $1
              @gsession_id = $2
            else
              raise \
                "Can't load feed:\n" \
                "\tURI: #{uri.host}#{uri.path}\n" \
                "\tHeader: #{headers}\n" \
                "\tResponse: #{initial_response.value} - #{initial_response.message}"
            end
          end
          
          uri = URI.parse(@gsession_url)
          response = http.get("#{uri.path}?gsessionid=#{@gsession_id}", headers)
          
          if response.body =~ /xmlns:gCal/
            return response
          else
            raise \
              "Can't load feed:\n" \
              "\tURI: #{uri.host}#{uri.path}?gsessionid=#{@gsession_id}\n" \
              "\tHeader: #{headers}\n" \
              "\tResponse: #{response.value} - #{response.message}"
          end
        end
        
        def get_authenticated_feed(uri = "")
          headers     = {
            "GData-Version"   => "2",
            "Authorization"   => "GoogleLogin auth=#{session}"
          }
          
          response = get_feed(uri, headers)
          
          return response
        end
      end # class << self
    # private
  end
end