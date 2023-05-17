require 'json'
require 'yaml'

class ParserThing
    def self.parse_string(the_string)
        begin
            return YAML.safe_load(the_string).transform_keys(&:to_sym)
        rescue
            return JSON.parse(the_string).transform_keys(&:to_sym)
        end
    end
end
