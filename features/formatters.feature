Feature: Formatters

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
