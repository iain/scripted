Feature: Running Groups

  You can specify multiple groups and use the command line option "--group" or
  "-g" to run only that group.

  If you don't specify a group, it will run the default group. And if you don't
  specify which group a command is in, it will be in the default group.

  Example:

  ``` ruby
  group :install do
    run "bundle install"
  end
  ```

  Background:
    Given the configuration:
    """
    run "echo from the default group"
    group :install do
      run "echo from the install group"
    end
    """

  Scenario: Running the default group.
    When I run `scripted`
    Then the output should contain "from the default group"
    But the output should not contain "from the install group"

  Scenario: Running another group
    When I run `scripted -g install`
    Then the output should contain "from the install group"
    But the output should not contain "from the default group"

  Scenario: Running multiple groups
    When I run `scripted -g install,default`
    Then the output should contain "from the install group"
    And the output should contain "from the default group"
