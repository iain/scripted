Feature: Unimportant Commands

  You can mark features as unimportant. This will mean that they won't change
  the global exit status if they fail.

  Scenario: Basic
    Given a file named "scripted.rb" with:
    """
    run "false" do
      unimportant!
    end
    """
    When I run `scripted`
    Then it should pass
