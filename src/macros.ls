;; List of built in macros for LispyScript. This file is included by
;; default by the LispyScript compiler.

(macro undefined? (obj)
  (= (typeof ~obj) "undefined"))

(macro null? (obj)
  (= ~obj null))

(macro true? (obj)
  (= true ~obj))

(macro false? (obj)
  (= false ~obj))

(macro boolean? (obj)
  (= (typeof ~obj) "boolean"))

(macro zero? (obj)
  (= 0 ~obj))

(macro number? (obj)
  (= (Object.prototype.toString.call ~obj) "[object Number]"))

(macro string? (obj)
  (= (Object.prototype.toString.call ~obj) "[object String]"))

(macro array? (obj)
  (= (Object.prototype.toString.call ~obj) "[object Array]"))

(macro object? (obj)
  ((function (obj)
    (= obj (Object obj))) ~obj))

(macro function? (obj)
  (= (Object.prototype.toString.call ~obj) "[object Function]"))

(macro do (rest...)
  ((function () ~rest...)))

(macro when (cond rest...)
  (if ~cond (do ~rest...)))

(macro unless (cond rest...)
  (when (! ~cond) (do ~rest...)))

(macro cond (first second rest...)
  (if ~first ~second (cond ~rest...)))

(macro array (rest...)
  ((function ()
    (Array.prototype.slice.call arguments)) ~rest...))

(macro object (rest...)
  ((function ()
    (var _r {})
    (javascript "for(var i=0,l=arguments.length;i<l;i+=2){_r[arguments[i]]=arguments[i+1];}")
    _r) ~rest...))

(macro each (obj fn rest...)
  ((function (o f s)
    (javascript "if(o.forEach){o.forEach(f,s);}else{for(var i=0,l=o.length;i<l;++i)f.call(s||o,o[i],i,o);}")
    undefined) ~obj ~fn ~rest...))
 
(macro eachKey (obj fn rest...)
  ((function (o f s)
    (javascript "var _k;if(Object.keys){_k=Object.keys(o);}else{_k=[];for(var i in o)_k.push(i);}")
    (each _k
      (function (elem)
        (f.call s (get elem o) elem o)))) ~obj ~fn ~rest...))

(macro reduce (arr fn rest...)
  ((function (arr f init)
    (var noInit (< arguments.length 3))
    (each arr
      (function (val i list)
        (if (&& (= i 0) noInit)
          (set init val)
          (set init (f init val i list)))))
    init) ~arr ~fn ~rest...))

(macro map (arr fn rest...)
  ((function (arr f scope)
    (var _r [])
    (each arr
      (function (val i list)
        (_r.push (f.call scope val i list))))
    _r) ~arr ~fn ~rest...))

(macro filter (rest...)
  (Array.prototype.filter.call ~rest...))

(macro some (rest...)
  (Array.prototype.some.call ~rest...))

(macro every (rest...)
  (Array.prototype.every.call ~rest...))

(macro template (name args rest...)
  (var ~name
    (function ~args
      (str ~rest...))))

(macro template-repeat (arg rest...)
  (reduce ~arg
    (function (___memo elem index)
      (+ ___memo (str ~rest...))) ""))

(macro template-repeat-key (obj rest...)
  (do
    (var ___ret "")
    (eachKey ~obj
      (function (value key)
        (set ___ret (+ ___ret (str ~rest...)))))
    ___ret))

;; Tail call optimised loop recur construct
;; Takes a set of args, initial values, and body
;; eg. (loop (arg1 arg2 arg3) (init1 init2 init3)
;;       ....
;;       (recur val1 val2 val3))
;; The body MUST evaluate to a NON undefined value to break from the loop.
;; null, 0 and other falsy values are ok to break from the loop.
(macro loop (args vals rest...)
  ((function ()
    (var recur null)
    (var ___result !undefined)
    (var ___nextArgs null)
    (var ___f (function ~args ~rest...))
    (set recur
      (function ()
        (set ___nextArgs arguments)
        (if (= ___result undefined)
          undefined
          (do
            (set ___result undefined)
            (javascript "while(___result===undefined) ___result=___f.apply(this,___nextArgs);")
            ___result))))
    (recur ~@vals))))

(macro sequence (name args init rest...)
  (var ~name
    (function ~args
      ((function ()
        ~@init
        (var next null)
        (var ___curr 0)
        (var ___actions (new Array ~rest...))
        (set next
          (function ()
            (var ne (get ___curr++ ___actions))
            (if ne
              ne
              (throw "Call to (next) beyond sequence."))))
        ((next)))))))

(macro assert (cond message)
  (if (true? ~cond)
    (+ "Passed - " ~message)
    (+ "Failed - " ~message)))

(macro testGroup (name rest...)
  (var ~name 
    (function ()
      (array ~rest...))))

(macro testRunner (groupname desc)
  ((function (groupname desc)
    (var start (new Date))
    (var tests (groupname))
    (var passed 0)
    (var failed 0)
    (each tests
      (function (elem)
        (if (elem.match /^Passed/)
          ++passed
          ++failed)))
    (str 
      (str "\n" desc "\n" start "\n\n")
      (template-repeat tests elem "\n")
      "\nTotal tests " tests.length 
      "\nPassed " passed 
      "\nFailed " failed 
      "\nDuration " (- (new Date) start) "ms\n")) ~groupname ~desc))




