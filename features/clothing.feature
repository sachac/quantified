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

