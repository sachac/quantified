Feature: Users
  Scenario: Log in with e-mail address
    When I log in with my e-mail address
    Then I should be logged in
  Scenario: Log in with username
    When I log in with my username
    Then I should be logged in
