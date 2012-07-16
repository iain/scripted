Feature: Formatters

  @wip
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
    ┌─────────┬─────────┬────────┐
    │ Command │ Runtime │ Status │
    ├─────────┼─────────┼────────┤
    │ true    │  0.005s │ false  │
    │ true    │  0.003s │ false  │
    │ false   │  0.004s │ true   │
    │ true    │  0.004s │ false  │
    └─────────┴─────────┴────────┘
    """
