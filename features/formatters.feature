Feature: Formatters

  You can specify multiple formatters, similar to RSpec formatters.

  This is done, either via the command line or via the configuration.

  A formatter needs a name and optionally an output.

  In the following example, the default output (the output of your commands)
  will be written to the file `out.txt` but the announcer formatter will print
  to the terminal.

      $ scripted -f default -o out.txt -f announcer

  To specify a formatter in the configuration:

  ``` ruby
  formatter "default", :out => "out.txt"
  formatter "announcer"

  run "bundle install"
  ```

  If you don't specify a format, only the default formatter will be used. If
  you specify a formatter, the default won't be used, so you won't see any
  output.

  There are a couple of formatters included, such as `default`, `table`,
  `announcer`, `websocket` and `stats`. If you want to add your own, just use
  the complete class name as a formatter.

      $ scripted -f MyAwesome::Formatter

  Take a look at the included formatters to see how to make your own.

  Scenario: Saving output to a file
    Given the configuration:
    """
    run "echo Hi there"
    """
    When I run `scripted -f default -o output.txt`
    Then the output should not contain "Hi there"
    But the file "output.txt" should contain "Hi there"

  Scenario: Multiple outputs
    Given the configuration:
    """
    run "echo Hello there"
    """
    When I run `scripted -f default -o output.txt -f announcer -o announce.txt`
    Then the file "output.txt" should contain "Hello there"
    And the file "announce.txt" should contain:
    
    """
    ┌────────────────────────────────────────────────┐
    │                echo Hello there                │
    └────────────────────────────────────────────────┘
    """

  Scenario: Status table formatter
    Given the configuration:
    """
    run "true"
    run "true"
    run "false"
    run "true"
    """
    When I run `scripted -f table`
    Then it should fail with:
    """
    ┌─────────┬─────────┬─────────┐
    │ Command │ Runtime │ Status  │
    ├─────────┼─────────┼─────────┤
    """

  Scenario: Announcer formatter
    Given the configuration:
    """
    run "echo hi there"
    """
    When I run `scripted -f announcer -f default`
    Then the output should contain:
    """
    ┌────────────────────────────────────────────────┐
    │                 echo hi there                  │
    └────────────────────────────────────────────────┘

    hi there
    """

  Scenario: Stats output
    Given the configuration:
    """
    run "echo hi there"
    """
    When I run `scripted -f stats`
    Then the output should contain:
    """
    name,runtime,status
    """
