Scripted = Em.Application.create

  received: (data) ->
    action = @["on_#{data.action}"]
    action(data) if action

  on_start: (data) ->
    Scripted.CommandsController.clear()
    Scripted.Runner.setProperties(data.runner)
    for command in data.commands
      Scripted.updateCommand(command)

  on_stop: (data) ->
    Scripted.Runner.setProperties(data.runner)
    for command in data.commands
      Scripted.updateCommand(command)

  on_execute: (data) ->
    Scripted.updateCommand(data.command)

  on_done: (data) ->
    Scripted.updateCommand(data.command)

  on_output: (data) ->
    for output in data.output
      command = Scripted.updateCommand(output.command).set('output', output.output)

  updateCommand: (command) ->
    Scripted.CommandsController.updateOrCreate(command)

Scripted.ConnectionStatus = Em.Object.create

  status: "error"
  message: "No Connection"

  success: ->
    if @get('hasErrored')
      window.location.reload()
    @set 'status', 'success'
    @set 'message', 'Connected'

  error: (message) ->
    @set 'status', 'error'
    @set 'message', "Error: #{message}"
    @set 'hasErrored', true



Scripted.ConnectionStatusView = Em.View.extend

  contentBinding: 'Scripted.ConnectionStatus'
  tagName: 'span'
  classNameBindings: ['default', 'status']

  default: "pull-right label"

  status: (->
    switch @get('content').get('status')
      when "success" then "label-success"
      when "error" then "label-important"
      else "label-warning"
  ).property('content.status')



Scripted.CommandStatusView = Em.View.extend

  tagName: 'span'
  classNameBindings: ['className']

  text: (->
    @get('content').get('human_status')
  ).property('content.human_status')

  className: (->
    status_code = @get('content').get('status_code')
    switch status_code
      when "running"                                             then "label label-info"
      when "success", "success_ran_because_other_command_failed" then "label label-success"
      when "failed", "failed_ran_because_other_command_failed"   then "label label-important"
      when "failed_but_ignored"                                  then "label label-warning"
      when "failed_and_halted"                                   then "label label-inverse"
      else "label"
  ).property('content.status_code')

Scripted.CommandView = Em.View.extend

  classNameBindings: ['content.status_code']

  output: (->
    html = ""
    output = @get('content').get('output')
    nodes = ansiparse(output)
    for node in nodes
      html += "<span class='#{node.foreground}'>#{node.text}</span>"
    new Handlebars.SafeString(html)
  ).property('content.output')

  hasOutput: (->
    output = @get('content').get('output')
    output and output != ""
  ).property('content.output')

  outputChanged: (->
    output = this.$('.output')
    scrollDown = -> output[0].scrollTop = output[0].scrollHeight + 100000
    if output.length > 0
      setTimeout scrollDown, 100
      setTimeout scrollDown, 500
  ).observes('output', 'content.status_code')

Scripted.Runner = Em.Object.create

  running: false
  executed: false
  started_at: null

  roundedRuntime: (->
    value = @get('runtime')
    if value
      value.toFixed(3)
    else
      ""
  ).property('runtime')

Scripted.RunnerView = Em.View.extend

  contentBinding: 'Scripted.Runner'
  classNameBindings: ["alert", "alertType"]

  alert: (-> "alert").property()

  message: (->
    content = @get('content')
    commandsCount = "<strong>#{Scripted.CommandsController.content.length}</strong>"
    started_at = content.get('started_at')
    text = if Scripted.CommandsController.get('hasCommands')
      if not content.get('executed')
        "Running #{commandsCount} commands"
      else if content.get('failed')
        "One or more commands have failed"
      else
        "Success! Ran #{commandsCount} commands in <strong>#{content.get('roundedRuntime')}</strong> seconds"
    else
      "There are <strong>no</strong> commands yet."
    new Handlebars.SafeString(text)
  ).property('content.started_at', 'content.failed', 'content.executed', 'content.roundedRuntime', 'Scripted.CommandsController.hasCommands')

  alertType: (->
    failed = @get('content').get('failed')
    running = @get('content').get('running')
    executed = @get('content').get('executed')
    if failed
      "alert-error"
    else if running
      "alert-info"
    else if executed
      "alert-success"
    else
      ""
  ).property('content.failed', 'content.running', 'content.executed')

Scripted.Command = Em.Object.extend

  id: null
  name: ""
  status_code: "unknown"
  output: ''

  roundedRuntime: (->
    value = @get('runtime')
    if value
      value.toFixed(3)
    else
      ""
  ).property('runtime')

Scripted.CommandsController = Em.ArrayController.create

  content: []

  updateOrCreate: (data) ->
    command = @findCommand(data)
    if command
      command.setProperties(data)
    else
      command = Scripted.Command.create(data)
      @pushObject(command)
      command


  findCommand: (data) ->
    if @get('hasCommands')
      @find((command) -> command.get('id') is data.id)
    else
      null

  hasCommands: (->
    @get('content').length > 0
  ).property('lastObject')

jQuery ->
  client = new Faye.Client('http://localhost:9292/faye')
  subscription = client.subscribe '/scripted', (data) -> Scripted.received(data)
  subscription.callback -> Scripted.ConnectionStatus.success()
  subscription.errback (error) -> Scripted.ConnectionStatus.error(error.message)
  client.bind 'transport:down', -> Scripted.ConnectionStatus.error("No Connection")
  client.bind 'transport:up', -> Scripted.ConnectionStatus.success()

window.Scripted = Scripted
