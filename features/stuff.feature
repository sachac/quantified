Feature: Stuff
  Background:
    Given I am a user
    And I am logged in
  Scenario: Set up a context
    Given I have the following stuff:
      | Name      | Home location | Current location |
      | backpack  | front shelf | front shelf |
      | laptop    | backpack | pantry |
      | badge     | belt bag | belt bag |
      | lunch bag | kitchen cabinet | kitchen cabinet |
    When I create a context called "Going to work"
    And I define the following rules:
      | laptop is in backpack |
      | backpack is with me |
      | badge is in belt bag |
      | lunch bag is in backpack |
    And I save the context  
    Then the context should exist

    When I start the context
    Then the following things should be reported as out of place:
      | Name | Current location | New location |
      | laptop | pantry | backpack |
      | lunch bag | kitchen cabinet | backpack |
      | backpack | front shelf | me |
    And the following things should be reported as in place:
      | belt bag |
    When I mark "laptop" as moved to "backpack"
    And the following things should be reported as in place:
      | laptop |
      | belt bag |
    When I mark all as done
    Then nothing should be reported as out of place
