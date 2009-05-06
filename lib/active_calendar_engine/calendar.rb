require 'active_calendar_engine/event'

class Event < ActiveCalendarEngine::Event; end

module ActiveCalendarEngine
  class Calendar < ActiveCalendarEngine::Base
    
    has_google_options :google_service => "cl", :google_feed => "http://www.google.com/calendar/feeds/default/allcalendars/full"
    
    attr_accessors(
      :links, :author,
      :published_on, :updated_on, :title,
      :timezone, :access_level, :summary, :raw_data, :events
    )
    
    def initialize(*args)
      initialize_calendar_properties
      
      attributes = args.extract_options!
      attributes.each_pair do |key, value|
        instance_variable_set("@#{key}", value) if instance_variable_get("@#{key}")
      end
    end
    
    def to_s
      self.inspect
    end
    
    def events
      @events ||= Event.find_and_extract_events( self.links[:alternate] )
    end
    
    class << self
      
      def calendars
        return self.find(:all)
      end
      
      def find(*args)
        options = args.extract_options!
        
        case args.first
        when :all
          super args.first, options
          return parse_calendar_data(@data[:data])
        when :first
          super self.unescape_id(args.first)
          return parse_single_calendar(@data[:data])
        else
          super self.unescape_id(args.first)
          return parse_single_calendar(@data[:data])
        end
      end
        
    end
    
    private
    
      def initialize_calendar_properties
        @links        = {}
        @author       = {:email => "", :name => ""}
        @id           = String.new
        @title        = String.new
        @summary      = String.new
        @timezone     = String.new("American/New_York")
        @access_level = String.new("owner")
        %w(published updated).each do |dated|
          instance_variable_set("@#{dated}_on", Time.now.xmlschema)
        end
        @raw_data     = ""
      end
      
      class << self
        def parse_single_calendar(data)
          return self.parse_calendar_data(data).first
        end
        
        def parse_calendar_data(data)
          calendars = []
          document = Nokogiri::XML.parse(data)
          
          document.css('entry').each do |entry|
            # -- Author and Link data --
            # I created these seperate of the Calendar.new method because I'm
            # too lazy to do the whole loop interaction through a collect etc.
            author_data = {}
            entry.css('author').first.children.each do |child|
              author_data[eval(":#{child.name}")] = child.text unless child.name == "text"
            end
            
            link_data = {}
            entry.css('link').each do |link|
              unless link.attribute('rel').value =~ /http/
                link_data[eval(":#{link.attribute('rel').value}")] = link.attribute('href').value
              end
            end
            # --
            
            calendar = self.new(
              :raw_data     => entry,
              :author       => author_data,
              :access_level => "#{entry.xpath('//gCal:accesslevel').first.attribute('value')}",
              :summary      => (entry.xpath('//summary').length > 0 ? entry.xpath('//summary').first.content : nil),
              :title        => entry.css('title').first.content,
              :timezone     => "#{entry.xpath('//gCal:timezone').first.attribute('value')}",
              :published_on => entry.css('published').first.content,
              :updated_on   => entry.css('updated').first.content,
              :links        => link_data
            )
            calendar.id = link_data[:self]
            
            calendars << calendar
          end
          
          return calendars
        end
             
      end # class << self
    # private
  end
end