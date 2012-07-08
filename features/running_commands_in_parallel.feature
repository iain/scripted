Feature: Running Commands in Parallel

  Commands can be run in parallel. Simply put a `parallel` block around them.

  ``` ruby
  parallel do
    run "rspec"
    run "cucumber"
  end
  ```

  Scenario: Parallel

    Given the configuration:
    """
    parallel do
      run "sleep 1"
      run "sleep 1"
    end
    parallel do
      run "sleep 1"
      run "sleep 1"
      run "sleep 1"
    end
    """
    When I run `time scripted`
    Then it should have taken about 2 seconds
