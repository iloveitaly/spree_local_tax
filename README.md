SpreeLocalTax
=============

Local tax calculation (i.e. state based for US tax requirements) for Spree Commerce.
Will include the ability to include/exclude shipping, promotions, etc from tax calculation. 

Design goals:  

* Inherit from DefaultTax
* Taxable amount is calculated as: item total + shipping - promotional adjustments.
  This can be [easily adjusted](https://github.com/iloveitaly/spree_local_tax/blob/master/app/models/spree/calculator/local_tax.rb#L33).
* Allow for matching by city + state or zip code
* No modifications to existing tax calculation logic: all logic contained within new calculator
* Downloadable reports via [spree_advanced_reporting](http://github.com/iloveitaly/spree_advanced_reporting): tax by city, tax by order
* Swappable tax calculation backends. Right now only SQL is supported,
  possibly support [avalara](http://www.avalara.com/products/sdk), [taxcloud](https://taxcloud.net/default.aspx), or [TDS](http://www.taxdatasystems.com) in the future

Example
=======

After installation, a new tax calculator will be available under Configuration --> Tax Rates.

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
