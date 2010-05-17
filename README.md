Name
====

Task.Joose.NodeJS - Joose, packaged with NodeJS flavour.


SYNOPSIS
========

        require('Task/Joose/NodeJS')
        
        Class('Animal', {
            ...
        })

        
        Role('Winged', {
            has : {
                leftWing    : { is : 'rw' },
                rightWing   : { is : 'rw' }
            },
            
            methods : {
                
                flight : function () {
                    this.leftWing.flutter()
                    this.rightWing.flutter()
                },
                
                land : function () {
                    this.leftWing.hold()
                    this.rightWing.hold()
                }
            }
        })



        Class('Bird', {
            isa : 'Animal',
        
            does : 'Winged'
        })


        Class('Gryphon', {
            isa : 'Lion',
            
            does : 'Winged'
        })
        


DESCRIPTION
===========

`Task.Joose.NodeJS` is a distribution, containing Joose core bundled along with several essential extensions. Below is the composition:

> Joose                             [3.008](http://openjsan.org/doc/s/sa/samuraijack/Joose/3.008/lib/Joose.html)

>> Joose core, provides definitions for `Class/Role/Module` helpers

> JooseX.Attribute                  [0.02](http://openjsan.org/doc/s/sa/samuraijack/JooseX/Attribute/0.02/lib/JooseX/Attribute.html) 

>> Additional features for attributes

> JooseX.Namespace.Depended         [0.02](http://openjsan.org/doc/s/sa/samuraijack/JooseX/Namespace/Depended/0.02/lib/JooseX/Namespace/Depended.html)

>> Dependencies handling extension

> JooseX.CPS                        [0.02](http://openjsan.org/doc/s/sa/samuraijack/JooseX/CPS/0.02/lib/JooseX/CPS.html)

>> Trait, allowing to add the asynchronous (aka non-blocking) methods to your classes


Approach to modules 
===================

Joose was initially created to run in browser environment. Browser platform is less tolerant to synchronous resource loading than SSJS, as in older browsers it blocks the UI.
Thus, Joose wasn't able to adapt the CommonJS modules system (which is synchronous) and behave differently. However, when using Joose on server-side, you can freely mix the
Joose and CommonJS modules. 

Below is the quick introductory to Joose modules. Please refer to [Joose manual](http://openjsan.org/go/?l=Joose.Manual) for details. 


Basic Joose module
------------------

The module in Joose is just a special kind of class, which is declared with `Module` helper. The 1st argument to helper is the name of the module and the 2nd - a module's "body".
"Body" is  a function, which will be called with the module namespace as the single argument and in the same scope:  

        Module('Some.Module', function (m) {
            
            // this == m
            // this == Some.Module
            
            this.exportedFunction1 = function () { ... }
            this.exportedFunction2 = function () { ... }
        })
        
        Some.Module.exportedFunction1()
        Some.Module.exportedFunction2()

The module doesn't export anything. Instead, the module namespace (`Some.Module`) is exported to the calling scope. If you need to export some function, then define it
as the property of the module's namespace (when defining Classes you may prefer to use [static methods](http://openjsan.org/go/?l=Joose.Manual.Static)) 


Joose module with dependencies
------------------------------

If the module depends on other modules, the dependencies should be listed with `use` builder:

        Module('Some.Another.Module', {
            
            VERSION : 0.01,
        
            use : {
                'Some.Module'           : 0.01,
                'Yet.Another.Module'    : 0.02 
            },
        
        body : function (m) {
            
            // this == m
            // this == Some.Another.Module
            
            // setup aliases for methods being "imported"
            var exportedFunction1  = Some.Module.exportedFunction1
            var exportedFunction2  = Some.Module.exportedFunction2
        }})
    
Before running the "body" all dependencies will be asynchronously pre-loaded (only once). This code will work unmodified in both browser and server-side enviroments.

This functionality is provided by the [JooseX.Namespace.Depended](http://openjsan.org/go/?l=JooseX.Namespace.Depended) extension, please refer to its documentation for details 
(like how the files should be laid out in filesystem).


USAGE
=====

        require('Task/Joose/NodeJS')


This will export `Class/Role/Module` as standard CommonJS module. Also, it will *create the same helpers in the global scope*. 


Scenario 1. Using Joose in CommonJS modules
-------------------------------------------

In this scenario you'll probably want to create anonymous classes (just omit the name):

        var Class       = require('Task/Joose/NodeJS').Class
        
        var someFunc    = require('some/module').someFunc
    
    
        exports.Circle = Class({
            has : {
                radius : {
                    is      : 'rw',
                    init    : 10
                }
            },
            
            methods : {
                getSquare : function () {
                    ...
                }
            }
        })


Scenario 2. Using CommonJS modules in Joose - basic
---------------------------------------------------

In this scenario we first declare the module (to get the "body" function with own scope) , and then "promote" it to class. Note, how we use the leading dot in the name of class.
Without it, the created class would've been put in the module's namespace, like: `Graphic.Circle.Graphic.Circle`

        Module('Graphic.Circle', function (module) {
            
            var puts        = require('sys').puts
            var someFunc    = require('some/module').someFunc
        
        
            // promotes module to class, leading dot means place it in global namespace
            Class('.Graphic.Circle', {
            
                has : {
                    radius : {
                        is      : 'rw',
                        init    : 10
                    }
                },
        
                methods : {
                    draw : function () {
                        puts("using imported function")
                        
                        someFunc(this)
                    }
                }
            })
        })
    


Scenario 3. Using CommonJS modules in Joose - with dependencies
---------------------------------------------------------------

In this scenario we declare additional dependencies for out Joose class. We can specify the dependencies either with `use` - they'll be loaded via Joose
modules system or with `require` - they'll be handled by standard `require`.


        Module('Graphic.Circle', {
          
            require : [ './some/commonjs/module1.js', './some/commonjs/module2.js' ],
        
            use : {
                'Some.Joose.Role'       : 0.01,
                'Some.Another.Class'    : 0.02
            },
        
        body : function (module) {
            
            // will be already loaded, so the call will be synchronous 
            var someFunc = require('./some/commonjs/module1.js').someFunc
        
        
            Class('.Graphic.Circle', {
                does : Some.Joose.Role,
                
                has : {
                    radius : {
                        is      : 'rw',
                        init    : 10
                    }
                },
        
                methods : {
                    draw : function () {
                        someFunc("using imported function")
                    }
                }
            })
        }})


Scenario 4. Using Joose classes, depending on Joose classes only
---------------------------------------------------------------

When using Joose classes, depending on Joose classes only, we can declare the Class from start, without wrapping Module.

        Class('Graphic.Circle', {
        
            VERSION : 0.01,
            
            does : {
                'Some.Joose.Role' : 0.01,
            },
          
            use : {
                'Some.Another.Class' : 0.02
            },
        
                
            has : {
                radius : {
                    is      : 'rw',
                    init    : 10
                }
            },
        
            methods : {
                draw : function () {
                    Some.Another.Class.someFunc("using imported function as class method")
                }
            },
            
            
            // static part of the class
            my : {
                methods : {
                    exportedFunction1 : function () { ... },
                    exportedFunction2 : function () { ... }
                }
            }
        })




GETTING HELP
============

This extension is supported via github issues tracker: <http://github.com/SamuraiJack/Task-Joose-NodeJS/issues>
For general Joose questions you can also visit #joose on irc.freenode.org or the forum at: <http://joose.it/forum>
 


SEE ALSO
========

Web page of this module: <http://github.com/SamuraiJack/Task-Joose-NodeJS/>

General documentation for Joose: <http://openjsan.org/go/?l=Joose>


BUGS
====

All complex software has bugs lurking in it, and this module is no exception.

Please report any bugs through the web interface at <http://github.com/SamuraiJack/Task-Joose-NodeJS/issues>



AUTHORS
=======

Nickolay Platonov <nplatonov@cpan.org>



COPYRIGHT AND LICENSE
=====================

Copyright (c) 2009, Nickolay Platonov

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the name of Nickolay Platonov nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
