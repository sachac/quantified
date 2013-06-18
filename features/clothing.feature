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
      |       Date | Clothing |
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
      |       Date | Clothing    | Type   |
      | 2011-11-01 | red shirt   | top    |
      | 2011-11-01 | black pants | bottom |
      | 2011-11-02 | blue jeans  | bottom |
      | 2011-11-02 | white shirt | top    |
      | 2011-11-03 | red shirt   | top    |
      | 2011-11-03 | black pants | bottom |
      | 2011-11-03 | red shirt   | top    |
      | 2011-11-03 | blue jeans  | bottom |
      | 2011-11-03 | black sweater | sweater |
    When I analyze my clothes
    Then I should see that "red shirt" was worn 2 times with "black pants"
    And I should see that "white shirt" was worn 1 time with "blue jeans"
    And I should see that "red shirt" was worn 1 time with "blue jeans"
    And I should not see "black sweater"
  Scenario: Graph clothing choices
    Given I have the following clothing logs:
      |       Date | Clothing    | Type   |
      | 2011-11-01 | red shirt   | top    |
      | 2011-11-01 | black pants | bottom |
      | 2011-11-02 | blue jeans  | bottom |
      | 2011-11-02 | white shirt | top    |
      | 2011-11-03 | red shirt   | top    |
      | 2011-11-03 | black pants | bottom |
      | 2011-11-03 | red shirt   | top    |
      | 2011-11-03 | blue jeans  | bottom |
      | 2011-11-03 | black sweater | sweater |
    When I graph my clothes
    Then I should see that "red shirt" was worn 2 times with "black pants"
    And I should see that "white shirt" was worn 1 time with "blue jeans"
    And I should see that "red shirt" was worn 1 time with "blue jeans"

   
