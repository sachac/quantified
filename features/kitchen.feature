Feature: Kitchen - Groceries
  Background:
    Given I am logged in
    And I have a grocery list named "Home"
  Scenario: I can add an item to our grocery list
    When I add "Apples" to our grocery list
    Then I should see "Apples" on our grocery list
  Scenario: I can organize items by aisle or category
    When I add "Apples" to our grocery list
    And I set "Apples" to belong to "Produce"
    Then I should see "Apples" under "Produce"
  Scenario: We can cross items off
    Given I have "Apples" on our grocery list
    When I cross "Apples" off
    Then "Apples" should be crossed off
  Scenario: We can un-cross-off items
    Given I have "Apples" on our grocery list
    And I cross "Apples" off
    When I restore "Apples"
    Then I should see "Apples" on our grocery list
  Scenario: I can clear all crossed-off items
    Given I have a grocery list like:
      | Name    | Status |
      | Apples  | Done   |
      | Pears   | Done   |
      | Oranges |        |
    When I clear all crossed-off items
    Then I should not see "Apples" on my grocery list
    And I should see "Oranges" on my grocery list  
  Scenario: I can indicate quantities
    When I add "5 Apples" to our grocery list
    Then our grocery list should say I need 5 "Apples"
  Scenario: I can reorganize aisles/categories
    Given the following grocery list categories:
      | Produce |
      | Household Supplies |
    When I configure "Household Supplies" to be first
    Then the grocery list categories should be:
      | Household Supplies |
      | Produce |
  Scenario: Items have a price history
    When I have the following price history:
      | Name   | Quantity | Unit price | Total |       Date |
      | Apples |        1 |          5 |  5.00 | 2014-10-01 |
      | Apples |        2 |          4 |  8.00 | 2014-10-02 |
    And I add "Apples" to our grocery list
    And I view the grocery item page for "Apples"
    Then I should see that "Apples" had the past price of 5.0
  Scenario: I can set the price of an item
    When I add "Apples" to our grocery list
    And I set the price of "Apples" to 3.97
    Then "Apples" should have the price of 3.97
  Scenario: We can indicate our intent to pick something up
    When I add "Apples" to our grocery list
    And "W" indicates an intent to pick up "Apples"
    Then I should see that "Apples" are taken
  Scenario: We can clear our intent to pick something up
    When I add "Apples" to our grocery list
    And "W" indicates an intent to pick up "Apples"
    And "W" clears the intent to pick up "Apples"
    Then I should see that "Apples" are free to pick up
  Scenario: I cannot grant access to my list to a new user
    When I have a grocery list like:
      | Name    | Status |
      | Apples  | Done   |
      | Pears   | Done   |
      | Oranges |        |
    And I share my grocery list with a non-existent user
    Then I should see that the other user does not exist
  Scenario: I can grant access to my list to an existing user
    When I have a grocery list like:
      | Name    | Status |
      | Apples  | Done   |
      | Pears   | Done   |
      | Oranges |        |
    And I share my list with an existing user
    And I log out
    And the other user logs in
    Then the other user should see the list in their grocery lists
    And the other user should be able to add "Bananas"
    And the other user should be able to cross off "Oranges"
  Scenario: I can remove someone's access to my grocery list
    Given I share my list with an existing user
    And I remove the other user from the grocery list
    Then the other person should not have access to my grocery list
  Scenario: We can send messages
    When "W" sends me a message
    Then I should see that message
  Scenario: We can request to meet and indicate our location
    When "W" requests to meet at the counters
    Then I should see a request to meet at the counters    
  Scenario: I can take notes on products
  Scenario: I can autocomplete an item name
  Scenario: I can link groceries to recipes
  Scenario: I can cancel a recipe
  Scenario: I can store pictures of our favourite brands or types
  Scenario: I can keep a pantry/staples list
  Scenario: I can restock pantry/staples
  Scenario: When looking at a recipe, I can see what ingredients are staples
  Scenario: Our lists are synchronized
  Scenario: I can change the synchronization frequency
