class Langtrainer.LangtrainerApp.Models.World extends Backbone.Model
  url: -> Langtrainer.LangtrainerApp.apiEndpoint + '/world?token=' + Langtrainer.LangtrainerApp.currentUser.readAttribute('token')

  initialize: ->
    Langtrainer.LangtrainerApp.world = @
    @set('step', new Langtrainer.LangtrainerApp.Models.Step)
    @set('unit', new Langtrainer.LangtrainerApp.Models.Unit)
    @set('course', new Langtrainer.LangtrainerApp.Models.Course)
    @set('language', new Langtrainer.LangtrainerApp.Models.Language)
    @set('nativeLanguage', new Langtrainer.LangtrainerApp.Models.Language)

    @set('coursesCollection', new Langtrainer.LangtrainerApp.Collections.Courses)
    @set('nativeLanguagesCollection', new Langtrainer.LangtrainerApp.Collections.Languages)
    @set('languagesCollection', new Langtrainer.LangtrainerApp.Collections.Languages)
    @set('unitsCollection', new Langtrainer.LangtrainerApp.Collections.Units)

    @listenTo @, 'change:token', @reset

    @listenTo @get('course'), 'change:slug', @onCourseChanged
    @listenTo @get('unit'), 'change:slug', @onUnitChanged
    @listenTo @get('nativeLanguage'), 'change:slug', @onNativeLanguageChanged


  reset: ->
    @get('coursesCollection').reset(@get('courses'))
    @get('nativeLanguagesCollection').reset(@get('languages'))

    @get('course').set Langtrainer.LangtrainerApp.currentUser.getCurrentCourse().attributes

    @get('nativeLanguage').set Langtrainer.LangtrainerApp.currentUser.getCurrentNativeLanguage().attributes

  onCourseChanged: (course) ->
    @get('unitsCollection').reset course.get('units')
    @get('unit').set course.getCurrentUnit().attributes

  onUnitChanged: (unit) ->
    @get('step').set unit.get('current_step')

  onNativeLanguageChanged: (nativeLanguage) ->
    nativeSlug = nativeLanguage.get('slug')
    languages = _.reject @get('languages'), (language) -> language.slug == nativeSlug
    @get('languagesCollection').reset languages

    @get('language').set Langtrainer.LangtrainerApp.currentUser.getCurrentLanguage().attributes
