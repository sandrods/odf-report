require 'rubygems'
require 'zipruby'
require 'fileutils'
require 'nokogiri'
require 'tmpdir'

require File.expand_path('../odf-report/parser/default',  __FILE__)

require File.expand_path('../odf-report/images',    __FILE__)
require File.expand_path('../odf-report/field',     __FILE__)
require File.expand_path('../odf-report/text',      __FILE__)
require File.expand_path('../odf-report/file',      __FILE__)
require File.expand_path('../odf-report/fields',    __FILE__)
require File.expand_path('../odf-report/nested',    __FILE__)
require File.expand_path('../odf-report/section',   __FILE__)
require File.expand_path('../odf-report/table',     __FILE__)
require File.expand_path('../odf-report/report',    __FILE__)
