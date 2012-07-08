Feature: Rake Integration

  Scripted has support for Rake.

  You can either let it pick up your "scripted.rb" file, or define the commands
  in place.

  When you don't specify a block, it will pick up your "scripted.rb" file:

  ``` ruby
  require 'scripted/rake_task'
  Scripted::RakeTask.new(:scripted)
  ```

  When you specify a block, it will use this block to execute:

  ``` ruby
  require 'scripted/rake_task'
  Scripted::RakeTask.new(:scripted) do
    run "echo from inside rakefile"
  end
  ```

  The rake command will run the default group by default. To change this, specify the group:

  ``` ruby
  require 'scripted/rake_task'
  Scripted::RakeTask.new(:install, :install)
  ```

  You can also specify Rake dependencies:

  ``` ruby
  require 'scripted/rake_task'
  Scripted::RakeTask.new(:my_task => "db:migrate")
  ```

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
