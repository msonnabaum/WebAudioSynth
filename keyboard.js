(function(){
    // remove layerX and layerY
    var all = $.event.props,
        len = all.length,
        res = [];
    while (len--) {
      var el = all[len];
      if (el != 'layerX' && el != 'layerY') res.push(el);
    }
    $.event.props = res;
}());
function Keyboard(numOctaves) {
  this.keys = {};

  this.keyState = {};

  this.keyMap = {};

  this.keysAvail = [
    '65', // a
    '87', // w
    '83', // s
    '69', // e
    '68', // d

    '70', // f
    '84', // t
    '71', // g
    '89', // y
    '72', // h
    '85', // u
    '74', // j

    '75', // k
    '79', // o
    '76', // l
    '80', // p
    '186', // ;
  ];

  $('body').append('<div id="keyboard"></div>');

  var numOctaves = numOctaves || 4;
  this.pos = numOctaves / 2;
  //         A  Bb B  C  C# D  Eb E  F  F# G  G#
  var pat = [0, 1, 0, 2, 1, 0, 1, 0, 2, 1, 0, 1];
  var pitch = 9 + (((8 - numOctaves) / 2) * 12);
  var keys = [];
  keyMapId = 0;
  keys.push('<div id="octave-wrapper-0" class="octave_wrapper">');
  for (var i = 1; i < numOctaves; i++) {
    for (var j = 0; j < pat.length; j++) {
      switch(pat[j]) {
       case 0:
        css_class = 'white';
       break;
      case 1:
        css_class = 'black';
       break;
      case 2:
        css_class = 'cf white';
       break;
      }
      keys.push('<div id="' + pitch + '" class="key ' + css_class + '" ></div>');
      this.keyMap[this.keysAvail[keyMapId]] = pitch;
      keyMapId++;
      pitch++;
    }
    keys.push('<div style="clear:right"></div></div>');
    keys.push('<div id="octave-wrapper-' + i + '" class="octave_wrapper">');
  };
  $('#keyboard').append(keys.join(""));

  $('#octave-wrapper-' + this.pos).addClass('active-octave');

  var that = this;
  $(document).keydown(function(e) {
    var keyCode = e.which;
    if ($.inArray(keyCode, [37,39]) >= 0) {
      switch(keyCode) {
        case 37:
          that.pos--;
          break;
        case 39:
          that.pos++;
          break;
      }
      $('.active-octave').removeClass('active-octave');
      $('#octave-wrapper-' + that.pos).addClass('active-octave');
    }
    else if ($.inArray(keyCode.toString(), that.keysAvail) >= 0) {
    // For some reason keydown sends repeatedly if held down.
    if (that.keyState[keyCode] != 1) {
      that.keyState[keyCode] = 1;
      //key = that.keyMap[keyCode];
      key = that.keyMap[keyCode] + (12 * that.pos);
      $('#' + key + ".white").addClass("white-down");
      $('#' + key + ".black").addClass("black-down");
      that.down(key);
    }
  }
  }).keyup(function(e) {
    var keyCode = e.which;
    if ($.inArray(keyCode.toString(), that.keysAvail) >= 0) {
      that.keyState[keyCode] = 0;
      key = that.keyMap[keyCode] + (12 * that.pos);
      $('#' + key + ".white").removeClass("white-down");
      $('#' + key + ".black").removeClass("black-down");
      that.up(key);
    }
  });
}

Keyboard.prototype.play = function(keyId) {
}

Keyboard.prototype.up = function(keyId) {
  this.keys[keyId].off();
}

Keyboard.prototype.down = function(keyId) {
  if (!(keyId in this.keys)) {
    this.keys[keyId] = new Note(keyId);
  }
  this.keys[keyId].on();
}


$(document).ready(function() {


  keys = new Keyboard(6);
});

