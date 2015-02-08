class Langtrainer.LangtrainerApp.Views.StepView extends Backbone.View
  _.extend(@prototype, Langtrainer.LangtrainerApp.Views.Extensions.Localized)

  template: JST['langtrainer_frontend_backbone/templates/step_view']
  className: 'row'
  id: 'step-view'

  STEPS_NUMBER_TO_SUGGEST_SIGN_UP: 10
  stepsCounter: 0

  events:
    'keyup .lt-answer': 'onKeyup'
    'keypress .lt-answer': 'onKeypress'
    'click .lt-show-next-word': 'onShowNextWord'
    'click .lt-check-answer': 'onCheckAnswer'
    'click .lt-show-right-answer': 'onShowRightAnswer'
    'click .lt-next-step': 'onNextStep'
    'click .lt-question-help-toggle': 'onQuestionHelpToggle'

  initialize: ->
    @listenTo Langtrainer.LangtrainerApp.world.get('step'), 'change', @renderStep
    @listenTo Langtrainer.LangtrainerApp.world.get('language'), 'change', @renderStep
    @listenTo Langtrainer.LangtrainerApp.world.get('nativeLanguage'), 'change', @renderStep

    @listenTo Langtrainer.LangtrainerApp.currentUser, 'change:question_help_enabled', @onQuestionHelpChanged

    @listenTo @model, 'keyup:wrong', @onWrongKeyUp
    @listenTo @model, 'keyup:right', @onRightKeyUp
    @listenTo @model, 'keyup:empty', @onEmptyKeyUp

    @listenTo @model, 'verify:right', @onVerifyRight
    @listenTo @model, 'verify:wrong', @onVerifyWrong
    @listenTo @model, 'verify:error', @onVerifyError

    @initLocalization(onLocaleChanged: @render)

  render: ->
    @$el.html(@template())
    @$input = @$('.lt-answer')
    @$('.lt-check-answer').closest('li').popover
      title: ''
      content: LangtrainerI18n.t('step_view.popover.hotkey.check')
      placement: 'top'
      trigger: 'manual'

    @renderStep()

    @

  renderStep: ->
    @$('.lt-question').text(@model.question(@currentNativeLanguage()))
    @$('.lt-answer').val('')
    @onQuestionHelpChanged()

    questionHelp = @model.questionHelp(@currentLanguage())
    if questionHelp? && questionHelp.length > 0
      @$('.lt-question-notification').sticky(questionHelp, autoclose: false)
    else
      @$('.lt-question-help-toggle').addClass('disabled')

    @

  toggleQuestionHelp: ->
    Langtrainer.LangtrainerApp.currentUser.toggleQuestionHelp()

  currentLanguage: ->
    Langtrainer.LangtrainerApp.currentUser.getCurrentLanguage()

  currentNativeLanguage: ->
    Langtrainer.LangtrainerApp.currentUser.getCurrentNativeLanguage()

  isVerifyKey: (event) ->
    event.which is 13 && !event.shiftKey

  onKeypress: (event) ->
    if @isVerifyKey(event)
      return false

    true

  onKeyup: (event) ->
    if @isVerifyKey(event)
      @verifyAnswerOnServer()
    else
      @model.verifyAnswer(@$input.val(), @currentLanguage(), 'keyup')
    true

  onWrongKeyUp: ->
    @$('.lt-wrong-answer').show()

  onRightKeyUp: ->
    @$('.lt-wrong-answer').hide()

  onEmptyKeyUp: ->
    @$('.lt-wrong-answer').hide()

  onShowNextWord: ->
    answer = @$input.val()
    matches = @model.nextWord(answer, @currentLanguage())

    if matches?
      ending = matches[1]

      if ending.length > 0
        @$input.val("#{answer}#{ending}")
      else
        nextWord = matches[2]

        if nextWord.length > 0
          @$input.val("#{answer} #{nextWord}")

      @model.verifyAnswer(@$input.val(), @currentLanguage(), 'keyup')
    false

  onShowRightAnswer: ->
    answers = @model.answers(@currentLanguage())
    _.each answers.reverse(), (rightAnswer, index) ->
      @$('.lt-answer-notification').sticky("#{LangtrainerI18n.t('step_view.popover.answer')} ##{answers.length - index}: #{rightAnswer}", autoclose: 10000)

    @model.showRightAnswer()
    false

  onNextStep: ->
    @model.nextStep()
    false

  verifyAnswerOnServer: ->
    @model.verifyAnswerOnServer(@$input.val(), @currentLanguage())

  onCheckAnswer: ->
    @verifyAnswerOnServer()
    @showHotkeyPopover()
    false

  showHotkeyPopover: ->
    @$('.lt-check-answer').closest('li').popover('show')
    close = =>
      @$('.lt-check-answer').closest('li').popover('hide')
    setTimeout(close, 3000)

  onVerifyRight: ->
    @$('.lt-answer-notification').sticky(LangtrainerI18n.t('step_view.popover.right_answer'))
    if !Langtrainer.LangtrainerApp.currentUser.signedIn()
      @stepsCounter += 1
      if @stepsCounter > @STEPS_NUMBER_TO_SUGGEST_SIGN_UP
        @stepsCounter = 0
        @$('.lt-answer-notification').sticky(LangtrainerI18n.t('step_view.popover.sign_up'))

  onVerifyWrong: ->
    @$('.lt-answer-notification').sticky(LangtrainerI18n.t('step_view.popover.wrong_answer'))

  onVerifyError: ->
    @$('.lt-answer-notification').sticky(LangtrainerI18n.t('error'))

  onQuestionHelpToggle: ->
    Langtrainer.LangtrainerApp.currentUser.toggleQuestionHelp()
    false

  onQuestionHelpChanged: ->
    if Langtrainer.LangtrainerApp.currentUser.questionHelpEnabled()
      @$('.lt-question-help-disabled').addClass('hide')
      @$('.lt-question-help-enabled').removeClass('hide')
      @$('.lt-question-notification').slideDown()
    else
      @$('.lt-question-help-disabled').removeClass('hide')
      @$('.lt-question-help-enabled').addClass('hide')
      @$('.lt-question-notification').slideUp()
