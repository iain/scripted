# Scripted

A DSL for running scripts. Really? Is this the best description I can come up with?

Anyway, what makes Scripted different from regular bash scripts, ruby scripts
or even rake, is that you can determine when to stop the process and you'll get
a pretty overview of how all your scripts exited.

Example configuration:

``` ruby
run "rspec"

run "cucumber"

run "javascript" do
  sh "evergreen run"
end
```

When you run this, via the `scripted` command, you'll get an output like this:

```
┌────────────┬─────────┬─────────┐
│ Command    │ Runtime │ Status  │
├────────────┼─────────┼─────────┤
│ rspec      │ 13.923s │ success │
│ cucumber   │ 59.347s │ failed  │
│ javascript │ 31.003s │ success │
└────────────┴─────────┴─────────┘
```

## Installation

Add this line to your application's Gemfile:

    gem 'scripted'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scripted

## Usage

You can define a configuration file, call it `scripted.rb`

``` ruby
run "rspec"
run "cucumber"
```

And then run it:

    $ scripted

To get more options:

    $ scripted --help

## Configuration

A group can contain multiple commands to run. The commands are run in the order they are supplied.

### When to stop the script

By default all commands are run, even if a command fails.

If you want to stop your scripts, when it fails. In the following example,
Cucumber will not be run if RSpec failed.

``` ruby
run "rspec" do
  important!
end
run "cucumber"
```

You might not care whether a command failed or not:

``` ruby
run "rm -r tmp" do
  unimportant!
end
```

This will not only keep the script running, but also not change the exit status
of the script in total if the command failed.

Also, you can enforce commands to run:

``` ruby
run "cleanup" do
  forced!
end
```

### Changing the command

Sometimes the command is too long or ugly to appear on the report. You can change the command:

``` ruby
run "javascript" do
  sh "evergreen run"
end
```

``` ruby
run "a command" do
  rake "db:migrate"
end
```

``` ruby
run "a command" do
  rails "server"
end
```

You can also run Ruby code:

``` ruby
run "something nice" do
  ruby { 1 + 1 }
end
```

Depending on your Ruby version, this might not work properly when running in parallel.

### Controlling reporting

Sometimes you don't want it to be in your report at all:

``` ruby
run "rake clean" do
  silent!
end
```

You can specify the formatter and output:

``` ruby
formatter :table     # the default
formatter :websocket # can give you real time output in a browser (not provided)
```

You can use multiple formatters, and configure their output individually:

``` ruby
formatter :table,     :out => "log/test.log" # defaults to $stderr
formatter :websocket, :out => "ws://localhost:12345/tests"
```

You can also specify this during the command line, just like RSpec formatters:

    $ scripted --format table --out log/test.log --format websocket --out ws://localhost:12345/tests

Or in short form:

    $ scripted -ft -fs -o ws://....

### Groups

You can define groups, and only run a subset:

``` ruby
group :ci do
  rake "db:migrate"
  run "rspec"
  run "cucumber"
end
group :install do
  run "bundle install"
  run "rake db:migrate"
end
```

Specify the group you want when running:

    $ scripted -g install,default

Commands specified outside groups belong to the `:default` group, just like Bundler.

### Running in parallel

You can make some commands run in parallel:

``` ruby
parallel do
  run "sleep 1"
  run "sleep 1"
end
run "sleep 1"
```

This script will take just about two seconds to run, instead of three. If you
mark one of the commands in parallel as important, it will stop as soon as all
commands that run in parallel exit.

Also note that any output from the commands might get intermingled when they
both try to access the same output stream.

### Dependencies

You can make group dependent of eachother, similar to Rake.

``` ruby
group :install do
  run "bundle install"
end

group :ci => :install do
  run "rspec"
end
```

Also similar to Rake: dependencies will not run multiple times. Once a group
has run, it will not run again.

### Integration

To run scripted from within another ruby script:

``` ruby
require 'scripted'

Scripted.configure do
  run "rspec"
  run "cucumber"

  group :install do
    run "db:migrate"
  end
end

Scripted.start! :default, :install # arguments optional
```

When you go the manual approach, the `scripted.rb` config file will not be loaded.

There is also integration with Rake, which does load the `scripted.rb` file, if it exists.

``` ruby
require 'scripted/rake_task'
Scripted::RakeTask.new(:install)
```

The first parameter you provide is also the name of the group to be executed.

You can further customize it:

``` ruby
require 'scripted/rake_task'
Scripted::RakeTask.new(:install) do
  formatter :table
  run "ls"
  # etc...
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

To run the tests:

    $ bundle install
    $ rake

Scripted eats its own dogfood.
