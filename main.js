
function Synth (audiolet, frequency) {
  this.audiolet = audiolet;
  AudioletGroup.apply(this, [this.audiolet, 1, 1]);
 // this.limiter = new Limiter(this.audiolet, .1);
  this.limiter = new Limiter(this.audiolet, 0.3);
  //this.reverb = new LaggedReverb(this.audiolet, 0.1);

  //this.sine = new Sine(this.audiolet, frequency);
  this.sine = new Triangle(this.audiolet, frequency);

  this.lag = new Lag(this.audiolet, 0, 1);
  this.gain = this.lag.value;
  this.gainNode = new Gain(this.audiolet);

  this.sine.connect(this.gainNode);
  this.lag.connect(this.gainNode, 0, 1);
  //this.limiter.connect(this.outputs[0]);
  //this.gainNode.connect(this.outputs[0]);
  this.gainNode.connect(this.limiter);
  //this.gainNode.connect(this.outputs[0]);
  //
  //
  //this.reverb.connect(this.limiter);
  this.limiter.connect(this.audiolet.output);

  this.spectrum();
}
extend(Synth, AudioletGroup);

Synth.prototype.spectrum = function() {
  var dft = new FFT(4096, 44100);

  var updateSpectrum = function() {
  dft.forward(this.audiolet.device.buffer.channels[0]);
  var spectrum = dft.spectrum;
    // Clear the canvas before drawing spectrum
    ctx.clearRect(0,0, canvas.width, canvas.height);
    for (var i = 0; i < spectrum.length; i++ ) {
      // multiply spectrum by a zoom value
      magnitude = spectrum[i] * 4000;

      // Draw rectangle bars for each frequency bin
      ctx.fillRect(i * 4, canvas.height, 3, -magnitude);
    }
    setTimeout(updateSpectrum, 100);
  }

  updateSpectrum();
}

var audiolet = new Audiolet();


function Note(pitch) {
  this.pitch = pitch;
  //this.audiolet = new Audiolet();
}

Note.prototype.on = function() {
  var f = this.freq(this.pitch);
  //this.synth = new Synth(this.audiolet, f);
  this.synth = new Synth(audiolet, f);
  console.log("Note: " + this.pitch + ", Frequency: " + f);
  var value = 1.0 / Object.keys(keys.keyState).length;
  this.synth.gain.setValue(value);
  this.synth.connect(audiolet.output);
}

Note.prototype.off = function() {
  this.synth.gain.setValue(0);
  var lag = this.synth.lag.lag.getValue();
  var that = this;
  setTimeout(function() {
    that.synth.remove();
  }, lag * 1000);
}

Note.prototype.freq = function() {
  return 440 * Math.pow(2, ((this.pitch - 60)/12));
}
