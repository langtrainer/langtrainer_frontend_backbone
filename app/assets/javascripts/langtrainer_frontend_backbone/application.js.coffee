#= require_self
#= require ./backbone_patch
#= require_tree ./models/extensions
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./templates
#= require_tree ./views/extensions
#= require_tree ./views
#= require_tree ./routers

window.Langtrainer.LangtrainerApp =
  Models:
    Extensions: {}
  Collections: {}
  Views:
    Extensions: {}
    Dialogs: {}
  Routers: {}

  commonRouter: null
  world: null
  currentUser: null
  globalBus: _.extend({}, Backbone.Events)

  apiEndpoint: ''

  run: (initialData, successCallback, errorCallback)->
    @csrfToken = $("meta[name='csrf-token']").attr('content')

    @apiEndpoint = initialData.apiEndpoint
    @world = new Langtrainer.LangtrainerApp.Models.World
    @setUpCurrentUser(JSON.parse(initialData.currentUser || '{}'))

    @world.fetch(success: successCallback, error: errorCallback)

    @commonRouter = new Langtrainer.LangtrainerApp.Routers.CommonRouter

    @globalBus.on 'user:signedIn', @setUpCurrentUser, @
    @globalBus.on 'user:signedOut', => @setUpCurrentUser({}), @
    @globalBus.on 'signInDialog:hidden', @navigateRoot, @
    @globalBus.on 'signUpDialog:hidden', @navigateRoot, @

    Backbone.history.start()

  setUpCurrentUser: (attrs)->
    @currentUser = new Langtrainer.LangtrainerApp.Models.User(attrs)

  navigate: (fragment, options)->
    scroll = $(window).scrollTop()

    @commonRouter.navigate(fragment, options)

    $(window).scrollTop(scroll)

  navigateRoot: ->
    @navigate('/')

  navigateToSignIn: ->
    @navigate('sign_in', trigger: true)

  navigateToSignUp: ->
    @navigate('sign_up', trigger: true)

  clearCookies: ->
    _.each $.cookie(), (value, key) ->
      $.removeCookie(key)
