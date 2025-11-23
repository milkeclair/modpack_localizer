## ModpackLocalizer

Localizer for Minecraft Modpack.
If you want to translate to other languages than Japanese,  
please add the `language` option during initialization.  
Can always get help with `ModpackLocalizer.help`

#### Example

`ModpackLocalizer::SNBT::Performer.new(language: "English")`  
`ModpackLocalizer::JAR::Performer.new(language: "English")`  
or if no specific configs required  
`ModpackLocalizer.omakase(language: "English")`

## Steps

1. Download [release](https://github.com/milkeclair/modpack_localizer/releases)
2. Make `.env` file
3. Add your API keys to `.env` file [see](https://github.com/milkeclair/translation_api)
4. Add `some.snbt` or `quests` directory contents to `quests` directory
5. Add `some.jar` files to `mods` directory
6. Double click `start.bat` file
7. Check `output` directory

## Options for omakase method

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

## Initialize options

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

## Only for jar performer initialize options

#### country

Your country name  
**(default: Japan)**

#### locale_code

Which locale code do you want to use?  
If you specified this, you don't need to specify the country.  
**(default: nil)**
