'use strict'

module.exports = (grunt) ->
  coffeelint = require './coffeelint.json'

  # configurable paths
  yeomanConfig =
    app: 'lib'
    dist: 'dist'
    test: 'spec'

  grunt.initConfig
    yeoman: yeomanConfig

    jasmine_node:
      specNameMatcher: "spec"
      projectRoot: "."
      requirejs: false
      forceExit: true
      useCoffee: true
      extensions: 'coffee'
      jUnit:
        report: false
        savePath: "./build/reports/jasmine/"
        useDotNotation: true
        consolidate: true

    coffeelint:
      options: coffeelint
      gruntfile:
        files:
          src: ['Gruntfile.coffee']
      lib:
        files:
          src: ['<%= yeoman.app %>/{,*/}*.coffee']
      test:
        files:
          src: ['<%= yeoman.test %>/{,*/}*.coffee']

    watch:
      lib:
        files: ['<%= yeoman.app %>/{,*/}*.coffee']
        tasks: [
          'coffeelint:lib'
        ]
      'unit-watch':
        files: [
          '<%= yeoman.app %>/{,*/}*.coffee'
          '<%= yeoman.test %>/{,*/}*.coffee'
        ]
        tasks: [
          'coffeelint:test'
          'coffeelint:lib'
          'jasmine_node'
        ]

  require('load-grunt-tasks')(grunt)

  grunt.registerTask('unit-watch', ['watch:unit-watch'])

  grunt.registerTask('test', ['jasmine_node'])

  grunt.registerTask('default', ['coffeelint', 'jasmine_node'])

