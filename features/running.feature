Feature: Running

  Scripted comes with a executable to run commands. This requires you to have
  a configuration file somewhere. The default configuration file is
  `scripted.rb`, allowing you to run scripted without passing any commands.

      $ scripted

  If you want to store your configuration file somewhere else,
  you can specify it with the `-r` or `--require` option:

      $ scripted -r foo.rb

  To get more information, about the options, run:

      $ scripted --help

  Scenario: Simple

    Given a file named "scripted.rb" with:
    """
    run "echo command 1"
    run "echo command 2"
    """
    When I run `scripted`
    Then it should pass
    And the output should contain "command 1"
    And the output should contain "command 2"

  Scenario: Having failing commands
    Given a file named "scripted.rb" with:
    """
    run "false"
    """
    When I run `scripted`
    Then it should fail

  Scenario: By specifying another file

    Given a file named "something_else.rb" with:
    """
    run "echo 1"
    run "echo 2"
    """
    When I run `scripted -r something_else.rb`
    Then it should pass

  Scenario: With a non existing file
    When I run `scripted -r nope.rb`
    Then it should fail with regexp:
    """
    ^No such file -- .*nope.rb$
    """

  Scenario: Without `scripted.rb`
    When I run `scripted`
    Then it should fail with regexp:
    """
    ^No such file -- .*scripted.rb$
    """
    And the output should contain:
    """
    Either create a file called 'scripted.rb', or specify another file to load
    """
