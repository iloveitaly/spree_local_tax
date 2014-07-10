SpreeLocalTax
=============

Local tax calculation (i.e. state based for US taxation) for Spree Commerce.

Design goals:  

* Inherit from DefaultTax
* Taxable amount is calculated as: item total + shipping - promotional adjustments.
  This can be [easily adjusted](https://github.com/iloveitaly/spree_local_tax/blob/master/app/models/spree/calculator/local_tax.rb#L33).
* Allow for matching by city + state or zip code
* No modifications to existing tax calculation logic: all logic contained within new calculator
* Downloadable reports via [spree_advanced_reporting](http://github.com/iloveitaly/spree_advanced_reporting): tax by city, tax by order. These reports default to report by order shipped date and include only fully shipped orders. Tax reports respect `Spree::Config[:tax_using_ship_address]`
* Swappable tax calculation backends. Right now only SQL is supported,
  possibly support [avalara](http://www.avalara.com/products/sdk), [taxcloud](https://taxcloud.net/default.aspx), [SpeedTax](http://www.speedtax.com/), or [TDS](http://www.taxdatasystems.com) in the future

Installation
=======

1. Run `bundle exec rails g spree_local_tax:install`. This adds the DB migration for SQL based local tax calculation
2. After installation, a new tax calculator will be available under Configuration --> Tax Rates.
3. You have to set the state tax rate manually `Spree::State.find_by_abbr('PA').update_attribute(:tax, 0.06)`

TODO
====

* Support for taxcloud or other tax API (I believe there are other extensions out there for 3rd party tax calculation now; don't need to do this ATM)
* The code that monkeypatches the `Spree::ReportsController` is pretty messy right now. Unfortunately there is not an easy way to clean this up without improvements to the class itself. There is an [issue open](https://github.com/spree/spree/issues/1863) describing this problem.

Copyright (c) 2012 Michael Bianco (@iloveitaly), released under the New BSD License
