SpreeLocalTax
=============

Local tax calculation (i.e. state based for US tax requirements) for Spree Commerce. Will include the ability to include/exclude shipping, promotions, etc from tax calculation. 

Design goals:  

* Inherit from DefaultTax
* Allow for matching by city + state or zip
* No modifications to existing tax calculation logic: all logic contained within new calculator
* Downloadable reports
* Swappable tax calculation backends

Example
=======

A new tax calculator will be available under Configuration --> Tax Rates

TODO
====

* Support for taxcloud or other tax API
* Right now the extension requires that you have `spree_advanced_reporting` installed, this requirement should be removed.

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

    $ bundle
    $ bundle exec rake test_app
    $ bundle exec rspec spec

Copyright (c) 2012 Michael Bianco (@iloveitaly), released under the New BSD License
