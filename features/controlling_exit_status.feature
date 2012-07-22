Feature: Controlling Exit Status

  By default, Scripted will run all commands. If a command failed (e.g. if you
  have failing tests) the entire run will be marked as failed. In Unix terms,
  this means the exit code will be zero for successful runs and non-zero for
  failed runs.

  Sometimes it doesn't make sense to continue running commands if one failed,
  like when an important setup command failed. If this is the case, you can
  mark the command as important. If this commands fails, it will not run the
  following commands.

  Here RSpec won't run if the database cannot be created:

  ``` ruby
  run "create the database" do
    rake "db:create"
    important!
  end

  run "rspec"
  ```

  Sometimes you don't care if the command failed or not. The recommended
  approach is to change the command itself so it does behave, but if you can't
  do that, you can mark it with `unimportant!`.

  ``` ruby
  run "some command" do
    unimportant!
  end
  ```

  Sometimes a command can be very important to you. An example might be
  shutting down daemons after a test run. You always want these commands to
  run, even if your test suite failed. You can mark these with `forced!`

  ``` ruby
  run "stop xvfb" do
    `/etc/init.d/xvfb`
    forced!
  end
  ```

  Scenario: Having failing commands
    Given the configuration:
    """
    run "false"
    run "echo this should still run"
    """
    When I run scripted
    Then it should fail
    And the output should contain "this should still run"

  Scenario: A failing important command
    Given the configuration:
    """
    run "false" do
      important!
    end
    run "echo this command will not be run"
    """
    When I run scripted
    Then it should fail
    And the output should not contain "this command will not be run"

  Scenario: Enforcing commands
    Given the configuration:
    """
    run "false" do
      important!
    end
    run "echo this command is forced" do
      forced!
    end
    """
    When I run scripted
    Then it should fail
    And the output should contain "this command is forced"

  Scenario: A failing command that would otherwise have failed.
    Given the configuration:
    """
    run "false" do
      unimportant!
    end
    """
    When I run scripted
    Then it should pass
