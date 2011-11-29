Feature: Framework
  Scenario: Switch layouts
    Given there is a user
    When I go to the dashboard
    And I switch to the mobile layout
    Then I should see the mobile layout
    When I go to the contexts page
    Then I should see the mobile layout
    When I switch to the full layout
    Then I should see the full layout
  Scenario: View different users
    Given there is a user with the username "test1"
    And there is a user with the username "test2"
    When I am on the subdomain for "test1"
    And I go to the dashboard
    Then the current account should be "test1"
    When I am on the subdomain for "test2"
    And I go to the dashboard
    Then the current account should be "test2"
  Scenario: Try non-existent account
    Given there is a user with the username "test1"
    When I am on the subdomain for "test2"
    And I go to the dashboard
    Then I should see an error
  Scenario: Try access denied
    Given there is a user with the username "test1"
    When I go to the context creation page
    Then I should not have access
