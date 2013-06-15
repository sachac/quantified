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
  Scenario: Try access denied
    Given there is a user with the username "test1"
    When I go to the context creation page
    Then I should not have access
