#!/bin/ruby
require 'io/console'
require 'fileutils'
require 'pathname'
require 'yaml'

require_relative 'SyntaxUtil'
require_relative 'ParserThing'

class ImprovedProgress
    DIGIT_NAMES = [
        "ZERO", "ONE", "TWO", "THREE", "FOUR", 
        "FIVE", "SIX", "SEVEN", "EIGHT", "NINE", 
    ]
    DIGIT_MODIFIERS = [
        {},
        {:suffix => "TY"},
        {:suffix => "HUNDRED"},
        {:suffix => " KILO AND "},
        {:suffix => "TY"},
        {:suffix => "HUNDRED"},
        {:suffix => " MEGA AND "},
        {:suffix => "TY"},
        {:suffix => "HUNDRED"},
        {:suffix => " GIGA AND "},
        {:suffix => "TY"},
        {:suffix => "HUNDRED"},
        {:suffix => " TERA AND "},
        {:suffix => "TY"},
        {:suffix => "HUNDRED"},
        {:suffix => " PETA AND "},
        {:suffix => "TY"},
        {:suffix => "HUNDRED"},
        {:suffix => " EXA AND "},
        {:suffix => "TY"},
        {:suffix => "HUNDRED"},
        {:suffix => " ZETTA AND "},
        {:suffix => "TY"},
        {:suffix => "HUNDRED"},
        {:suffix => " YOTTA AND "},
        {:suffix => "TY"},
        {:suffix => "HUNDRED"},
        {:suffix => " RONNA AND "},
        {:suffix => "TY"},
        {:suffix => "HUNDRED"},
        {:suffix => " QUETTA AND "},
        {:suffix => "TY"},
        {:suffix => "HUNDRED"},
        {:suffix => "▓"}
    ]
    REPLACEMENTS = [
        {
            /([^A-Za-z])ZERO((?:HUNDRED|TY|))([^A-Za-z])/ => '\1',
        },
        {
            /([^A-Za-z])ZERO((?:HUNDRED|TY|))([^A-Za-z])/ => '\1',
            /([^A-Za-z])ONETY([^A-Za-z])/ => '\1TEN\2',
            /([^A-Za-z])TWOTY([^A-Za-z])/ => '\1TWENTY\2',
            /([^A-Za-z])THREETY([^A-Za-z])/ => '\1THIRTY\2',
            /([^A-Za-z])FOURTY([^A-Za-z])/ => '\1FORTY\2',
            /([^A-Za-z])FIVETY([^A-Za-z])/ => '\1FIFTY\2',
            /([^A-Za-z])EIGHTTY([^A-Za-z])/ => '\1EIGHTY\2',
        },
        {
            /HUNDRED/ => ' HUNDRED',
            /TEN (ZERO|ONE|TWO|THREE|FOUR|FIVE|SIX|SEVEN|EIGHT|NINE)/ => '\1TEEN',
        },
        {
            /([^A-Za-z])ZEROTEEN([^A-Za-z])/ => '\1TEN\2',
            /([^A-Za-z])ONETEEN([^A-Za-z])/ => '\1ELEVEN\2',
            /([^A-Za-z])TWOTEEN([^A-Za-z])/ => '\1TWELVE\2',
            /([^A-Za-z])THREETEEN([^A-Za-z])/ => '\1THIRTEEN\2',
            /([^A-Za-z])FIVETEEN([^A-Za-z])/ => '\1FIFTEEN\2',
            /([^A-Za-z])EIGHTTEEN([^A-Za-z])/ => '\1EIGHTEEN\2',
            /([^A-Za-z])NINETEEN([^A-Za-z])/ => '\1NINTEEN\2',
        },
        {
            /AND  (KILO|MEGA|GIGA|TERA|PETA|EXA|ZETTA|YOTTA|RONNA|QUETTA)/ => 'AND ZERO \1'
        },
        {
            /ZERO HUNDRED/ => '\1'
        },
        {
            /  / => ' '
        }
    ]
    def self.num_to_words(
        num, 
        alterations = {
            :digit_names => ImprovedProgress::DIGIT_NAMES,
            :digit_modifiers => ImprovedProgress::DIGIT_MODIFIERS,
            :replacements => ImprovedProgress::REPLACEMENTS,
        }
    )
        digit_names = alterations[:digit_names]
        digit_modifiers = alterations[:digit_modifiers]
        replacements = if alterations.key?(:replacements)
            alterations[:replacements]
        else
            []
        end
        result = " "
        digit_pos = 0
        for digit in num.digits
            digit_modifier = digit_modifiers[digit_pos % digit_modifiers.size()]
            prefix = if digit_modifier.key?(:prefix)
                digit_modifier[:prefix]
            else
                ""
            end
            suffix = if digit_modifier.key?(:suffix)
                digit_modifier[:suffix]
            else
                ""
            end
            result = " #{prefix}#{digit_names[digit]}#{suffix}#{result}"
            digit_pos += 1
        end
        for replacement in replacements
            for replacement_key in replacement.keys
                result.gsub!(replacement_key, replacement[replacement_key])
            end
        end
        result = result.strip
        if result == ""
            result = digit_names[0]
        end
        return result.strip
    end

    class Counter
        def initialize(
            file_path, 
            number_alterations: nil, 
            sequence: "ABCDEFGHIJKLMNOPQRSTUVWXYZ", 
            selection_pool: :all, 
            mode: nil
        )
            <<-__PARAMS__
                sequence => String%{each char is unique}
                selection_pool => %Literal[:all, :first, :last]
                mode => %Literal[:json, :yaml, nil]
               __PARAMS__
            raise TypeError unless file_path.is_a? String
            @file_path = file_path
            @number_alterations = number_alterations
            @sequence = sequence
            @selection_pool = selection_pool
            @mode = mode
            if @mode == nil
                @mode = file_path.split("/")[-1].split(".")[-1].to_sym
            end
            if @number_alterations != nil
                goal = ImprovedProgress::num_to_words(0, number_alterations)
            else
                goal = ImprovedProgress::num_to_words(0)
            end

            @data = {
                :count => 0,
                :value => '',
                :goal => goal,
                :sequence => sequence,
            }
            for char in @data[:goal].chars
                if @data[:sequence].include?(char)
                    @data[:value] += @data[:sequence][0]
                else
                    @data[:value] += char
                end
            end


            if File.file?(file_path)
                file = File.open(@file_path, 'r')
                @data = ParserThing.parse_string(file.read())
                data__properize_types()
                file.close()
            else
                FileUtils::mkdir_p(Pathname.new(file_path).dirname)
            end
        end

        def data__properize_types()
            @data[:count] = @data[:count].to_i
        end

        def number_alterations__reset()
            @number_alterations = nil
        end

        def number_alterations(new_value = nil)
            result = @number_alterations
            if new_value != nil
                @number_alterations = new_value
            end
            return result
        end

        def sequence(new_value = nil)
            result = @sequence
            if new_value != nil
                @sequence = new_value
            end
            return result
        end
        
        def selection_pool(new_value = nil)
            result = @selection_pool
            raise TypeError unless [nil, :all, :first, :last].contains?(new_value)
            if new_value != nil
                @selection_pool = new_value
            end
            return result
        end

        def samefy_string_in_hash_sizes(the_hash, keys)
            keys.permutation(2).to_a.each { |shorter, longer|
                while the_hash[shorter].length < the_hash[longer].length
                    the_hash[shorter] += the_hash[longer][the_hash[shorter].length]
                end
            }
        end

        def increase()
            if @data[:value] == @data[:goal]
                @data[:count] += 1
                @data[:goal] = ImprovedProgress::num_to_words(@data[:count])
                @data[:value] = ""
                @data[:sequence] = @sequence
                value = @data[:goal]
                for char in value.chars
                    if @data[:sequence].include?(char)
                        @data[:value] += @data[:sequence][0]
                    else
                        @data[:value] += char
                    end
                end
            else
                valid_pos = []
                for pos in 0..@data[:value].length
                    if @data[:value][pos] != @data[:goal][pos]
                        valid_pos.push(pos)
                    end
                end
                pos = if @selection_pool == :first
                    valid_pos[0]
                elsif @selection_pool == :last
                    valid_pos[-1]
                else
                    valid_pos.sample()
                end

                samefy_string_in_hash_sizes(@data, [:value, :goal])

                if (
                    @data[:sequence].include?(@data[:value][pos])\
                and\
                    @data[:sequence].include?(@data[:goal][pos])\
                )
                    @data[:value][pos] = (
                        @data[:sequence][
                            (
                                @data[:sequence].index(@data[:value][pos]) + 1
                            ) % @data[:sequence].length
                        ]
                    )
                else
                    @data[:value][pos] = @data[:goal][pos]
                end
            end
        end
    
        def data(clone: true)
            <<-__PARAMS__
                clone => %Bool
               __PARAMS__
            if clone
                return @data.clone
            end
            return @data
        end

        
        def save()
            File.open(@file_path, 'w') do |file|
                if @mode == :yaml
                    file.write(@data.transform_keys(&:to_s).to_yaml)
                elsif @mode == :json
                    file.write(JSON.pretty_generate(@data))
                else
                    raise "Invalid @mode; excepted among [:yaml, :json]; got #{@mode}"
                end
            end
        end
    end
end

if __FILE__ == $0
    delay = 0.0
    delay_auto_pow = Rational(1, 3)
    file = "#{File.dirname(__FILE__)}/Data/progress.json"

    ARGV.each do |argv|
        [nil].each do |argvs|
            argvs = argv.split("=")

            if argv == '--yaml'
                file = "#{File.dirname(__FILE__)}/Data/progress.yaml"
            end
            if argv == '--json'
                file = "#{File.dirname(__FILE__)}/Data/progress.json"
            end
            if argvs[0] == '--delay'
                if argvs[1] == 'auto'
                    delay = :auto
                    if argvs.length > 2
                        delay_auto_pow = argvs[2].to_f
                    end
                else
                    delay = argvs[1].to_f
                end
            end
        end
    end
    counter = ImprovedProgress::Counter.new(file)
    if delay == :auto
        delay = counter.data[:count] ** delay_auto_pow
    end
    while true
        $stdout.clear_screen()
        print(
            "#{SyntaxUtil.syntax_string("time_utc", :variable)} = "\
            "#{SyntaxUtil.syntax_string(Time.now.utc.strftime('"%Y-%m-%dT%H:%M:%S"'), :string)}\n"\
            "#{SyntaxUtil.syntax_string("count", :variable)} = "\
            "#{SyntaxUtil.syntax_string(counter.data[:count], :int)}\n"\
            "#{SyntaxUtil.syntax_string("value", :variable)} = "\
            "#{SyntaxUtil.syntax_string("\"#{counter.data[:value]}\"", :string)}\n"\
            "#{SyntaxUtil.syntax_string("goal", :variable)} = "\
            "#{SyntaxUtil.syntax_string("\"#{counter.data[:goal]}\"", :string)}\n"\
            "#{SyntaxUtil.syntax_string("delay", :variable)} = "\
            "#{SyntaxUtil.syntax_string(delay, :float)}\n"\
        )
        
        counter.increase()
        counter.save()
        sleep(delay)
        delay_add = (1.0 / counter.data[:count])
        if delay_add > 2.5
            delay_add = 2.5
        end
        delay += delay_add * rand(1.0..1.1)
    end
end
