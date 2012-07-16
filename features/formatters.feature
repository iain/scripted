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
