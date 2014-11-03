Feature: Goals
  In order to use time for decision-making
  As a user
  I want to define goals for record categories
  Background:
    Given I am logged in
    And I have a record category named "Work on awesome things"
  Scenario: Define a greater-than-or-equal-to goal for a category
    When I view the record category named "Work on awesome things"
    And I define a goal for it
    And I name the goal "Work on awesome things weekly"
    And I set the goal to be >= 1 hour
    And I set the goal to be weekly
    And I save it
    And I view my dashboard
    Then I should see "Work on awesome things weekly"
