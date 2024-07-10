# frozen_string_literal: true

# name: replace-translations-global
# about: replace translations
# version: 0.0.1
# authors:  Linca
# url: https://github.com/Lhcfl/replace-translations-global
# required_version: 3.0.0

enabled_site_setting :enable_replace_translations_global

after_initialize do
  module ::JsLocaleHelper
    class << self
      alias_method :load_translations_old, :load_translations
      def load_translations(locale)
        ret = load_translations_old(locale)
        begin
          replacements = {}
          SiteSetting.replace_translations_replacements_map.each do |rule|
            matched = /([\s\S]+):([\s\S]+)=>([\s\S]*)/.match(rule)
            if (matched.present?)
              replacements[matched[1]] ||= []
              replacements[matched[1]].push([matched[2], matched[3]])
            end
          end

          rules = replacements[locale.to_s]
          if (rules.present?)
            ret.deep_transform_values do |val|
              if val.respond_to? :gsub
                rules.each do |ori, rep|
                  val.gsub! ori, rep
                end
              end
              val
            end
          else
            ret
          end
        rescue
          ret
        end
      end
    end
  end
end
