Feature: Running Scripted

  Scenario: With the binary

    Given a file named "scripts.rb" with:
      """
      group :tests do
        run "echo 1"
        run "echo 2" do
          sh "echo 3"
        end
      end
      """
    When I run `scripted -r scripts.rb`
    Then the output should contain:
      """
      1
      3
      """
