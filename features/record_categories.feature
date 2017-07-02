Feature: Record Categories
  In order to track time
  As a user
  I want to define a hierarchy of categories
  Background:
    Given I am logged in
  Scenario: Create a category tree and use it
    When I create a record category named "Discretionary" which is a "list"
    And I create a record category named "Quantified Awesome" which is an "activity" under "Discretionary"
    And I go to my record categories
    Then I should see "Discretionary"
    When I click on "Discretionary"
    Then I should see "Quantified Awesome"
  Scenario: Rename the keys for a category
    When I rename the keys for a category with existing data
    Then the records should be updated with the same keys
  Scenario: Delete the keys for a category
    When I delete the keys for a category
    Then the category fields should be updated
  @focus
  Scenario: Batch edit categories
    Given I have the following categories:
      | Name       | Type     | Parent     | Color |
      | Category A | list     |            |       |
      | Category B | activity | Category A |       |
      | Category C | activity |            | #00ff00 |
    When I batch-edit categories
    And I change the name of "Category A" to "Category X"
    Then I should see "Category X"
    And I should see "Category X - Category B"
    And I should see "Category C"
