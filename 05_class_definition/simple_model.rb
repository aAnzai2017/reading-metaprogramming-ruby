# 次の仕様を満たす、SimpleModelモジュールを作成してください
#
# 1. include されたクラスがattr_accessorを使用すると、以下の追加動作を行う
#   1. 作成したアクセサのreaderメソッドは、通常通りの動作を行う
#   2. 作成したアクセサのwriterメソッドは、通常に加え以下の動作を行う
#     1. 何らかの方法で、writerメソッドを利用した値の書き込み履歴を記憶する
#     2. いずれかのwriterメソッド経由で更新をした履歴がある場合、 `true` を返すメソッド `changed?` を作成する
#     3. 個別のwriterメソッド経由で更新した履歴を取得できるメソッド、 `ATTR_changed?` を作成する
#       1. 例として、`attr_accessor :name, :desc`　とした時、このオブジェクトに対して `obj.name = 'hoge` という操作を行ったとする
#       2. `obj.name_changed?` は `true` を返すが、 `obj.desc_changed?` は `false` を返す
#       3. 参考として、この時 `obj.changed?` は `true` を返す
# 2. initializeメソッドはハッシュを受け取り、attr_accessorで作成したアトリビュートと同名のキーがあれば、自動でインスタンス変数に記録する
#   1. ただし、この動作をwriterメソッドの履歴に残してはいけない
# 3. 履歴がある場合、すべての操作履歴を放棄し、値も初期状態に戻す `restore!` メソッドを作成する

module SimpleModel
    def self.included cls
        cls.class_eval do
            def self.attr_accessor *args
                args.each do |name|
                    define_method name do
                        instance_variable_get("@#{name.to_s}")
                    end

                    define_method "#{name.to_s}=" do |val|
                        instance_variable_set("@#{name.to_s}", val)
                        
                        changed_arr = if instance_variable_defined?('@changed_arr') 
                            instance_variable_get("@changed_arr")
                        else
                            []
                        end
                        
                        changed_arr << name unless changed_arr.include? name
                        instance_variable_set("@changed_arr", changed_arr)
                    end

                    define_method "#{name.to_s}_changed?" do
                        return false unless instance_variable_defined?('@changed_arr')
                        changed_arr = instance_variable_get("@changed_arr")
                        changed_arr.include? name
                    end
                end
            end

            def changed?
                @changed_arr.size > 0
            end

            def restore!
                for k, v in @initial_state
                    instance_variable_set("@#{k}", v)
                end
                @changed_arr = []
            end

            def initialize(**hash)
                @initial_state = hash
                @changed_arr ||= []
                for k, v in hash
                    instance_variable_set("@#{k}", v)
                end
            end
        end
    end
end
