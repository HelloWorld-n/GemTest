class SyntaxUtil

    def self.syntax_string(the_string, the_token)
        if the_token == :variable
            return (
                "\e[38;2;192;127;64m"\
                "#{the_string}"\
                "\e[0m"\
            )
        elsif the_token == :string
            return (
                "\e[38;2;184;184;96m"\
                "#{the_string}"\
                "\e[0m"\
            )
        elsif the_token == :int
            return (
                "\e[38;2;127;96;196m"\
                "#{the_string}"\
                "\e[0m"\
            )
        elsif the_token == :float
            return (
                "\e[38;2;127;64;127m"\
                "#{the_string}"\
                "\e[0m"\
            )
        else
            raise Error("the_token needs to be among {:variable, :string, :int, :float}")
        end
    end
end
