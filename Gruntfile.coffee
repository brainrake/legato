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
      extensions: 'coffee'
      jUnit:
        report: false
        savePath: "./build/reports/jasmine/"
        useDotNotation: true
        consolidate: true

    coffee:
      options:
        sourceMap: true
        sourceRoot: ''
      dist:
        files: [
          expand: true
          cwd: '<%= yeoman.app %>'
          src: '{,*/}*.coffee'
          dest: '<%= yeoman.app %>'
          ext: '.js'
        ]
      test:
        files: [
          expand: true
          cwd: '<%= yeoman.test %>'
          src: '{,*/}*.coffee'
          dest: '<%= yeoman.test %>'
          ext: '.js'
        ]

    coffeelint:
      options: coffeelint
      gruntfile:
        files:
          src: ['Gruntfile.coffee']
      dist:
        files:
          src: ['<%= yeoman.app %>/{,*/}*.coffee']
      test:
        files:
          src: ['<%= yeoman.test %>/{,*/}*.coffee']

    watch:
      dist:
        files: ['<%= yeoman.app %>/{,*/}*.coffee']
        tasks: [
          'coffeelint:dist'
          'coffee:dist'
        ]
      'unit-watch':
        files: [
          '<%= yeoman.app %>/{,*/}*.coffee'
          '<%= yeoman.test %>/{,*/}*.coffee'
        ]
        tasks: [
          'coffeelint:test'
          'coffeelint:dist'
          'coffee:test'
          'coffee:dist'
          'jasmine_node'
        ]

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-jasmine-node')

  grunt.registerTask('unit-watch', ['watch:unit-watch'])

  grunt.registerTask('default', ['coffeelint', 'jasmine_node'])

