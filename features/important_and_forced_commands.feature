Feature: Important and Forced Commands

  You can mark a feature as important, which means that the script will stop
  directly after that command if it failed.

  If you mark a command as forced, then it will run, even if an important
  command failed before.

  Scenario: A failing important command
    Given a file named "scripted.rb" with:
    """
    run "false" do
      important!
    end
    run "echo this command will not be run"
    """
    When I run `scripted`
    Then it should fail
    And the output should not contain "this command will not be run"

  Scenario: Enforcing commands
    Given a file named "scripted.rb" with:
    """
    run "false" do
      important!
    end
    run "echo this command is forced" do
      forced!
    end
    """
    When I run `scripted`
    Then it should fail
    And the output should contain "this command is forced"
