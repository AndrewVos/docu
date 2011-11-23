docu
====

Executes code examples you may have in your readme files!

Example README.md.docu
----------------------

```
Hello!
======

:example:
1 + 1000
#=> 1001
:end:
```

This file will generate a README.md that looks like this:
```
Hello!
======

1 + 1000
#=> 1001
```

It will also fail when you try to generate the assertion does not match.

Usage
-----
gem install docu
docu README.md.docu
