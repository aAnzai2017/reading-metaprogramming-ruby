# 次の仕様を満たすSimpleBotクラスとDSLを作成してください
#
# # これは、作成するSimpleBotクラスの利用イメージです
# class Bot < SimpleBot
#   setting :name, 'bot'
#   respond 'keyword' do
#     "response #{settings.name}"
#   end
# end
#
# Bot.new.ask('keyword') #=> 'respond bot'
#
# 1. SimpleBotクラスを継承したクラスは、クラスメソッドrespond, settingを持ちます
# 2. SimpleBotクラスのサブクラスのインスタンスは、インスタンスメソッドask, settingsを持ちます
#     1. askは、一つの引数をとります
#     2. askに渡されたオブジェクトが、後述するrespondメソッドで設定したオブジェクトと一致する場合、インスタンスは任意の返り値を持ちます
#     3. 2のケースに当てはまらない場合、askメソッドの戻り値はnilです
#     4. settingsメソッドは、任意のオブジェクトを返します
#     5. settingsメソッドは、後述するクラスメソッドsettingによって渡された第一引数と同名のメソッド呼び出しに応答します
# 3. クラスメソッドrespondは、keywordとブロックを引数に取ります
#     1. respondメソッドの第1引数keywordと同じ文字列が、インスタンス変数askに渡された時、第2引数に渡したブロックが実行され、その結果が返されます
# 4. クラスメソッドsettingは、引数を2つ取り、1つ目がキー名、2つ目が設定する値です
#     1. settingメソッドに渡された値は、インスタンスメソッド `settings` から返されるオブジェクトに、メソッド名としてアクセスすることで取り出すことができます
#     2. e.g. クラスメソッドで `setting :name, 'bot'` と実行した場合は、インスタンス内で `settings.name` の戻り値は `bot` の文字列になります

require 'byebug'

class SimpleBot
    def self.respond key, &block
        @@responds ||= {}
        @@responds[key] = block
    end

    def self.setting key, value
        @@settings ||= {}
        @@settings[key] = value
    end

    def initialize
        @obj = Object.new
        s = @@settings
        @obj.instance_eval do
            define_singleton_method :method_missing do |key|
                if s.include? key
                    s[key]
                else
                    nil
                end
            end
        end
    end

    def ask word
        if @@responds.include? word
            instance_eval &@@responds[word]
        else
            nil
        end
    end

    def settings
        @obj
    end
end


class Bot < SimpleBot
  setting :name, 'bot'
  respond 'keyword' do
    "response #{settings.name}"
    # 'hello'
  end
end

puts Bot.new.ask('keyword')