Promise = require 'bluebird'


# Copied from https://github.com/tj/co
# (The MIT License)
# Copyright (c) 2014 TJ Holowaychuk &lt;tj@vision-media.ca&gt;

###*
# Execute the generator function or a generator
# and return a promise.
#
# @param {Function} fn
# @return {Promise}
# @api public
###
co = (gen) ->
  ctx = this
  if typeof gen == 'function'
    gen = gen.call(this)
  # we wrap everything in a promise to avoid promise chaining,
  # which leads to memory leak errors.
  # see https://github.com/tj/co/issues/180
  new Promise((resolve, reject) ->

    ###*
    # @param {Mixed} res
    # @return {Promise}
    # @api private
    ###
    onFulfilled = (res) ->
      ret = undefined
      try
        ret = gen.next(res)
      catch e
        return reject(e)
      next ret
      return

    ###*
    # @param {Error} err
    # @return {Promise}
    # @api private
    ###
    onRejected = (err) ->
      ret = undefined
      try
        ret = gen.throw(err)
      catch e
        return reject(e)
      next ret
      return

    ###*
    # Get the next value in the generator,
    # return a promise.
    #
    # @param {Object} ret
    # @return {Promise}
    # @api private
    ###
    next = (ret) ->
      if ret.done
        return resolve(ret.value)
      value = toPromise.call(ctx, ret.value)
      if value and isPromise(value)
        return value.then(onFulfilled, onRejected)
      onRejected new TypeError('You may only yield a function, promise, generator, array, or object, ' + 'but the following object was passed: "' + String(ret.value) + '"')

    onFulfilled()
    return
)

###*
# Convert a `yield`ed value into a promise.
#
# @param {Mixed} obj
# @return {Promise}
# @api private
###
toPromise = (obj) ->
  if !obj
    return obj
  if isPromise(obj)
    return obj
  if isGeneratorFunction(obj) or isGenerator(obj)
    return co.call(this, obj)
  if 'function' == typeof obj
    return thunkToPromise.call(this, obj)
  if Array.isArray(obj)
    return arrayToPromise.call(this, obj)
  if isObject(obj)
    return objectToPromise.call(this, obj)
  obj

###*
# Convert a thunk to a promise.
#
# @param {Function}
# @return {Promise}
# @api private
###
thunkToPromise = (fn) ->
  ctx = this
  new Promise((resolve, reject) ->
    fn.call ctx, (err, res) ->
      if err
        return reject(err)
      if arguments.length > 2
        res = Array::slice.call(arguments, 1)
      resolve res
      return
    return
)

###*
# Convert an array of "yieldables" to a promise.
# Uses `Promise.all()` internally.
#
# @param {Array} obj
# @return {Promise}
# @api private
###
arrayToPromise = (obj) ->
  Promise.all obj.map(toPromise, this)

###*
# Convert an object of "yieldables" to a promise.
# Uses `Promise.all()` internally.
#
# @param {Object} obj
# @return {Promise}
# @api private
###
objectToPromise = (obj) ->
  results = new (obj.constructor)
  keys = Object.keys(obj)
  promises = []

  defer = (promise, key) ->
    # predefine the key in the result
    results[key] = undefined
    promises.push promise.then((res) ->
      results[key] = res
      return
    )
    return

  i = 0
  while i < keys.length
    key = keys[i]
    promise = toPromise.call(this, obj[key])
    if promise and isPromise(promise)
      defer promise, key
    else
      results[key] = obj[key]
    i++
  Promise.all(promises).then ->
    results

###*
# Check if `obj` is a promise.
#
# @param {Object} obj
# @return {Boolean}
# @api private
###
isPromise = (obj) ->
  'function' == typeof obj?.then

###*
# Check if `obj` is a generator.
#
# @param {Mixed} obj
# @return {Boolean}
# @api private
###
isGenerator = (obj) ->
  'function' == typeof obj?.next and 'function' == typeof obj?.throw

###*
# Check if `obj` is a generator function.
#
# @param {Mixed} obj
# @return {Boolean}
# @api private
###
isGeneratorFunction = (obj) ->
  constructor = obj.constructor
  if !constructor
    return false
  if 'GeneratorFunction' == constructor.name or 'GeneratorFunction' == constructor.displayName
    return true
  isGenerator constructor.prototype

###*
# Check for plain object.
#
# @param {Mixed} val
# @return {Boolean}
# @api private
###
isObject = (val) ->
  Object == val.constructor


module.exports =
  Promise: Promise
  co: co
  isPromise: isPromise
  isGenerator: isGenerator
