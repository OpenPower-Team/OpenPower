import pycountry
import gettext
import csv

languages = {
    "English": "en",
    "Spanish_Spain": "es",
    "Spanish - Latin America": "es_419",
    "Portuguese_Brazil": "pt_BR",
    "Portuguese - Portugal": "pt_PT",
    "French": "fr",
    "German": "de",
    "Italian": "it",
    "Dutch": "nl",
    "Romanian": "ro",
    "Ukrainian": "uk",
    "Crimean tatar": "crh",
    "Belarusian": "be",
    "Polish": "pl",
    "Czech": "cs",
    "Bulgarian": "bg",
    "Latvian": "lv",
    "Lithuanian": "lt",
    "Estonian": "et",
    "Danish": "da",
    "Swedish": "sv",
    "Finnish": "fi",
    "Norwegian": "no",
    "Georgian": "ka",
    "Turkish": "tr",
    "Vietnamese": "vi",
    "Greek": "el",
    "Hungarian": "hu",
    "Thai": "th",
    "Indonesian": "id",
    "Korean": "ko",
    "Traditional Chinese": "zh_TW",
    "Simplified Chinese": "zh_CN",
    "Japanese": "ja",
    "Arabic": "ar",
    "Armenian": "hy",
    "Azerbaijani": "az",
    "Georgian": "ka",
    "Kazakh": "kk",
    "Kyrgyz": "ky",
    "Tajik": "tg",
    "Turkmen": "tk",
    "Uzbek": "uz"
}

# Function to get country name in specific language
def get_country_name(country_code, language_code):
    try:
        if language_code == 'en':
            return pycountry.countries.get(alpha_3=country_code).name
        translation = gettext.translation('iso3166-1', pycountry.LOCALES_DIR, languages=[language_code])
        translation.install()
        return _(pycountry.countries.get(alpha_3=country_code).name)
    except Exception as e:
        return None

# Create TSV file
with open('countries.tsv', 'w', newline='', encoding='utf-8') as tsv_file:
    tsv_writer = csv.writer(tsv_file, delimiter='\t')
    
    # Write header
    header = ['Country Code'] + list(languages.values())
    tsv_writer.writerow(header)
    
    # Write country names
    for country in pycountry.countries:
        row = [country.alpha_3]
        for lang, lang_code in languages.items():
            country_name = get_country_name(country.alpha_3, lang_code)
            row.append(country_name if country_name else "N/A")
        tsv_writer.writerow(row)
