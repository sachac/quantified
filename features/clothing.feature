Feature: Clothing
  Background:
    Given I am logged in
  Scenario: View clothing index
    Given I have the following clothing items:
      | Name | Status |
      | red shirt | active |
      | blue shirt | active |
      | green shirt | stored |
    When I go to the clothing index path
    Then I should see the following clothing items:
      | red shirt |
      | blue shirt |
    And I should not see the following clothing items:
      | green shirt |
  Scenario: View clothing details for a top
    Given I have the following clothing items:
      | Name | Status | Tags | 
      | red shirt | active | top   |
      | black pants | active | bottom |
      | blue pants | active | bottom |
    And I have the following clothing logs:
      |       Date | Clothing |
      | 2011-11-01 | red shirt   |
      | 2011-11-01 | black pants |
    When I go to the clothing page for "red shirt"
    Then I should see that it is active
    And I should see that I can donate it
    And I should see that I have worn this with "black pants" before
    And I should see that "blue pants" are a possible match
  Scenario: View clothing details for a casual item
    Given I have the following clothing items:
      | Name | Status | Tags | 
      | red shirt | active | casual, top |
      | black pants | active | bottom |
      | blue pants | active | office, bottom |
      | green pants | active | casual, bottom |
    And I have the following clothing logs:
      |       Date | Clothing    |
      | 2011-11-01 | red shirt   |
      | 2011-11-01 | black pants |
    When I go to the clothing page for "red shirt"
    Then I should see that it is active
    And I should see that I can donate it
    And I should see that I have worn this with "black pants" before
    And I should not see that "blue pants" are a possible match
    And I should see that "green pants" are a possible match
  Scenario: View clothing details for an office item
    Given I have the following clothing items:
      | Name | Status | Tags | 
      | red shirt | active | office, top |
      | black pants | active | casual, bottom |
      | blue pants | active | office, bottom |
      | green pants | active | casual, bottom |
    And I have the following clothing logs:
      |       Date | Clothing |
      | 2011-11-01 | red shirt   |
      | 2011-11-01 | black pants |
    When I go to the clothing page for "red shirt"
    Then I should see that it is active
    And I should see that I can donate it
    And I should see that I have worn this with "black pants" before
    And I should see that "blue pants" are a possible match
    And I should not see that "green pants" are a possible match
  Scenario: View clothing details for a top
    Given I have the following clothing items:
      | Name | Status | Tags | 
      | red shirt | active | top   |
      | black pants | active | bottom |
      | blue pants | active | bottom |
    And I have the following clothing logs:
      |       Date | Clothing |
      | 2011-11-01 | red shirt   |
      | 2011-11-01 | black pants |
    When I go to the clothing page for "red shirt"
    Then I should see that it is active
    And I should see that I can donate it
    And I should see that I have worn this with "black pants" before
    And I should see that "blue pants" are a possible match
  Scenario: View clothing details for a bottom
    Given I have the following clothing items:
      | Name | Status | Tags | 
      | red shirt | active | top |
      | black pants | active | bottom |
      | blue pants | active | bottom |
    And I have the following clothing logs:
      |       Date | Clothing |
      | 2011-11-01 | red shirt   |
      | 2011-11-01 | black pants |
    When I go to the clothing page for "black pants"
    Then I should see that it is active
    And I should see that I can donate it
    And I should see that I have worn this with "red shirt" before
  Scenario: Create a new piece of clothing
    When I create a new piece of clothing
    Then the clothing should be mine
    And the clothing should be active
  Scenario: Edit a piece of clothing
    When I edit a piece of clothing
    And I tag it as "bottom"
    And I save it
    Then the clothing should be tagged "bottom"
  Scenario: Delete a piece of clothing
    Given I have the following clothing items:
      | Name | Status | Tags | 
      | red shirt | active | top |
      | black pants | active | bottom |
      | blue pants | active | bottom |
    When I edit the "red shirt" clothing item
    And I delete it
    And I go to the clothing index path
    Then I should not see the following clothing items:
      | red shirt |
  Scenario: View by tag
    Given I have the following clothing items:
      | Name | Status | Tags | 
      | red shirt | active | top, casual |
      | black pants | active | bottom, casual |
      | blue pants | active | bottom, office |
    When I go to the clothing tag page for "casual"
    Then I should see the following clothing items:
      | red shirt |
      | black pants |
    And I should not see the following clothing items:
      | blue pants |
  Scenario: View by status
    Given I have the following clothing items:
      | Name | Status | Tags | 
      | red shirt | active | top, casual |
      | black pants | active | bottom, casual |
      | blue pants | donated | bottom, office |
    When I go to the clothing status page for "donated"
    Then I should see the following clothing items:
      | blue pants |
    And I should not see the following clothing items:
      | red shirt   |
      | black pants |
  Scenario: Don't see other people's clothing items
    Given there is another user
    And the other user has the following clothing items:   
      | Name | Status | Tags | 
      | red shirt | active | top, casual |
    When I go to the clothing index path
    Then I should not see the following clothing items:
      | red shirt | 
  Scenario: View clothing logs for an item
    Given I have the following clothing logs:
      |       Date | Clothing |
      | 2011-11-01 | red shirt   |
      | 2011-11-01 | black pants |
      | 2011-11-02 | blue jeans |
    And the date is 2011-11-03
    When I go to the clothing logs page for "red shirt"
    Then the page should contain "black pants"
    And the page should not contain "blue jeans"
  Scenario: Analyze clothing
    Given I have the following clothing logs:
      |       Date | Clothing      | Tags    |
      | 2011-10-31 | red dress     | dress   |
      | 2011-11-01 | red shirt     | top     |
      | 2011-11-01 | black pants   | bottom  |
      | 2011-11-02 | blue jeans    | bottom  |
      | 2011-11-02 | white shirt   | top     |
      | 2011-11-03 | red shirt     | top     |
      | 2011-11-03 | black pants   | bottom  |
      | 2011-11-04 | red shirt     | top     |
      | 2011-11-04 | blue jeans    | bottom  |
      | 2011-11-04 | black sweater | sweater |
    And the date is 2011-11-04
    When I analyze my clothes
    Then I should see that "red shirt" was worn 2 times with "black pants"
    And I should see that "white shirt" was worn 1 time with "blue jeans"
    And I should see that "red shirt" was worn 1 time with "blue jeans"
  Scenario: Analyze clothing by month
    Given I have the following clothing logs:
      |       Date | Clothing      | Tags    |
      | 2011-10-31 | red dress     | dress   |
      | 2011-11-01 | red shirt     | top     |
      | 2011-11-01 | black pants   | bottom  |
      | 2011-11-02 | blue jeans    | bottom  |
      | 2011-11-02 | white shirt   | top     |
      | 2011-11-03 | red shirt     | top     |
      | 2011-11-03 | black pants   | bottom  |
      | 2011-11-04 | red shirt     | top     |
      | 2011-11-04 | blue jeans    | bottom  |
      | 2011-11-04 | black sweater | sweater |
      | 2011-12-01  | red shirt     | top     |
    When I analyze my clothes by month from 2011-01-01 to 2012-12-31
    Then I should see that "red shirt" was worn 3 times in the month ending 2011-11-30
  Scenario: Analyze clothing by year
    Given I have the following clothing logs:
      |       Date | Clothing      | Tags    |
      | 2011-11-01 | red shirt     | top     |
      | 2011-11-01 | black pants   | bottom  |
      | 2011-11-02 | blue jeans    | bottom  |
      | 2011-11-02 | white shirt   | top     |
      | 2011-11-03 | red shirt     | top     |
      | 2011-11-03 | black pants   | bottom  |
      | 2011-11-04 | red shirt     | top     |
      | 2011-11-04 | blue jeans    | bottom  |
      | 2011-11-04 | black sweater | sweater |
      | 2011-12-01 | red shirt     | top     |
      | 2010-12-01 | red shirt     | top     |
    And the date is 2012-11-04
    When I analyze my clothes by year from 2011-01-01 to 2012-12-31
    Then I should see that "red shirt" was worn 4 times in the year ending 2011-12-31
  Scenario: Analyze clothing by day
    Given I have the following clothing logs:
      |       Date | Clothing      | Tags    |
      | 2011-11-01 | red shirt     | top     |
      | 2011-11-01 | black pants   | bottom  |
      | 2011-11-02 | blue jeans    | bottom  |
      | 2011-11-02 | white shirt   | top     |
      | 2011-11-03 | red shirt     | top     |
      | 2011-11-03 | black pants   | bottom  |
      | 2011-11-04 | red shirt     | top     |
      | 2011-11-04 | blue jeans    | bottom  |
      | 2011-11-04 | black sweater | sweater |
      | 2011-12-01 | red shirt     | top     |
      | 2010-12-01 | red shirt     | top     |
    And the date is 2011-11-04
    When I analyze my clothes by day
    And I should see that "red shirt" was worn 1 time on "2011-11-03"
  Scenario: Graph clothing choices
    Given I have the following clothing logs:
      |       Date | Clothing      | Tags    |
      | 2011-11-01 | red shirt     | top     |
      | 2011-11-01 | black pants   | bottom  |
      | 2011-11-02 | blue jeans    | bottom  |
      | 2011-11-02 | white shirt   | top     |
      | 2011-11-03 | red shirt     | top     |
      | 2011-11-03 | black pants   | bottom  |
      | 2011-11-04 | red shirt     | top     |
      | 2011-11-04 | blue jeans    | bottom  |
      | 2011-10-31 | red dress     | dress   |
      | 2011-11-05 | black sweater | sweater |
    And the date is 2011-11-06
    When I graph my clothes
    Then I should see that "red shirt" and "black pants" are connected with weight 2
    And I should see that "white shirt" and "blue jeans" are connected with weight 1
    And I should see that "red shirt" and "blue jeans" are connected with weight 1
  Scenario: Summarize clothing use by week
    Given I have the following clothing logs:
      |       Date | Clothing      | Tags    |
      | 2014-04-01 | red shirt     | top     |
      | 2014-04-01 | black pants   | bottom  |
      | 2014-04-02 | blue jeans    | bottom  |
      | 2014-04-02 | white shirt   | top     |
      | 2014-04-03 | red shirt     | top     |
      | 2014-04-03 | black pants   | bottom  |
      | 2014-04-05 | red shirt     | top     |
      | 2014-04-05 | blue jeans    | bottom  |
      | 2014-04-31 | red dress     | dress   |
      | 2014-04-05 | black sweater | sweater |
    When I analyze my clothes by week from 2014-04-01 to 2014-04-05
    Then I should see that "red shirt" was worn 2 times in the week ending 2014-04-04

