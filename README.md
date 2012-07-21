# Scripted

[![Build Status](https://secure.travis-ci.org/iain/scripted.png?branch=master)](http://travis-ci.org/iain/scripted)

Scripted is a framework for organizing scripts.

Among its features are:

* A convenient DSL to determine how and when to run scripts
* Determine which scripts in parallel with each other
* Manage the exit status of your scripts
* A variaty of output formatters, including one that exports the output of the
  scripts via websockets!
* Specify groups of tasks
* Integration with Rake

See a video of [scripted running with websockets](http://www.youtube.com/watch?v=GMiN0dHtFkg).

## Reasoning

It is considered good practice to bundle all the tasks you need to do in one
script. This can be a setup script that installs your application, or a all
test scripts combined for your CI to use.

While it is very easy to make this with plain Bash scripts, I found myself
writing a lot of boiler code over and over again. I wanted to keep track of the
runtimes of each commands. Or I wanted to run certain scripts in parallel, but
still wait for them to finish.

This gem exists because I wanted to simply define which commands to run, and
not deal with all the boilerplate code every time.

## Examples

There are a number of examples included in the project. You can find them in
the `examples` directory.

* Clone the project
* Install via `./install`
* See which examples are avaibale: `rake -T examples`
* Run an example: `rake examples:websockets`

## Usage

You'll need to create a configuration file for scripted to run. By default this
file is called `scripted.rb`, but you can name it whatever you like.

After making the configuration, you can run it with the `scripted` executable.

Run `scripted --help` to get an overview of all the options.

### The Basic Command DSL

You can define "commands" via the `run`-method. For instance:

``` ruby
run "rspec"
run "cucumber"
```

The first argument to the `run`-method is the name of the command. If you don't
specify anything else, this will be the shell command run. You can change the
command further by supplying a block.

``` ruby
run "fast unit specs" do
  `rspec spec/unit`
end

run "slow integration specs" do
  `rspec spec/integration`
end
```

You can also specify Rake tasks and Ruby commands to run:

``` ruby
run "migrate the database" do
  rake "db:migrate"
end

run "some ruby code" do
  ruby { 1 + 1 }
end
```

### Running scripts in parallel

You can really win some time by running certain commands in parallel. Doing
that is easy, just put them in a `parallel`-block:

``` ruby
run "bundle install"

parallel do
  run "rspec"
  run "cucumber"
end

run "something else"
```

Commands that come after the parallel block, will wait until all the commands
that run in parallel have finished.

There are only a few caveats to this. The scripts must be able to run
simultaniously. If they both access the same global data, like a database or
files on your hard disk, they will probably fail. Also, any output they produce
will appear at the same time, possibly making it unreadable.

You can specify multiple parallel blocks.

### Managing exit status

By default, all commands will run, even if one failed. The exit status of the
entire scripted run will hover reflect that one script has failed.

If one of your commands is so important that other commands cannot possibly
succeed afterwards, mark it with `important!`:

``` ruby
run "bundle install" do
  important!
end

run "rspec"
```

If a command might fail, but you don't want the global exit status to change if
it happens, mark the command with `unimportant!`

``` ruby
run "flickering tests" do
  unimportant!
end
```

If you have some clean up to do, that always must run, even if an important
command failed, mark it with `forced!`:

``` ruby
run "start xvfb" do
  `/etc/init.d/xvfb start`
  unimportant! # it might be on already
end

run "bundle install" do
  important!
end

run "rspec"

run "stop xvfb" do
  `/etc/init.d/xvfb stop`
  forced!
end
```

And finally, to have a command run only if other commands have failed, mark it
with `only_when_failed!`:

``` ruby
run "mail me if build failed" do
  only_when_failed!
end
```

### Formatters

Formatters determine what gets outputted. This can be to your screen, a file,
or a websocket. You can specify the formatters via the command line, or via
the configuration file.

Via the command line:

    $ scripted --format my_formatter --out some_file.txt

Via the configuration file:

``` ruby
formatter :my_formatter, :out => "some_file.txt"
```

You can have multiple formatters. If you don't specify the `out` option, it
will send the output to `STDOUT`.

#### The default formatter

The formatter that is used if you don't specify anything is `default`. This
formatter will output the output of your scripts and display stacktraces. If
you specify different formatters, the default formatter will not be used. So if
you still want output to the terminal, you need to add this formatter.

    $ scripted -f default -f some_other_formatter

#### Table formatter

The `table` formatter will display an ASCII table when it's done, giving an
overview of all commands.

It looks something like this:

```
┌─────────────────┬─────────┬─────────┐
│ Command         │ Runtime │ Status  │
├─────────────────┼─────────┼─────────┤
│ rspec           │  0.661s │ success │
│ cucumber        │ 18.856s │ success │
│ cucumber -p wip │  0.558s │ success │
└─────────────────┴─────────┴─────────┘
  Total runtime: 19.527s
```

To use it:

    $ scripted --format table

#### Announcer formatter

This will print a banner before each command, so you can easily see when a
command is executed.

It looks something like this:

```
┌────────────────────────────────────────────────┐
│                 bundle update                  │
└────────────────────────────────────────────────┘
```

To use it:

    $ scripted --format announcer

#### Stats formatter

The `stats` formatter will print a csv file with the same contents as the
`table`-formatter. This is handy if you want to keep track of how long your
test suite takes over time, for example.

Example:

``` csv
name,runtime,status
bundle update,5.583716,success
rspec,4.319095,success
cucumber,22.292316,failed
cucumber -p wip,0.649777,success
```

To use it:

    $ scripted --format stats --out runtime.csv

Note: make sure you backup the file afterwars, because each time it runs, it
will override the file.

#### Websocket formatter

And last, but not least, the `websocket` formatter. This awesome formatter will
publish the output of your commands directly to a websocket.

This is done via [Faye](http://faye.jcoglan.com/), a simple pub/sub messaging
system. It is tricky to implement this, so be sure to check out the example
code, which includes a fully functioning Ember.js application.

    $ scripted -f websocket -o http://localhost:9292/faye

Make sure you have Faye running. The example does this for you.

![Example of the output](https://raw.github.com/iain/scripted/master/examples/websockets.png)

#### Your own formatter

You can also make your own formatter. As the name of the formatter, just
specify the class name:

    $ scripted -f MyAwesome::Formatter

Have a look at the existing formatters in `lib/scripted/formatters` to see how
to make one.

### Groups

You can specify different groups of commands by putting commands in a `group`
block:

``` ruby
group :test do
  run "rspec"
  run "cucumber"
end

group :install do
  run "bundle install"
  rake "db:setup"
end
```

Then you can specify one or many groups to run on the command line:

    $ scripted --group install --group test

Commands that are not defined in any group are put in the `default` group.

### Rake integration

Besides calling Rake tasks from Scripted, you can also launch scripted via
Rake.

The simplest example is:

``` ruby
require 'scripted/rake_task'
Scripted::RakeTask.new(:scripted)
```

Then you can run `rake scripted`

You can pass a block to specify your commands in-line if you like:

``` ruby
require 'scripted/rake_task'
Scripted::RakeTask.new(:install) do
  run "foo"
  run "bar"
end
```

You can also supply different groups to run:

```
require 'scripted/rake_task'
Scripted::RakeTask.new(:ci, :install, :test)
```

Running `rake ci` will run both the `install` and `test` group.

### Ruby integration

Calling scripted from within another Ruby process is easy:

``` ruby
require 'scripted'
Scripted.run do
  run "something"
end
```

## Some considerations

### Use cases

I first named this library "test_suite", and most examples show running test
suites. But Scripted isn't only for running tests. Here are some ideas:

* Installing stuff, like installing stuff you want 
* Running a command perminantly and seeing the output via websockets. Like
  ping, your server, or a tool that monitors your worker queues.

### Complicated setup

The beauty if plain bash scripts is that they can be run without having
anything installed. The problem with Scripted is that it is a gem and you might
need to `gem install scripted` or `bundle install` before it will work.

I prefer to have the README of my projects say, something along the lines of:

``` md
## How To

* Install: `script/install`
* Upgrade: `script/upgrade`
* Deploy: `script/deploy`
```

Nothing more. No complicated 10 step plan, just type one command and you're
good to go. You need a bash script for that.

So here is an example of how such a bash script might look like:

``` bash
#!/usr/bin/env bash
set -e
gem which scripted >/dev/null 2>&1 || gem install scripted
scripted --group install
```

### Status of the gem

This gem is in alpha state. YMMV. I believe I got the basic functionality, but
not everything is as cleanly implemented as it could be. For instance, there
are undoubtedly edge cases I didn't think of and error handling can probably be
more user friendly.

I'm putting this out there to get some feedback. Please don't hesitate to
contact me if you have any questions or ideas for improvements. Mention me on
[Twitter](https://twitter.com/iain_nl), or open an issue on Github.

### Known issues

* Only works on MRI 1.9 and Rubinius in 1.9 mode.
* JRuby and Ruby 1.8 don't play well with some Unix related stuff.

## Contributing

To set it up, just run `./install`.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

