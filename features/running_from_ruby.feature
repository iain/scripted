Feature: Running from Ruby

  If you want to use scripted from within your own Ruby application, you can
  define and run your scripts in place.

  Scenario: Configuring and running directly

    Given a file named "app.rb" with:
    """
    require 'scripted'
    Scripted.run do
      run "echo welcome from shell within Ruby"
    end
    """

    When I run `ruby app.rb`
    Then the output should contain "welcome from shell within Ruby"

  Scenario: Defining a configuration and running later
    Given a file named "app.rb" with:
    """
    require 'scripted'

    configuration = Scripted.configure do
      run "echo welcome from shell within Ruby"
    end

    puts "Not running yet at this point"

    Scripted.run(configuration)
    """

    When I run `ruby app.rb`
    Then the output should contain:
    """
    Not running yet at this point
    welcome from shell within Ruby
    """
