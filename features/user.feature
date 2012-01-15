Feature: Users
  Scenario: Log in with e-mail address
    When I log in with my e-mail address
    Then I should be logged in
  Scenario: Log in with username
    When I log in with my username
    Then I should be logged in
  Scenario: Register
    When I register
    Then I should see the thank you page
  Scenario: Find out about timezone settings
    Given I am a new user
    And I log in
    Then I should see a reminder to set my timezone
 
