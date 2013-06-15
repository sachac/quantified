Feature: Memories
  Background:
    Given I am logged in
    And I have the following memories:
      | Title    | Text                         | Tags   | Public |
      | Memory A | Details for memory A go here | family | Yes    |
      | Memory B | Details for memory B go here | life   | No     |
    And there is another user
    And the other user has the following memories:
      | Title    | Text                         | Tags   | Public |
      | Memory Z | Details for memory Z go here | family | Yes    |
  Scenario: View a list of memories
    When I view a list of memories
    Then I should see "Memory A"
    And I should see "Memory B"
    And I should not see "Memory C"
  @wip  
  Scenario: Logged out
    When I log out
    And I view a list of memories
    Then I should see "Memory A"
    And I should not see "Memory B"
  Scenario: Create a memory
    When I create a memory with the following information:
      | Title    | Text                         | Tags   | Public |
      | Memory C | Details for memory A go here | family | Yes    |
    Then I should see "Memory A"
    And I should see "Memory B"
    And I should see "Memory C"
  @wip
  Scenario: Make a linked memory
    When I view the "Memory A" memory
    And I create a linked memory with the following attributes:
      | Title    | Text                         | Tags   | Public |
      | Memory C | Details for memory C go here | family | Yes    |
    Then I should see "Memory C"
    And I should see "Memory A" is a linked memory
    When I view the "Memory A" memory
    Then I should see "Memory C" is a linked memory
  # Scenario: Link existing memories
  #   When I view the "Memory A" memory
  #   And I link it with "Memory B"
  #   Then I should see "Memory B" is a linked memory
  # Scenario: Revise another person's memory
  #   When I view the "Memory C" memory
  #   And I say it happened differently with the following information:
  #     | Title               | Text                 | Tags   | Public |
  #     | Memory C my version | My version goes here | family | Yes    |
  #   And I am on my own subdomain
  #   And I view a list of memories
  #   Then I should see "Memory C my version"
  #   When I view the "Memory C my version" memory
  #   Then I should see "Memory C" is a linked memory
  #   When I view the "Memory C" memory
  #   Then I should see "Memory C my version" is a linked memory
    
