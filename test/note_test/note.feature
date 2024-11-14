Feature: Note
  Scenario: Create a note
    Given I have a note with the title "My note"
    When I create the note
    Then I should see the note with the title "My note"

