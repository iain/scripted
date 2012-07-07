Feature: Rake integration

  Scripted has support for Rake.

  You can either let it pick up your "scripted.rb" file, or define the commands
  in place.

  Scenario: Picking up scripted.rb

    Given a file named "scripted.rb" with:
    """
    run "echo command 1"
    """

    And a file named "Rakefile" with:
    """
    require 'scripted/rake_task'
    Scripted::RakeTask.new(:scripted)
    """

    When I run `rake scripted`
    Then the output should contain "command 1"

  Scenario: Specifying different groups

    Given a file named "scripted.rb" with:
    """
    run "echo command 1"
    group :install do
      run "echo install command"
    end
    """

    And a file named "Rakefile" with:
    """
    require 'scripted/rake_task'
    Scripted::RakeTask.new(:scripted, :install)
    """

    When I run `rake scripted`
    Then the output should contain "install command"
    But the output should not contain "command 1"


  Scenario: Configuring in place

    Given a file named "Rakefile" with:
    """
    require 'scripted/rake_task'
    Scripted::RakeTask.new(:scripted) do
      run "echo from inside rakefile"
    end
    """
    And the file "scripted.rb" should not exist
    When I run `rake scripted`
    Then the output should contain "from inside rakefile"
