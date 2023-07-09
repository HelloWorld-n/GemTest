class SyntaxUtil

    def self.syntax_string(the_string, the_token)
        if the_token == :variable
            return (
                "\e[38;2;253;147;83m"\
                "#{the_string}"\
                "\e[0m"\
            )
        elsif the_token == :string
            return (
                "\e[38;2;252;229;102m"\
                "#{the_string}"\
                "\e[0m"\
            )
        elsif the_token == :int
            return (
                "\e[38;2;148;138;227m"\
                "#{the_string}"\
                "\e[0m"\
            )
        elsif the_token == :float
            return (
                "\e[38;2;180;136;227m"\
                "#{the_string}"\
                "\e[0m"\
            )
        else
            raise Error("the_token needs to be among {:variable, :string, :int, :float}")
        end
    end
end
