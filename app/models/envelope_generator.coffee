 # Taken almost verbatim from the moog google-doogle and rewritten in coffescript.
 #
 # http://code.google.com/p/bob-moog-google-doodle/source/browse/oscillator.js


 # An ADSD envelope generator, used to control volume of a single synth note.
 # See the Phase_ enum below for a description of how ADSD envelopes work.
 # @param {number} sampleInterval How many seconds pass with each sample.
 # @param {number} attackTime Initial attack time in seconds.
 # @param {number} decayTime Initial decay time in seconds.
 # @param {number} sustainLevel Initial sustain level [0..1].
 # @constructor

class EnvelopeGenerator
  # The different phases of an ADSD envelope.  When playing a key on a synth,
  # these phases are always executed in the order they're defined in this enum.
  # @enum {number}
  # @private
  @Phase_ = {
    # A linear ramp up from no volume (just before a key is struck) to maximum
    # volume.
    ATTACK: 0,
    # A linear ramp down from maximum volume to the sustain volume level.
    DECAY: 1,
    # Once the attack and decay phases have completed, the volume at which the
    # note is held until the key is released.
    SUSTAIN: 2,
    # A linear ramp down from the sustain volume to no volume after a key is
    # released.  Moog instruments uniquely reuse the decay time parameter for the
    # release time (hence the "ADSD" acronym instead of "ADSR").
    RELEASE: 3,
    # Meta state indicating that the envelope is not currently active.
    INACTIVE: 4
  }
  constructor: (sampleInterval, attackTime, decayTime, sustainLevel) ->

    # How many seconds pass with each sample.
    # @type {number}
    # @private
    # @const
    @SAMPLE_INTERVAL_ = sampleInterval

    # The amount by which the tone associated with this envelope should be
    # scaled.  A number in the range [0, 1].
    # @type {number}
    # @private
    @amplitudeCoefficient_ = 0

    # The current phase of the envelope.
    # @type {!EnvelopeGenerator.Phase_}
    # @private
    @setPhase EnvelopeGenerator.Phase_.INACTIVE

    # The duration of the attack phase in seconds.
    # @type {number}
    # @private
    @attackTime_ = attackTime


    # How much the amplitude should be increased for each sample in the attack
    # phase.
    #
    # NOTE: This variable and other 'step' variables can be computed from other
    # EnvelopeGenerator state.  We explicitly store these values though since
    # they are precisely the data needed in getNextAmplitudeCoefficient which is
    # typically executed in a sound buffer filling loop and therefore performance
    # critical.
    # @type {number}
    # @private
    @attackStep_

    # The duration of the decay phase in seconds.
    # @type {number}
    # @private
    @decayTime_ = decayTime

    # How much the amplitude should be decreased for each sample in the decay
    # phase.
    # @type {number}
    # @private
    @decayStep_

    # The sustain amplitude coefficient.
    # @type {number}
    # @private
    @sustainLevel_ = sustainLevel

    # How much the amplitude should be decreased for each sample in the release
    # phase.
    # @type {number}
    # @private
    @releaseStep_
    @recomputePhaseSteps_()



  setPhase: (phase) ->
    @phase_ = phase

   # Initiates the attack phase of the envelope (e.g., when a key is pressed).
  startAttack: ->
    @recomputePhaseSteps_()
    @amplitudeCoefficient_ = 0
    @setPhase EnvelopeGenerator.Phase_.ATTACK

  # Initiates the release phase of the envelope (e.g., when a key is lifted).
  startRelease: () ->
    if @phase_ is EnvelopeGenerator.Phase_.RELEASE
      return
    else
      # Compute release step based on the current amplitudeCoefficient_.
      if @decayTime_ <= 0
        @releaseStep_ = 1
      else
        @releaseStep_ = @amplitudeCoefficient_ * @SAMPLE_INTERVAL_ / @decayTime_
    @setPhase EnvelopeGenerator.Phase_.RELEASE


   # Gets the next amplitude coefficient that should be applied to the currently
   # playing note.  This method must be called (and applied, natch) for each
   # sample filled for the duration of a note.
   # @return {number} An amplitude coefficient in the range [0, 1] that should be
   #     applied to the current sample.
  getNextAmplitudeCoefficient: ->
    switch @phase_
      when EnvelopeGenerator.Phase_.ATTACK
        @amplitudeCoefficient_ += @attackStep_
        if (@amplitudeCoefficient_ >= 1)
          @amplitudeCoefficient_ = 1
          @setPhase EnvelopeGenerator.Phase_.DECAY
      when EnvelopeGenerator.Phase_.DECAY
        @amplitudeCoefficient_ -= @decayStep_
        if @amplitudeCoefficient_ <= @sustainLevel_
          @amplitudeCoefficient_ = @sustainLevel_
          @setPhase EnvelopeGenerator.Phase_.SUSTAIN
      #when EnvelopeGenerator.Phase_.SUSTAIN
        ## Just stay at the sustain level until a release is signaled.
        #@phase_ = @phase
      when EnvelopeGenerator.Phase_.RELEASE
        @amplitudeCoefficient_ -= @releaseStep_
        if (@amplitudeCoefficient_ <= 0)
          @amplitudeCoefficient_ = 0
          @setPhase EnvelopeGenerator.Phase_.INACTIVE
      # Not sure why yet, but this causes an odd bouncing attack, and
      # commenting out seems to fix.
      #when EnvelopeGenerator.Phase_.INACTIVE
        # Stay at 0, as set in the release transition (muted).
        #@phase_ = 0
    @amplitudeCoefficient_

  # Sets attack phase duration.
  # @param {number} time Duration of the attack phase in seconds.
  setAttackTime: (time) ->
    @attackTime_ = time
    @recomputePhaseSteps_()

  # Sets decay phase duration.
  # @param {number} time Duration of the decay phase in seconds.
  setDecayTime: (time) ->
    @decayTime_ = time
    @recomputePhaseSteps_()

  # Sets the sustain level.
  # @param {number} level The sustain level, a number in the range [0, 1].
  setSustainLevel: (level) ->
    @sustainLevel_ = level
    @recomputePhaseSteps_()

  # Updates phase step variables to reflect current EnvelopeGenerator state.
  # @private
  recomputePhaseSteps_: () ->
    @attackStep_ = if @attackTime_ <= 0 then 1 else @SAMPLE_INTERVAL_ / @attackTime_

    if @decayTime_ <= 0
      @decayStep_ = 1
      @releaseStep_ = 1
    else
      @decayStep_ =
        (1 - @sustainLevel_) * @SAMPLE_INTERVAL_ / @decayTime_
      @releaseStep_ =
        @sustainLevel_ * @SAMPLE_INTERVAL_ / @decayTime_

module.exports = EnvelopeGenerator
