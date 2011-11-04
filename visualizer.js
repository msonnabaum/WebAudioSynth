//$(document).ready(function() {

var canvas = document.getElementById('fft'),
ctx = canvas.getContext('2d'),
channels,
rate,
frameBufferLength,
fft;
/*
function loadedMetadata() {
  channels          = audio.mozChannels;
  rate              = audio.mozSampleRate;
  frameBufferLength = audio.mozFrameBufferLength;
  fft = new FFT(frameBufferLength / channels, rate);
}

function audioAvailable(event) {
  var fb = event.frameBuffer,
  t  = event.time,
  signal = new Float32Array(fb.length / channels),
  magnitude;

  for (var i = 0, fbl = frameBufferLength / 2; i < fbl; i++ ) {
    // Assuming interlaced stereo channels,
    // need to split and merge into a stero-mix mono signal
    signal[i] = (fb[2*i] + fb[2*i+1]) / 2;
  }

  fft.forward(signal);

  // Clear the canvas before drawing spectrum
  ctx.clearRect(0,0, canvas.width, canvas.height);

  for (var i = 0; i < fft.spectrum.length; i++ ) {
    // multiply spectrum by a zoom value
    magnitude = fft.spectrum[i] * 4000;

    // Draw rectangle bars for each frequency bin
    ctx.fillRect(i * 4, canvas.height, 3, -magnitude);
  }
}
*/
//});

