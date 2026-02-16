require "rubygems"
require "zip"
require "fileutils"
require "nokogiri"
require "mime/types"
require "securerandom"

require File.expand_path("../odf-report/parser/default", __FILE__)

require File.expand_path("../odf-report/data_source", __FILE__)
require File.expand_path("../odf-report/field", __FILE__)
require File.expand_path("../odf-report/text", __FILE__)
require File.expand_path("../odf-report/template", __FILE__)
require File.expand_path("../odf-report/image", __FILE__)
require File.expand_path("../odf-report/composable", __FILE__)
require File.expand_path("../odf-report/nestable", __FILE__)
require File.expand_path("../odf-report/section", __FILE__)
require File.expand_path("../odf-report/table", __FILE__)
require File.expand_path("../odf-report/report", __FILE__)
