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
    When I run `scripted`
    Then it should fail with:
    """
    THE TABLE
    """
