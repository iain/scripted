var controlBlinker = function() {
  var cursor = document.getElementById('cursor');
  if (cursor) { cursor.style.display = cursor_display; }
}

var connect = function() {
    var client = new Faye.Client('http://localhost:9292/faye');
    var state = document.getElementById('status');
    var log = document.getElementById('log');
    var cursor = '<span id="cursor">&nbsp;</span>';
    var _prompt = '<span id="prompt">$ </span>';
    var cursor_display = "inline";

    var movePrompt = function() {
      var element = document.getElementById('cursor');
      if (element) { element.parentNode.removeChild(element); }
      log.innerHTML += cursor;
      controlBlinker();
      log.scrollTop = log.scrollHeight;
    }

    var lastTime = null;

    var subscription = client.subscribe('/foo', function(data) {
      if (data.action === "start") {
        log.innerHTML = cursor;
      } else if ( data.action === "execute" ) {
        log.innerHTML += ("<h2 class='blue'>Executing: " + data.command.name + "</h2>");
        lastTime = (new Date()).getTime();
        log.innerHTML += "<span id='console-"+lastTime+"'></span>"
      } else if (data.action === "output") {
        var parsed = ansiparse(data.output);
        var length = parsed.length;
        var console = document.getElementById("console-" + lastTime);
        var html = "";
        for (var i = 0; i < length; i++) {
          var x = parsed[i];
          html += ("<span class='" + x.foreground + "'>" + x.text + "</span>");
        }
        console.innerHTML = html;
      } else if (data.action === "done") {
        if (data.command.success) {
          log.innerHTML += "<h2 class='green'>Command " + data.command.name + " executed successfully!</h2>"
        } else {
          log.innerHTML += "<h2 class='red'>Command " + data.command.name + " failed!</h2>"
        }
      } else if (data.action === "close") {
        log.innerHTML += "<h2 class='grey'>Done.</h2>";
        log.innerHTML += _prompt;
      }
      movePrompt();
    });

    subscription.callback(function() {
      state.className = 'label label-success';
      state.innerHTML = 'connected';
      log.innerHTML = _prompt + cursor;
    });

    subscription.errback(function(error) {
      state.className = 'label label-important';
      state.innerHTML = 'Error: ' + error.message;
    });

    client.bind('transport:down', function() {
      state.className = 'label label-important';
      state.innerHTML = "No connection"
    });

    client.bind('transport:up', function() {
      state.className = 'label label-success';
      state.innerHTML = 'connected';
    });

}

var blinker = function() {

  var off = function() {
    cursor_display = "none";
    controlBlinker();
    setTimeout(on, 1000);
  }

  var on = function() {
    cursor_display = "inline";
    controlBlinker();
    setTimeout(off, 1000);
  }

  setTimeout(off, 1000);
}


window.onload = function() {
  connect();
  blinker();
}
