Feature: Clothing logs
  Background:
    Given I am logged in
  Scenario: View clothing logs
    Given I have the following clothing logs:
      |       Date | Clothing |
      | 2011-11-01 | red shirt   |
      | 2011-11-01 | black pants |
    And the date is 2011-11-02
    When I go to the clothing logs page
    Then I should see the following clothing items:
      | red shirt |
      | black pants |
  Scenario: View clothing matches
    Given I have the following clothing logs:
      |       Date | Clothing |
      | 2011-11-01 | red shirt   |
      | 2011-11-01 | black pants |
    And the date is 2011-11-02
    When I go to the clothing logs matches page
    Then I should see "red shirt"
  Scenario: Edit a clothing log entry
    Given I have the following clothing logs:
      |       Date | Clothing |
      | 2011-11-01 | red shirt   |
      | 2011-11-01 | black pants |
      | 2011-11-02 | blue jeans |
    When I go to the clothing log page for "red shirt" on 2011-11-01
    Then I should see "red shirt"
    When I edit it
    And I change the clothing log entry to "blue jeans"
    Then I should see "blue jeans"
    And I should not see "red shirt"
  Scenario: Create a clothing log entry
    Given I have the following clothing items
      | Name       | Status | Tags |
      | red shirt  | active | top  |
      | blue jeans | active | bottom  |
    And the date is 2011-11-02
    When I create a new clothing log entry for "red shirt" on "2011-11-01"
    Then I should see "2011-11-01"
  Scenario: Delete a clothing log entry
    Given I have the following clothing logs:
      |       Date | Clothing |
      | 2011-11-01 | red shirt   |
      | 2011-11-01 | black pants |
    And the date is 2011-11-02
    When I go to the clothing log page for "red shirt" on 2011-11-01
    When I delete it
    And I go to the clothing logs page
    Then I should not see "red shirt"
    And I should see "black pants"
  Scenario: View by date
    Given I have the following clothing logs:
      |       Date | Clothing    |
      | 2011-11-01 | red shirt   |
      | 2011-11-01 | black pants |
      | 2011-11-02 | red shirt   |
      | 2011-11-02 | blue jeans  |
    When I go to the clothing logs by date for 2011-11-01
    Then I should see "red shirt"
    And I should see "black pants"
    And I should not see "blue jeans"
