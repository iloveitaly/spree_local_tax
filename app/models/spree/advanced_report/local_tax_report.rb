class Spree::AdvancedReport::LocalTaxReport < Spree::AdvancedReport
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::UrlHelper

  def name
    "Local tax report"
  end

  def description
    "Local tax report by city"
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
        state
        county
        total_tax
        taxable_amount
        tax_total
        state_tax
        county_tax_amount
        other
      ]
    })

    # TODO this should be rearranged to handle states + counties, not just counties
    city_locations = {}
    state_locations = {}

    orders.each do |order|
      next if order.adjustments.eligible.tax.blank?

      # TODO handle multiple tax adjustments

      order.adjustments.eligible.tax.each do |tax_rate|
        calculator = tax_rate.originator.calculator

        if calculator.class == Spree::Calculator::LocalTax
          tax_address = Spree::Config[:tax_using_ship_address] ? order.ship_address : order.bill_address
          local_tax = calculator.find_local_tax(tax_address)
          taxable_amount = calculator.taxable_amount(order)
          tax_total = calculator.compute(order)

          if local_tax.present?
            city_locations[local_tax.state.abbr] ||= {}
            city_locations[local_tax.state.abbr][local_tax.city] ||= {
              "state" => local_tax.state.abbr,
              "county" => local_tax.city,
              "total_tax" => number_to_percentage(local_tax.rate * 100.0, precision: 2, strip_insignificant_zeros: true),
              "tax_total" => 0.0,
              "taxable_amount" => 0,
              "state_tax" => 0,
              "county_tax_amount" => 0,
              "other" => 0
            }

            state_tax = local_tax.state.tax

            # TODO messy, there has to be a more ruby way to handle this
            city_locations[local_tax.state.abbr][local_tax.city]["tax_total"] += tax_total
            city_locations[local_tax.state.abbr][local_tax.city]["taxable_amount"] += taxable_amount
            city_locations[local_tax.state.abbr][local_tax.city]["state_tax"] += state_tax * taxable_amount
            city_locations[local_tax.state.abbr][local_tax.city]["county_tax_amount"] += local_tax.local * taxable_amount
            city_locations[local_tax.state.abbr][local_tax.city]["other"] += local_tax.other * taxable_amount
          else
            # if not local tax object is available, fall back to state tax calculation
            # NOTE this will break for international orders (Order#state_text should be used instead)

            state_text = tax_address.state.abbr

            Rails.logger.error "Missing zipcode from #{state_text} for local tax: #{tax_address.zipcode}"

            state_locations[state_text] ||= {
              "state" => tax_address.state.abbr,
              "county" => "",
              "total_tax" => number_to_percentage(calculator.calculable.amount * 100.0, precision: 2, strip_insignificant_zeros: true),
              "tax_total" => 0.0,
              "taxable_amount" => 0,
              "state_tax" => 0,
              "county_tax_amount" => 0,
              "other" => 0
            }

            state_locations[state_text]["tax_total"] += tax_total
            state_locations[state_text]["state_tax"] += tax_total # its all state tax
            state_locations[state_text]["taxable_amount"] += taxable_amount
          end
        end
      end
    end

    (city_locations.values.map(&:values).flatten + state_locations.values).each do |data|
      # format numbers
      data["taxable_amount"] = number_to_currency(data["taxable_amount"])
      data["tax_total"] = number_to_currency(data["tax_total"])
      data["other"] = number_to_currency(data["other"])
      data["state_tax"] = number_to_currency(data["state_tax"])
      data["county_tax_amount"] = number_to_currency(data["county_tax_amount"])

      ruportdata << data
    end

    # sort by quantity sold
    # ruportdata.sort_rows_by! ["county"]

    # spaces don't seem to work in 
    ruportdata.rename_column("county", "County")
    ruportdata.rename_column("total_tax", "Total Tax")
    ruportdata.rename_column("taxable_amount", "Taxable Amount")
    ruportdata.rename_column("tax_total", "Tax Total")
    ruportdata.rename_column("state_tax", "State Tax")
    ruportdata.rename_column("county_tax_amount", "County Tax")
    ruportdata.rename_column("other", "Stadium Tax & Other")
  end
end if defined?(Spree::AdvancedReport)