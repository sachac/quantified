Feature: Clothing logs
  Background:
    Given I am logged in
    And I have the following clothing items:
      | Name        | Status | Tags   |
      | red shirt   | active | top    |
      | black pants | active | bottom |
      | blue shirt  | active | top    |
      | khaki pants | active | bottom |
    And I have the following clothing logs:
      |       Date | Clothing     |
      | 2011-11-01 | red shirt    |
      | 2011-11-01 | black pants  |
      | 2011-11-02 | blue shirt   |
      | 2011-11-02 | khakhi pants |
      | 2011-11-03 | red shirt    |
      | 2011-11-03 | blue pants   |
