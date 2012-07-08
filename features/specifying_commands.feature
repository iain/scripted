Feature: Specifying Commands

  By default the name of the command is the shell command to be run.

  There are a number of different runners.

  Scenario: Choosing a different shell command

    Given a file named "scripted.rb" with:
    """
    run "the name" do
      sh "echo the command output"
    end
    """
    When I run `scripted`
    Then the output should contain "the command output"

  Scenario: Choosing a different shell command with backticks
    This is exactly the same as the `sh` method.

    Given the configuration:
    """
    run "the name" do
      `echo the command output`
    end
    """
    When I run `scripted`
    Then the output should contain "the command output"



  Scenario: Running a rake command outside rake
    Given a file named "Rakefile" with:
    """
    namespace :db do
      task :migrate do
        puts "the rake task ran"
      end
    end
    """
    And a file named "scripted.rb" with:
    """
    run "rake" do
      rake "db:migrate"
    end
    """
    When I run `scripted`
    Then it should pass
    And the output should contain "the rake task ran"

  Scenario: Running a rake command from within Rake

    If you are running rake inside rake, it will use the normal invocation
    pattern, so dependencies will not be run again.

    Given a file named "Rakefile" with:
    """
    task :setup do
      raise "setup ran again" if File.exist?("foo")
      `touch foo`
    end
    task :migrate => :setup do
      puts "the rake task ran"
    end
    require 'scripted/rake_task'
    Scripted::RakeTask.new(:scripted => [:setup]) do
      run "migrate" do
        rake "migrate"
      end
    end
    task :both => [:setup, :scripted]
    """
    When I run `rake both`
    Then it should pass
    Then the output should contain "the rake task ran"

  Scenario: Running pure ruby

    Given a file named "scripted.rb" with:
    """
    run "some ruby code" do
      ruby { puts "the command" }
    end
    run "some failing ruby code" do
      ruby { raise "this command failed" }
    end
    """
    When I run `scripted`
    Then it should fail
    And the output should contain "the command"
    And the output should contain "this command failed"
