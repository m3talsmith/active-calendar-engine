module ActiveCalendarEngine
  class Event < ActiveCalendarEngine::Base
    
    has_google_options :google_service => "cl", :google_feed => "http://www.google.com/calendar/feeds/default/allcalendars/full"
    
    attr_accessors(
      :published_on, :updated_on, :title, :content, :links, :author,
      :event_status, :who, :where, :when, :raw_data, :comments
    )
    
    def initialize(*args)
      initialize_event_properties
      
      attributes = args.extract_options!
      attributes.each_pair do |key, value|
        instance_variable_set("@#{key}", value) if instance_variable_get("@#{key}")
      end
    end
    
    class << self
      
      def find(*args)
        super self.unescape_id(args.first)
        return parse_event_data(@data[:data])
      end
      
      def extract_events(data)
        return self.parse_event_data(data)
      end
      
      def find_and_extract_events(feed)
        return self.find(feed)
      end
      
    end
      
    private
    
      def initialize_event_properties
        @links        = {}
        @comments     = []
        @author       = {:email => "", :name => ""}
        @who          = [] # {:email => "", :name => "", :status => ""}
        @where        = String.new
        @when         = {}
        @event_status = "confirmed"
        @id           = String.new
        @title        = String.new
        @content      = String.new
        %w(published updated).each do |dated|
          instance_variable_set("@#{dated}_on", Time.now.xmlschema)
        end
        @raw_data     = ""
      end
    
      class << self
        def parse_event_data(data)
          events = []
          document = Nokogiri::XML.parse(data)
          
          document.css('entry').each do |entry|
            # -- lazy data --
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
            
            comment_data = []
            entry.xpath('//gd:comments').each do |comment|
              comment.xpath('//gd:feedlink').each do |link|
                comment_data << link.attribute('href').value
              end
            end
            
            who_data = []
            entry.xpath('//gd:who').each do |who|
              user = {
                :name   => who.attribute('valueString').value,
                :email  => who.attribute('email').value,
                :status => who.xpath('//gd:attendeeStatus').first.attribute('value').value.split(".").last
              }
              who_data << user
            end
            
            whin = entry.xpath('//gd:when').first
            whin_data = {}
            whin_data = {
              :start_time => Time.xmlschema(whin.attribute('startTime').value),
              :end_time   => Time.xmlschema(whin.attribute('endTime').value),
              :reminders  => []
            }
              
            reminders = []
            whin.xpath('//gd:reminder').each do |reminder|
              rd = {
                :minutes  => reminder.attribute('minutes').value,
                :method   => reminder.attribute('method').value
              }
              reminders << rd
            end
            whin_data[:reminders] = reminders
            # --
            
            event = self.new(
              :raw_data     => entry,
              :comments     => comment_data,
              :author       => author_data,
              # :who          => who_data,
              :where        => entry.xpath('//gd:where').first.attribute('valueString').value,
              :when         => whin_data,
              :event_status => entry.xpath('//gd:eventStatus').first.attribute('value').value.split(".").last,
              :title        => entry.css('title').first.content,
              :content      => (entry.css('content').length > 0 ? entry.css('content').first.content : nil),
              :published_on => Time.xmlschema(entry.css('published').first.content),
              :updated_on   => Time.xmlschema(entry.css('updated').first.content),
              :links        => link_data
            )
            event.id = link_data[:alternate]
            
            events << event
          end
          
          return events
        end
      end
  end
end