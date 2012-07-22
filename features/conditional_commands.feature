Feature: Conditional Commands

  There are two types of commands that can be run conditionally, depending on
  the output of the other commands. These are marked with `only_when_success!`
  and `only_when_failed!`.

  Usually you want to put the commands at the end of your script, because it
  measures the success or failure by the commands that have executed until that
  point.

  Tip: You can combine these commands with `important!` to stop the script half
  way, without making every command important.

  Scenario: Only when success when no other command failed
    Given the configuration:
    """
    run "true"
    run "echo only when success has run" do
      only_when_success!
    end
    """
    When I run scripted
    Then it should pass
    And the output should contain "only when success has run"

  Scenario: Only when success with a failing command
    Given the configuration:
    """
    run "false"
    run "echo only when success has run" do
      only_when_success!
    end
    """
    When I run scripted
    Then it should fail
    And the output should not contain "only when success has run"

  Scenario: Only when failed with a failing command
    Given the configuration:
    """
    run "false"
    run "echo only when failed has run" do
      only_when_failed!
    end
    """
    When I run scripted
    Then it should fail
    And the output should contain "only when failed has run"

  Scenario: Only when failed when nothing failed
    Given the configuration:
    """
    run "true"
    run "echo only when failed has run" do
      only_when_failed!
    end
    """
    When I run scripted
    Then it should pass
    And the output should not contain "only when failed has run"

  Scenario: Stopping a script half way
    Given the configuration:
    """
    run "true"
    run "false"

    run "make sure all the previous tasks have succeeded" do
      `false`
      only_when_failed!
      important!
    end

    # the rest
    run "echo this should not be run"
    """
    When I run scripted
    Then the output should not contain "this should not be run"
