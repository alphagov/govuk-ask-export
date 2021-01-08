require "google/cloud/dlp/v2"

module AskExport
  module Transformers
    class Deidentify
      CONFIG_PATH = File.expand_path("../../../config/deidentification.yml", __dir__)
      EXCLUDED_WORDS = YAML.safe_load(File.read(CONFIG_PATH))["excluded_words"].freeze

      INFO_TYPES = %w[
        DATE_OF_BIRTH
        EMAIL_ADDRESS
        PASSPORT
        PERSON_NAME
        PHONE_NUMBER
        STREET_ADDRESS
        UK_NATIONAL_INSURANCE_NUMBER
        UK_NATIONAL_HEALTH_SERVICE_NUMBER
      ].freeze

      INSPECTION_CONFIG = {
        # The types of information to match
        info_types: INFO_TYPES.map { |type| { name: type } },

        # Only return results above a likelihood threshold (0 for all)
        min_likelihood: :POSSIBLE,

        # Limit the number of findings (0 for no limit)
        limits: { max_findings_per_request: 0 },

        # Whether to include the matching string in the response
        include_quote: true,

        rule_set: [{
          info_types: [
            { name: "PERSON_NAME" },
            { name: "EMAIL_ADDRESS" },
            { name: "DATE_OF_BIRTH" },
            { name: "STREET_ADDRESS" },
          ],
          rules: [
            {
              exclusion_rule: {
                dictionary: {
                  word_list: {
                    words: EXCLUDED_WORDS,
                  },
                },
                matching_type: :MATCHING_TYPE_PARTIAL_MATCH,
              },
            },
            {
              exclusion_rule: {
                regex: {
                  pattern: ".+\\.gov\\.uk|10\\sDowning\\sSt.*|Boris\\sJohnson.*",
                },
                matching_type: :MATCHING_TYPE_FULL_MATCH,
              },
            },
          ],
        }],
      }.freeze

      DEIDENTIFY_CONFIG = {
        info_type_transformations: {
          # The transformations applied to each type of information found
          transformations: INFO_TYPES.map do |info_type|
            {
              # Which info types to apply the transformation to
              info_types: [{ name: info_type }],

              # The type of transformation to apply
              primitive_transformation: {

                # Replace the matched information with the name of information type
                replace_config: {
                  new_value: { string_value: info_type },
                },
              },
            }
          end,
        },
      }.freeze

      def initialize
        @parent = "projects/#{ENV['GOOGLE_CLOUD_PROJECT']}/locations/global"
        @dlp = Google::Cloud::Dlp::V2::DlpService::Client.new
      end

      def bulk_transform(values)
        # Split values in to groups of 500 as maximum per request
        values.each_slice(500).flat_map do |values_slice|
          # Create request with multiple values prevent doing individual
          # requests per value
          response = @dlp.deidentify_content(
            parent: @parent,
            deidentify_config: DEIDENTIFY_CONFIG,
            inspect_config: INSPECTION_CONFIG,
            item: { table: {
              headers: [{ name: "text" }],
              rows: values_slice.map { |text| { values: [{ string_value: text }] } },
            } },
          )

          # Retrieve values from response. This assumes the order of values in
          # the array in the request is the same as the response
          response.item.table.rows.map { |row| row.values[0].string_value }
        end
      end
    end
  end
end
