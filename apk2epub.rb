#! /usr/bin/env ruby

require 'rubygems'
require 'zipruby'

class Apk2Epub
  def self.do_convert(apk_file_name, epub_file_name)
    epub_data = Apk2Epub.extract_epub_data(apk_file_name)
    Apk2Epub.write_epub(epub_data, epub_file_name)
  end

  def self.extract_epub_data(apk_file_name)
    epub_data = Zip::Archive.open_buffer(Zip::CREATE) do |epub_archive|
      Zip::Archive.open(apk_file_name) do |archive|
        archive.each do |zip_entry|
          next unless %r!^assets/! =~ zip_entry.name
          zip_entry_data = zip_entry.read(zip_entry.size)
          zip_entry_name = zip_entry.name.sub(%!assets/!,'')
          epub_archive.add_buffer(zip_entry_name, zip_entry_data)
        end
      end
    end

    return epub_data
  end

  def self.write_epub(epub_data, epub_file_name)
    
    Zip::Archive.open(epub_file_name, Zip::CREATE|Zip::TRUNC|Zip::BEST_SPEED) do |epub_archive_file|
      Zip::Archive.open_buffer(epub_data) do |epub_archive_data|
        epub_archive_data.each do |epub_entry|
          epub_entry_data = epub_entry.read(epub_entry.size)
          epub_archive_file.add_buffer(epub_entry.name, epub_entry_data)
        end
      end
    end
  end
end

def convert_apk_to_epub(apk_file_name)
  epub_file_name = apk_file_name.sub(/\.apk$/, '.epub')
  puts("converting #{apk_file_name} to #{epub_file_name}")
  Apk2Epub.do_convert(apk_file_name, epub_file_name)
end

def usage
  puts("#{$PROGRAM_NAME} [o'reilly e-book apk files]")
end

def main
  if ARGV.empty?
    usage
    exit
  else
    ARGV.each do |apk_file_name|
      convert_apk_to_epub(apk_file_name)
    end
  end
end

main
