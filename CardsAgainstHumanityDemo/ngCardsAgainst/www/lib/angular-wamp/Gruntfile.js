/* global module */
module.exports = function (grunt) {
    'use strict';

    grunt.initConfig({
        pkg: grunt.file.readJSON('package.json'),
        meta: {
            banner: 'Angular WAMP v2'
        },

        // merge files from src/ into angular-wamp.js
        concat: {
            app: {
                //options: {banner: '<%= meta.banner %>'},
                src: [
                    //'src/autobahn.min.js',
                    'src/angular-wamp.js'
                ],
                dest: 'release/angular-wamp.js'
            }
        },

        // Run shell commands
        shell: {
            options: {
                stdout: true
            },
            protractor_install: {
                command: 'node ./node_modules/protractor/bin/webdriver-manager update'
            },
            npm_install: {
                command: 'npm install'
            },
            bower_install: {
                command: 'bower install'
            }
        },

        // Create local server
        connect: {
            testserver: {
                options: {
                    hostname: 'localhost',
                    port: 3030
                }
            }
        },

        // Add Angular Annotations
        ngAnnotate: {
            options: {
                preserveComments: 'none'
            },
            app: {
                files: {
                    'release/angular-wamp.js': ['release/angular-wamp.js']
                }
            }
        },

        // Minify JavaScript
        uglify: {
            options: {
                preserveComments: 'some'
            },
            app: {
                files: {
                    'release/angular-wamp.min.js': ['release/angular-wamp.js']
                }
            }
        },

        // Auto-run tasks on file changes
        watch: {
            scripts: {
                files: ['src/*.js', 'tests/unit/**/*.spec.js', 'tests/lib/**/*.js', 'tests/mocks/**/*.js'],
                tasks: ['test:unit', 'notify:watch'],
                options: {
                    interrupt: true,
                    atBegin: true
                }
            }
        },

        // Unit tests
        karma: {
            options: {
                configFile: 'tests/automatic_karma.conf.js'
            },
            manual: {
                configFile: 'tests/manual_karma.conf.js'
            },
            singlerun: {},
            watch: {
                autowatch: true,
                singleRun: false
            },
            saucelabs: {
                configFile: 'tests/sauce_karma.conf.js'
            }
        },

        // End to end (e2e) tests
        protractor: {
            options: {
                configFile: "tests/local_protractor.conf.js"
            },
            singlerun: {},
            saucelabs: {
                options: {
                    configFile: "tests/sauce_protractor.conf.js",
                    args: {
                        sauceUser: process.env.SAUCE_USERNAME,
                        sauceKey: process.env.SAUCE_ACCESS_KEY
                    }
                }
            }
        },

        // Desktop notificaitons
        notify: {
            watch: {
                options: {
                    title: 'Grunt Watch',
                    message: 'Build Finished'
                }
            }
        }
    });

    require('load-grunt-tasks')(grunt);

    // Installation
    grunt.registerTask('install', ['shell:protractor_install']);
    grunt.registerTask('update', ['shell:npm_install', 'shell:bower_install']);

    // Single run tests
    grunt.registerTask('test', ['test:unit', 'test:e2e']);
    grunt.registerTask('test:unit', ['karma:singlerun']);
    grunt.registerTask('test:e2e', ['connect:testserver', 'protractor:singlerun']);
    grunt.registerTask('test:manual', ['karma:manual']);

    // Travis CI testing
    grunt.registerTask('test:travis', ['build', 'test:unit']);

    // Sauce tasks
    grunt.registerTask('sauce:unit', ['karma:saucelabs']);
    grunt.registerTask('sauce:e2e', ['connect:testserver', 'protractor:saucelabs']);

    // Watch tests
    grunt.registerTask('test:watch', ['karma:watch']);
    grunt.registerTask('test:watch:unit', ['karma:watch']);

    // Build tasks
    grunt.registerTask('build', ['concat', 'ngAnnotate', 'uglify']);

    // Default task
    grunt.registerTask('default', ['build', 'test']);

    grunt.loadNpmTasks('grunt-ng-annotate');
};
