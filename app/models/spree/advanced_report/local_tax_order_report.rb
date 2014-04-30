class Spree::AdvancedReport::LocalTaxOrderReport < Spree::AdvancedReport
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::UrlHelper

  def name
    "Local Tax by Order"
  end

  def description
    "Local Tax Report by Order"
  end

  def initialize(params)
    params[:advanced_reporting] ||= {}

    # default to report on shipped orders only
    params[:advanced_reporting][:order_type] = 'shipped' if params[:advanced_reporting][:order_type].blank?

    # default to exclude orders that are not fully shipped
    params[:advanced_reporting][:shipment] = 'fully_shipped' if params[:advanced_reporting][:shipment].blank?

    # use taxable address as state filter
    params[:advanced_reporting][:state_based_on_taxable_address] = '1' if params[:advanced_reporting][:state_based_on_taxable_address].blank?

    super(params)

    # group is a subclass of table
    # TODO use date slash format instead of dashes
    self.ruportdata = Ruport::Data::Group.new({
      :name => "#{self.name} #{self.date_range}",
      :column_names => %w[
        order
        firstname
        lastname
        state
        county
        total_tax
        taxable_amount
        shipping_total
        tax_total
        state_tax
        county_tax_amount
        other
      ]
    })

    # NOTE this designed around taxation for US based locales
    # getting this to work for international taxation reporting would take some work

    orders.each do |order|
      next if order.adjustments.eligible.tax.blank?

      tax_adjustment = order.adjustments.eligible.tax.first
      calculator = tax_adjustment.originator.calculator
      tax_address = Spree::Config[:tax_using_ship_address] ? order.ship_address : order.bill_address

      tax_data = {
        "order" => link_to(order.number, Spree::Core::Engine.routes.url_helpers.admin_order_path(order), target: '_blank'),
        "firstname" => tax_address.firstname,
        "lastname" => tax_address.lastname,
        "total_tax" => 0,
        "taxable_amount" => 0,
        "shipping_total" => number_to_currency(order.adjustments.shipping.sum(&:amount)),
        "tax_total" => number_to_currency(calculator.compute(order)),
        "state_tax" => number_to_currency(0),
        "county_tax_amount" => number_to_currency(0),
        "other" => number_to_currency(0),
      }

      if calculator.class == Spree::Calculator::LocalTax
        local_tax = calculator.find_local_tax(tax_address)
        taxable_amount = calculator.taxable_amount(order)

        tax_data.merge!({
          "taxable_amount" => number_to_currency(taxable_amount),
        })

        if local_tax
          tax_data.merge!({
            "state" => local_tax.state.abbr,
            "county" => local_tax.city,
            "total_tax" => number_to_percentage(local_tax.rate * 100.0, precision: 2, strip_insignificant_zeros: true),
            "tax_total" => number_to_currency(calculator.compute(order)),
            "state_tax" => number_to_currency(local_tax.state.tax * taxable_amount),
            "county_tax_amount" => number_to_currency(local_tax.local * taxable_amount),
            "other" => number_to_currency(local_tax.other * taxable_amount),
          })
        else
          # no specific tax available, fallback to state based taxes
          tax_data.merge!({
            "state" => tax_address.state.abbr,
            "state_tax" => number_to_currency(calculator.compute(order)),
            "total_tax" => number_to_percentage(calculator.calculable.amount * 100.0, precision: 2, strip_insignificant_zeros: true)
          })
        end
      else
        # TODO calculate tax based on defaulttax calculator
      end

      ruportdata << tax_data
    end

    # rename the columns (ruport doesn't allow spaces in names)
    ruportdata.rename_column("order", "Order")
    ruportdata.rename_column("county", "County")
    ruportdata.rename_column("state", "State")
    ruportdata.rename_column("shipping_total", "Shipping Total")
    ruportdata.rename_column("county", "County")
    ruportdata.rename_column("firstname", "First Name")
    ruportdata.rename_column("lastname", "Last Name")
    ruportdata.rename_column("total_tax", "Total Tax")
    ruportdata.rename_column("taxable_amount", "Taxable Amount")
    ruportdata.rename_column("tax_total", "Tax Total")
    ruportdata.rename_column("state_tax", "State Tax")
    ruportdata.rename_column("county_tax_amount", "County Tax")
    ruportdata.rename_column("other", "Stadium Tax & Other")
  end
end if defined?(Spree::AdvancedReport)