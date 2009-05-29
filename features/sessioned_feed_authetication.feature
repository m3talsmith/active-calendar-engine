Feature: Session feed authentication
  In order to retrieve a list of calendars and related events from google we have to authenticate and store a session token when authenticated for further use.
  
  Scenario: Authenticated Session is being requested for the first time
    Given an authenticated session is not initialized
    And the preferences return valid credentials
    Then an authenticated session should be initialized when I try to authenticate the feed