@life
Feature: Development-driven behaviour
  Scenario: Check for overdue books
    When I check our library items
    Then there should be no items that are overdue
  Scenario: Check my work load
    When I look at my time use for the past 7 days
    Then I should have time data
    And I should have worked between 40 and 44 hours
  Scenario: Check if I'm sleeping
    When I look at my time use for the past 7 days
    Then I should have slept between 8 and 9 hours a day
