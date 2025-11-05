# plugins/I18nPlugin.rb
require_relative 'Plugin'
require 'cgi'

class I18nPlugin < Plugin
  attr_reader :translations

  # data[0] is expected to be a hash like:
  # { "Telegram" => {"en"=>"Receive Alerts on Telegram", "es"=>"Recibe Alertas en Telegram"}, ... }
  def initialize(data)
    @translations = data[0] || {}
  end

  def execute
    out = {}

    # For each key, emit an HTML span with data attributes.
    translations.each do |key, langs|
      en = (langs['en'] || key).to_s
      es = (langs['es'] || en).to_s
      out["lang_#{key}"] =
        %Q(<span class="i18n" data-i18n-key="#{h(key)}" data-en="#{h(en)}" data-es="#{h(es)}"></span>)
    end

    # Emit the helper <script> – include this once (e.g., in footer)
    out['script'] = <<~HTML
      <script>
      (function(){
        var pref = (navigator.language || navigator.userLanguage || 'en').toLowerCase();
        var lang = pref.startsWith('es') ? 'es' : 'en';
        // Optional: set <html lang=".."> so :lang CSS also works.
        try { document.documentElement.setAttribute('lang', lang); } catch(e){}
        document.querySelectorAll('.i18n[data-i18n-key]').forEach(function(el){
          var text = el.dataset[lang] || el.dataset.en || '';
          el.textContent = text;
        });
      })();
      </script>
    HTML

    out
  end

  private
  def h(s) = CGI.escapeHTML(s)
end
