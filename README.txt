diy

* http://rubyforge.org/projects/atomicobjectrb/
* http://atomicobjectrb.rubyforge.org/diy

== DESCRIPTION:

DIY (Dependency Injection in Yaml) is a simple dependency injection library
which focuses on declarative composition of objects through constructor injection.

Currently, all objects that get components put into them must have a
constructor that gets a hash with symbols as keys.
Best used with constructor.rb

Auto-naming and auto-library support is done.

== FEATURES/PROBLEMS:
  
* Constructor-based dependency injection container using YAML input.

== SYNOPSIS:

=== A Simple Context

The context is a hash specified in in a yaml file.  Each top-level key identifies
an object.  When the context is created and queried for an object, by default, 
the context will require a file with the same name:

  require 'foo'

Next, by default, it will call new on a class from the camel-cased name of the key:

  Foo.new

foo.rb:
  class Foo; end

context.yml:
  ---
  foo:
  bar:

  c = DIY::Context.from_file('context.yml')
  c[:foo]  => <Foo:0x81eb0> 

=== Specifying Ruby File to Require

If the file the class resides in isn't named after they key:

fun_stuff.rb:
  class Foo; end
 
context.yml:
   ---
   foo:
     lib: fun_stuff
   bar:

=== Constructor Arguments

DIY allows specification of constructor arguments as hash key-value pairs
using the <tt>compose</tt> directive.  

foo.rb:
  class Foo
    def initialize(args)
      @bar = args[:bar]
      @other = args[:other]
    end
  end
 
context.yml:
  ---
  foo:
    compose: bar, other
  bar:
  other:

=== Using DIY with constructor.rb:

foo.rb:
  class Foo
    constructor :bar, :other
  end

If the constructor argument names don't match up with the object keys
in the context, they can be mapped explicitly.

 foo.rb:
   class Foo
     constructor :bar, :other
   end

context.yml:
  ---
  foo:
    bar: my_bar
    other: the_other_one
  my_bar:
  the_other_one:

=== Non-singleton objects
 
Non-singletons will be re-instantiated each time they are needed.

context.yml:
  ---
  foo:
    singleton: false

  bar:

  engine:
    compose: foo, bar

== REQUIREMENTS:

* rubygems
* works best with constructor

== INSTALL:

* gem install diy

== LICENSE:

(The MIT License)

Copyright (c) 2007 Atomic Object

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
