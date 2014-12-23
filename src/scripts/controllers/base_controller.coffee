###
# Crafting Guide - base_controller.coffee
#
# Copyright (c) 2014 by Redwood Labs
# All rights reserved.
###

views = require '../views'

########################################################################################################################

module.exports = class BaseController extends Backbone.View

    constructor: (options={})->
        @_rendered = false
        @_parent   = options.parent
        @_children = []

        @_loadTemplate options.templateName
        super options

    # Public Methods ###############################################################################

    addChild: (Controller, atSelector, options={})->
        options.el = @$(atSelector)[0]
        options.parent = this

        child = new Controller options
        child.render()
        @_children.push child
        return child

    refresh: ->
        logger.verbose "#{this} refreshing"

    # Event Methods ################################################################################

    onWillRender: -> # do nothing

    onDidRender: ->
        @refresh()

    # Backbone.View Overrides ######################################################################

    render: (options={})->
        return this unless not @_rendered or options.force

        data = (@model?.toHash? and @model.toHash()) or @model or {}

        if not @_template?
            logger.error "Default render called for #{@constructor.name} without a template"
            return this

        logger.verbose "#{this} rendering with data: #{data}"
        @onWillRender()
        $oldEl = @$el
        $newEl = Backbone.$(@_template(data))
        if $oldEl
            $oldEl.replaceWith $newEl
            $newEl.addClass $oldEl.attr 'class'

        @setElement $newEl
        @_rendered = true
        @onDidRender()

        return this

    # Object Overrides #############################################################################

    toString: ->
        return "#{@constructor.name}(#{@cid})"

    # Private Methods ##############################################################################

    _loadTemplate: (templateName)->
        if templateName?
            @_template = views[templateName]