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
    super(params)

    # group is a subclass of table
    # TODO use date slash format instead of dashes
    self.ruportdata = Ruport::Data::Group.new({
      :name => "#{self.name} #{self.date_range}",
      :column_names => %w[county total_tax taxable_amount tax_total state_tax county_tax_amount other]
    })

    # TODO this should be rearranged to handle states + counties, not just counties
    tax_locations = {}

    orders.each do |order|
      next if order.adjustments.eligible.tax.blank?

      # TODO handle multiple tax adjustments

      order.adjustments.eligible.tax.each do |tax_rate|
        calculator = tax_rate.originator.calculator

        if calculator.class == Spree::Calculator::LocalTax
          local_tax = calculator.find_local_tax(order.bill_address)

          if local_tax.present?
            tax_locations[local_tax.city] ||= {
              "county" => local_tax.city,
              "total_tax" => number_to_percentage(local_tax.rate * 100.0, precision: 2, strip_insignificant_zeros: true),
              "tax_total" => 0.0,
              "taxable_amount" => 0,
              "state_tax" => 0,
              "county_tax_amount" => 0,
              "other" => 0
            }

            taxable_amount = calculator.taxable_amount(order)
            state_tax = local_tax.state.tax

            tax_locations[local_tax.city]["tax_total"] += calculator.compute(order)
            tax_locations[local_tax.city]["taxable_amount"] += taxable_amount
            tax_locations[local_tax.city]["state_tax"] += state_tax * taxable_amount
            tax_locations[local_tax.city]["county_tax_amount"] += local_tax.local * taxable_amount
            tax_locations[local_tax.city]["other"] += local_tax.other * taxable_amount

            Rails.logger.info "DIFFERENCE #{calculator.compute(order)} : #{tax_rate.amount}"
          end
        end
      end
    end

    tax_locations.values.each do |data|
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
    ruportdata.rename_column("county_tax_amount", "County Tax Amount")
    ruportdata.rename_column("other", "Other")
  end
end