Feature: Google Calendars
  In order to use my google calendar
  As a ActiveRecord like object
  I want to be given the data from google's api as an active object
  
  Scenario: An array of Calendars will be retrieved using an authenticated token
    When I do a find all
    Then I should have an array of calendars
    
  Scenario: A calendar, chosen from an array of calendars, is valid
    When I retrieve a list of calendars
    And I look at the first calendar
    Then It should have all it's attributes and the timezone should not be nil:
      | attributes    |
      | links         |
      | author        |
      | published_on  |
      | updated_on    |
      | title         |
      | timezone      |
      | access_level  |
      | summary       |
      | events        |