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
  Scenario: View the menu
    Given I log in with my username
    And I go to the menu
    Then I should see "Time"
    And I should see "Decisions"
  Scenario: Sign up
    When I sign up as a new user
    Then I should see "Thank you for signing up!"
  Scenario: Send feedback
    Given there is a demo user
    When I send feedback
    Then the administrator should receive a feedback email
    And I should see "Thank you!"
  Scenario: Delete the user
    Given I am a new user
    And I log in
    And I delete my account
    Then my account should be deleted


