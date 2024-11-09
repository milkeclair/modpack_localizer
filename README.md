## ModpackLocalizer

Translator for FTBQuest. (title, subtitle, description)  
If you want to translate to other languages than Japanese,  
please add the `language` option during initialization.  
Can always get help with `ModpackLocalizer.help`

#### Example

`ModpackLocalizer::SNBT::Performer.new(language: "English")`  
or if no specific configs required  
`ModpackLocalizer.omakase(language: "English")`

## Steps

1. Download [release](https://github.com/milkeclair/modpack_localizer/releases)
2. Make `.env` file
3. Add `OPENAI_API_KEY=your_api_key` to `.env`
4. Optional: Add `OPENAI_MODEL=some_openai_model` to `.env` **(default: gpt-4o-mini)**
5. Add `some.snbt` or `quests` directory contents to `quests` directory
6. Check `output` directory

## ModpackLocalizer.omakase Options

#### language

Which language do you want to translate to?
**(default: Japanese)**

#### country

Your country name
**(default: Japan)**

#### locale_code

Which locale code do you want to use?  
If you specified this, you don't need to specify the country.
**(default: nil)**

#### threadable

Do you want to exec in parallel?
**(default: false)**

## Initialize Options

#### output_logs

Want to output OpenAI usage logs?
**(default: true)**

#### except_words

Words that you don't want to translate
**(default: empty array)**

#### language

Which language do you want to translate to?
**(default: Japanese)**

#### display_help

Want to display help?
**(default: true)**

## Only for jar performer

#### country

Your country name
**(default: Japan)**

#### locale_code

Which locale code do you want to use?  
If you specified this, you don't need to specify the country.
**(default: nil)**