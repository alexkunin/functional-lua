return {
    type            = {
        Either = require 'fl.type.Either',
        IO     = require 'fl.type.IO',
        Maybe  = require 'fl.type.Maybe',
        Task   = require 'fl.type.Task',
    },
    combinator      = require 'fl.combinator',
    compose         = require 'fl.compose',
    curry_n         = require 'fl.curry_n',
    defType         = require 'fl.defType',
    either          = require 'fl.either',
    execute         = require 'fl.execute',
    left            = require 'fl.left',
    map             = require 'fl.map',
    maybe           = require 'fl.maybe',
    performUnsafeIO = require 'fl.performUnsafeIO',
    reject          = require 'fl.reject',
}
