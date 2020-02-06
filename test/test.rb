require 'nokogiri'

xml = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<office:document-content xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0" xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0" xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0" xmlns:ooo="http://openoffice.org/2004/office" xmlns:ooow="http://openoffice.org/2004/writer" xmlns:oooc="http://openoffice.org/2004/calc" xmlns:dom="http://www.w3.org/2001/xml-events" xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rpt="http://openoffice.org/2005/report" xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:grddl="http://www.w3.org/2003/g/data-view#" xmlns:officeooo="http://openoffice.org/2009/office" xmlns:tableooo="http://openoffice.org/2009/table" xmlns:drawooo="http://openoffice.org/2010/draw" xmlns:calcext="urn:org:documentfoundation:names:experimental:calc:xmlns:calcext:1.0" xmlns:field="urn:openoffice:names:experimental:ooo-ms-interop:xmlns:field:1.0" xmlns:formx="urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:form:1.0" xmlns:css3t="http://www.w3.org/TR/css3-text/" office:version="1.2">
  <office:scripts/>
  <office:font-face-decls>
    <style:font-face style:name="Tahoma1" svg:font-family="Tahoma"/>
    <style:font-face style:name="Arial1" svg:font-family="Arial" style:font-family-generic="swiss"/>
    <style:font-face style:name="Courier New" svg:font-family="'Courier New'" style:font-family-generic="modern" style:font-pitch="variable"/>
    <style:font-face style:name="Times New Roman" svg:font-family="'Times New Roman'" style:font-family-generic="roman" style:font-pitch="variable"/>
    <style:font-face style:name="Arial" svg:font-family="Arial" style:font-family-generic="swiss" style:font-pitch="variable"/>
    <style:font-face style:name="Arial Unicode MS" svg:font-family="'Arial Unicode MS'" style:font-family-generic="system" style:font-pitch="variable"/>
    <style:font-face style:name="Tahoma" svg:font-family="Tahoma" style:font-family-generic="system" style:font-pitch="variable"/>
  </office:font-face-decls>
  <office:automatic-styles>
    <style:style style:name="TABLE_5f_01" style:display-name="TABLE_01" style:family="table">
      <style:table-properties style:width="16.999cm" table:align="margins"/>
    </style:style>
    <style:style style:name="TABLE_5f_01.A" style:display-name="TABLE_01.A" style:family="table-column">
      <style:table-column-properties style:column-width="5.666cm" style:rel-column-width="21845*"/>
    </style:style>
    <style:style style:name="TABLE_5f_01.A1" style:display-name="TABLE_01.A1" style:family="table-cell">
      <style:table-cell-properties fo:padding="0.097cm" fo:border-left="0.05pt solid #000000" fo:border-right="none" fo:border-top="0.05pt solid #000000" fo:border-bottom="0.05pt solid #000000"/>
    </style:style>
    <style:style style:name="TABLE_5f_01.C1" style:display-name="TABLE_01.C1" style:family="table-cell">
      <style:table-cell-properties fo:padding="0.097cm" fo:border="0.05pt solid #000000"/>
    </style:style>
    <style:style style:name="TABLE_5f_02" style:display-name="TABLE_02" style:family="table">
      <style:table-properties style:width="16.999cm" table:align="margins"/>
    </style:style>
    <style:style style:name="TABLE_5f_02.A" style:display-name="TABLE_02.A" style:family="table-column">
      <style:table-column-properties style:column-width="5.666cm" style:rel-column-width="21845*"/>
    </style:style>
    <style:style style:name="TABLE_5f_02.A1" style:display-name="TABLE_02.A1" style:family="table-cell">
      <style:table-cell-properties fo:padding="0.097cm" fo:border-left="0.05pt solid #000000" fo:border-right="none" fo:border-top="0.05pt solid #000000" fo:border-bottom="0.05pt solid #000000"/>
    </style:style>
    <style:style style:name="TABLE_5f_02.C1" style:display-name="TABLE_02.C1" style:family="table-cell">
      <style:table-cell-properties fo:padding="0.097cm" fo:border="0.05pt solid #000000"/>
    </style:style>
    <style:style style:name="TABLE_5f_03" style:display-name="TABLE_03" style:family="table">
      <style:table-properties style:width="16.999cm" table:align="margins"/>
    </style:style>
    <style:style style:name="TABLE_5f_03.A" style:display-name="TABLE_03.A" style:family="table-column">
      <style:table-column-properties style:column-width="5.666cm" style:rel-column-width="21845*"/>
    </style:style>
    <style:style style:name="TABLE_5f_03.A1" style:display-name="TABLE_03.A1" style:family="table-cell">
      <style:table-cell-properties fo:padding="0.097cm" fo:border-left="0.05pt solid #000000" fo:border-right="none" fo:border-top="0.05pt solid #000000" fo:border-bottom="0.05pt solid #000000"/>
    </style:style>
    <style:style style:name="TABLE_5f_03.C1" style:display-name="TABLE_03.C1" style:family="table-cell">
      <style:table-cell-properties fo:padding="0.097cm" fo:border="0.05pt solid #000000"/>
    </style:style>
    <style:style style:name="P1" style:family="paragraph" style:parent-style-name="Standard">
      <style:paragraph-properties fo:margin-left="0cm" fo:margin-right="0cm" fo:text-align="start" style:justify-single-word="false" fo:text-indent="0cm" style:auto-text-indent="false" style:text-autospace="none"/>
      <style:text-properties style:font-name="Arial1" fo:font-size="12pt" fo:language="zxx" fo:country="none" style:font-name-asian="Arial1" style:font-size-asian="12pt" style:language-asian="zxx" style:country-asian="none" style:font-name-complex="Arial1" style:font-size-complex="12pt" style:language-complex="zxx" style:country-complex="none"/>
    </style:style>
    <style:style style:name="P2" style:family="paragraph" style:parent-style-name="Standard">
      <style:paragraph-properties fo:margin-left="0cm" fo:margin-right="0cm" fo:text-align="start" style:justify-single-word="false" fo:text-indent="0cm" style:auto-text-indent="false" style:text-autospace="none"/>
      <style:text-properties style:font-name="Arial1" fo:font-size="12pt" fo:language="zxx" fo:country="none" officeooo:rsid="000bcb7a" officeooo:paragraph-rsid="000bcb7a" style:font-name-asian="Arial1" style:font-size-asian="12pt" style:language-asian="zxx" style:country-asian="none" style:font-name-complex="Arial1" style:font-size-complex="12pt" style:language-complex="zxx" style:country-complex="none"/>
    </style:style>
    <style:style style:name="P3" style:family="paragraph" style:parent-style-name="Standard">
      <style:paragraph-properties fo:margin-left="0cm" fo:margin-right="0cm" fo:text-align="start" style:justify-single-word="false" fo:text-indent="0cm" style:auto-text-indent="false" style:text-autospace="none"/>
      <style:text-properties style:font-name="Arial1" fo:font-size="12pt" fo:language="zxx" fo:country="none" officeooo:rsid="000ccec8" officeooo:paragraph-rsid="000ccec8" style:font-name-asian="Arial1" style:font-size-asian="12pt" style:language-asian="zxx" style:country-asian="none" style:font-name-complex="Arial1" style:font-size-complex="12pt" style:language-complex="zxx" style:country-complex="none"/>
    </style:style>
    <style:style style:name="P4" style:family="paragraph" style:parent-style-name="Standard">
      <style:paragraph-properties fo:margin-left="0cm" fo:margin-right="0cm" fo:text-align="center" style:justify-single-word="false" fo:text-indent="0cm" style:auto-text-indent="false" style:text-autospace="none"/>
      <style:text-properties style:font-name="Arial1" fo:font-size="10pt" fo:language="zxx" fo:country="none" style:font-name-asian="Arial1" style:font-size-asian="10pt" style:language-asian="zxx" style:country-asian="none" style:font-name-complex="Arial1" style:font-size-complex="10pt" style:language-complex="zxx" style:country-complex="none"/>
    </style:style>
    <style:style style:name="P5" style:family="paragraph" style:parent-style-name="Table_20_Contents">
      <style:paragraph-properties fo:text-align="start" style:justify-single-word="false"/>
      <style:text-properties style:font-name="Arial1" fo:font-size="12pt" officeooo:rsid="000bd2b4" officeooo:paragraph-rsid="000bd2b4" style:font-name-asian="Arial1" style:font-size-asian="12pt" style:font-name-complex="Arial1" style:font-size-complex="12pt"/>
    </style:style>
    <style:style style:name="P6" style:family="paragraph" style:parent-style-name="Standard">
      <style:paragraph-properties fo:margin-left="0cm" fo:margin-right="0cm" fo:text-align="start" style:justify-single-word="false" fo:text-indent="0cm" style:auto-text-indent="false" style:text-autospace="none"/>
      <style:text-properties style:font-name="Arial1" fo:font-size="12pt" fo:language="zxx" fo:country="none" officeooo:rsid="000bcb7a" officeooo:paragraph-rsid="000bcb7a" style:font-name-asian="Arial1" style:font-size-asian="12pt" style:language-asian="zxx" style:country-asian="none" style:font-name-complex="Arial1" style:font-size-complex="12pt" style:language-complex="zxx" style:country-complex="none"/>
    </style:style>
    <style:style style:name="P7" style:family="paragraph" style:parent-style-name="Standard">
      <style:paragraph-properties fo:margin-left="0cm" fo:margin-right="0cm" fo:text-align="start" style:justify-single-word="false" fo:text-indent="0cm" style:auto-text-indent="false" style:text-autospace="none"/>
      <style:text-properties style:font-name="Arial1" fo:font-size="12pt" fo:language="zxx" fo:country="none" officeooo:rsid="000df62c" officeooo:paragraph-rsid="000df62c" style:font-name-asian="Arial1" style:font-size-asian="12pt" style:language-asian="zxx" style:country-asian="none" style:font-name-complex="Arial1" style:font-size-complex="12pt" style:language-complex="zxx" style:country-complex="none"/>
    </style:style>
    <style:style style:name="P8" style:family="paragraph" style:parent-style-name="Standard">
      <style:paragraph-properties fo:margin-left="0cm" fo:margin-right="0cm" fo:text-align="start" style:justify-single-word="false" fo:text-indent="0cm" style:auto-text-indent="false" style:text-autospace="none"/>
      <style:text-properties style:font-name="Arial1" fo:font-size="12pt" fo:language="zxx" fo:country="none" style:font-name-asian="Arial1" style:font-size-asian="12pt" style:language-asian="zxx" style:country-asian="none" style:font-name-complex="Arial1" style:font-size-complex="12pt" style:language-complex="zxx" style:country-complex="none"/>
    </style:style>
    <style:style style:name="P9" style:family="paragraph" style:parent-style-name="Standard">
      <style:paragraph-properties fo:margin-left="0cm" fo:margin-right="0cm" fo:text-align="start" style:justify-single-word="false" fo:text-indent="0cm" style:auto-text-indent="false" style:text-autospace="none"/>
      <style:text-properties style:font-name="Arial1" fo:font-size="12pt" fo:language="zxx" fo:country="none" officeooo:paragraph-rsid="000df62c" style:font-name-asian="Arial1" style:font-size-asian="12pt" style:language-asian="zxx" style:country-asian="none" style:font-name-complex="Arial1" style:font-size-complex="12pt" style:language-complex="zxx" style:country-complex="none"/>
    </style:style>
    <style:style style:name="P10" style:family="paragraph" style:parent-style-name="Standard">
      <style:paragraph-properties fo:margin-left="0cm" fo:margin-right="0cm" fo:text-align="start" style:justify-single-word="false" fo:text-indent="0cm" style:auto-text-indent="false" style:text-autospace="none"/>
      <style:text-properties style:font-name="Courier New" fo:font-size="14pt" fo:language="zxx" fo:country="none" officeooo:rsid="000df62c" officeooo:paragraph-rsid="000df62c" style:font-name-asian="Arial1" style:font-size-asian="14pt" style:language-asian="zxx" style:country-asian="none" style:font-name-complex="Arial1" style:font-size-complex="14pt" style:language-complex="zxx" style:country-complex="none"/>
    </style:style>
    <style:style style:name="P11" style:family="paragraph" style:parent-style-name="Standard">
      <style:paragraph-properties fo:margin-left="0cm" fo:margin-right="0cm" fo:text-align="start" style:justify-single-word="false" fo:text-indent="0cm" style:auto-text-indent="false" fo:break-before="page" style:text-autospace="none"/>
      <style:text-properties style:font-name="Courier New" fo:font-size="14pt" fo:language="zxx" fo:country="none" officeooo:rsid="000df62c" officeooo:paragraph-rsid="000df62c" style:font-name-asian="Arial1" style:font-size-asian="14pt" style:language-asian="zxx" style:country-asian="none" style:font-name-complex="Arial1" style:font-size-complex="14pt" style:language-complex="zxx" style:country-complex="none"/>
    </style:style>
    <style:style style:name="P12" style:family="paragraph" style:parent-style-name="Table_20_Contents">
      <style:paragraph-properties fo:text-align="start" style:justify-single-word="false"/>
      <style:text-properties style:font-name="Arial1" fo:font-size="12pt" officeooo:rsid="000bd2b4" officeooo:paragraph-rsid="000df62c" style:font-name-asian="Arial1" style:font-size-asian="12pt" style:font-name-complex="Arial1" style:font-size-complex="12pt"/>
    </style:style>
    <style:style style:name="Sect1" style:family="section">
      <style:section-properties style:editable="false">
        <style:columns fo:column-count="1" fo:column-gap="0cm"/>
      </style:section-properties>
    </style:style>
  </office:automatic-styles>
  <office:body>
    <office:text text:use-soft-page-breaks="true">
      <text:sequence-decls>
        <text:sequence-decl text:display-outline-level="0" text:name="Illustration"/>
        <text:sequence-decl text:display-outline-level="0" text:name="Table"/>
        <text:sequence-decl text:display-outline-level="0" text:name="Text"/>
        <text:sequence-decl text:display-outline-level="0" text:name="Drawing"/>
      </text:sequence-decls>
      <text:p text:style-name="P10">fields_spec.rb</text:p>
      <text:p text:style-name="P10"/>
      <text:p text:style-name="P2"/>
      <text:p text:style-name="P2">Field_01: Smitham, Veum and Funk</text:p>
      <text:p text:style-name="P2">Field_02: Bert Bogan</text:p>
      <text:p text:style-name="P1"/>
      <text:p text:style-name="P1"/>
      <table:table table:name="TABLE_01" table:style-name="TABLE_5f_01">
        <table:table-column table:style-name="TABLE_5f_01.A" table:number-columns-repeated="3"/>
        <table:table-row xmlns:table="table" xmlns:draw="draw" xmlns:xlink="xlink" xmlns:text="text">
          <table:table-cell table:style-name="TABLE_5f_01.A1" office:value-type="string">
            <text:p text:style-name="P5">2063458380</text:p>
          </table:table-cell>
          <table:table-cell table:style-name="TABLE_5f_01.A1" office:value-type="string">
            <text:p text:style-name="P5">Huey Skiles</text:p>
          </table:table-cell>
          <table:table-cell table:style-name="TABLE_5f_01.C1" office:value-type="string">
            <text:p text:style-name="P5">[COLUMN_03]</text:p>
          </table:table-cell>
        </table:table-row>
        <table:table-row xmlns:table="table" xmlns:draw="draw" xmlns:xlink="xlink" xmlns:text="text">
          <table:table-cell table:style-name="TABLE_5f_01.A1" office:value-type="string">
            <text:p text:style-name="P5">2738946152</text:p>
          </table:table-cell>
          <table:table-cell table:style-name="TABLE_5f_01.A1" office:value-type="string">
            <text:p text:style-name="P5">Elfriede Wyman</text:p>
          </table:table-cell>
          <table:table-cell table:style-name="TABLE_5f_01.C1" office:value-type="string">
            <text:p text:style-name="P5">[COLUMN_03]</text:p>
          </table:table-cell>
        </table:table-row>
        <table:table-row xmlns:table="table" xmlns:draw="draw" xmlns:xlink="xlink" xmlns:text="text">
          <table:table-cell table:style-name="TABLE_5f_01.A1" office:value-type="string">
            <text:p text:style-name="P5">7700127050</text:p>
          </table:table-cell>
          <table:table-cell table:style-name="TABLE_5f_01.A1" office:value-type="string">
            <text:p text:style-name="P5">Waldo Ebert</text:p>
          </table:table-cell>
          <table:table-cell table:style-name="TABLE_5f_01.C1" office:value-type="string">
            <text:p text:style-name="P5">[COLUMN_03]</text:p>
          </table:table-cell>
        </table:table-row>
      </table:table>
      <text:p text:style-name="P1"/>
      <text:p text:style-name="P1"/>
      <text:section xmlns:draw="draw" xmlns:xlink="xlink" xmlns:text="text" text:style-name="Sect1" text:name="3944a5de-a0e4-4a00-a1d5-80e5082221f3">
        <text:p text:style-name="P3">7700127050</text:p>
        <text:p text:style-name="P3">Waldo Ebert</text:p>
      </text:section>
      <text:p text:style-name="P1"/>
      <text:p text:style-name="P1"/>
      <text:p text:style-name="P1"/>
      <text:p text:style-name="P1"/>
      <text:p text:style-name="P11">tables_spec.rb</text:p>
      <text:p text:style-name="P10"/>
      <text:p text:style-name="P9"/>
      <table:table table:name="TABLE_02" table:style-name="TABLE_5f_02">
        <table:table-column table:style-name="TABLE_5f_02.A" table:number-columns-repeated="3"/>
        <table:table-row>
          <table:table-cell table:style-name="TABLE_5f_02.A1" office:value-type="string">
            <text:p text:style-name="P12">[COLUMN_01]</text:p>
          </table:table-cell>
          <table:table-cell table:style-name="TABLE_5f_02.A1" office:value-type="string">
            <text:p text:style-name="P12">[COLUMN_02]</text:p>
          </table:table-cell>
          <table:table-cell table:style-name="TABLE_5f_02.C1" office:value-type="string">
            <text:p text:style-name="P12">[COLUMN_03]</text:p>
          </table:table-cell>
        </table:table-row>
      </table:table>
      <text:p text:style-name="P7"/>
      <table:table table:name="TABLE_03" table:style-name="TABLE_5f_03">
        <table:table-column table:style-name="TABLE_5f_03.A" table:number-columns-repeated="3"/>
        <table:table-row>
          <table:table-cell table:style-name="TABLE_5f_03.A1" office:value-type="string">
            <text:p text:style-name="P12">[COLUMN_01]</text:p>
          </table:table-cell>
          <table:table-cell table:style-name="TABLE_5f_03.A1" office:value-type="string">
            <text:p text:style-name="P12">[COLUMN_02]</text:p>
          </table:table-cell>
          <table:table-cell table:style-name="TABLE_5f_03.C1" office:value-type="string">
            <text:p text:style-name="P12">[COLUMN_03]</text:p>
          </table:table-cell>
        </table:table-row>
      </table:table>
      <text:p text:style-name="P7"/>
      <text:p text:style-name="P4">END_OF_DOCUMENT</text:p>
    </office:text>
  </office:body>
</office:document-content>
XML

tmp = Nokogiri::XML(xml, &:noblanks)

puts tmp.at("text|section")
# tmp.root['xmlns:table'] = "urn:oasis:names:tc:opendocument:xmlns:table:1.0"
# tmp.root['xmlns:draw'] = "urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
# tmp.root['xmlns:xlink'] = "urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
#
# # xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0"
#
# doc = Nokogiri::XML(tmp.to_xml(:save_with => Nokogiri::XML::Node::SaveOptions::AS_XML))
#
# puts doc
#
# puts "============="
#
# nodo = doc.search("//draw:frame[@draw:name='IMAGE_IN_TABLE']/draw:image")
# puts nodo
#
# nodo.attribute('href').content = 'new_href'
#
# puts nodo
#
# puts "-------------"
#
# puts doc

# require 'ox'
#
# xml = <<-XML
#     <table:table-row table:style-name="IMAGE_5f_TABLE.2">
#       <table:table-cell table:style-name="IMAGE_5f_TABLE.A2" office:value-type="string">
#         <text:p text:style-name="P8">[IMAGE_NAME]</text:p>
#       </table:table-cell>
#       <table:table-cell table:style-name="IMAGE_5f_TABLE.B2" office:value-type="string">
#         <text:p text:style-name="P7">
#           <draw:frame draw:style-name="fr2" draw:name="sf" text:anchor-type="paragraph" svg:width="2.5in" svg:height="1.25in" draw:z-index="2">
#             <draw:image xlink:href="Pictures/C2.jpg" xlink:type="simple" xlink:show="embed" xlink:actuate="onLoad" loext:mime-type="image/jpeg"/>
#           </draw:frame>
#           <draw:frame draw:style-name="fr2" draw:name="IMAGE_IN_TABLE" text:anchor-type="paragraph" svg:width="2.5in" svg:height="1.25in" draw:z-index="2">
#             <draw:image xlink:href="Pictures/10000000000000F00000007807BDCBD66FA37CC2.jpg" xlink:type="simple" xlink:show="embed" xlink:actuate="onLoad" loext:mime-type="image/jpeg"/>
#           </draw:frame>
#         </text:p>
#       </table:table-cell>
#     </table:table-row>
# XML
#
# doc = Ox.parse(xml)
#
# frame = doc.locate("*/draw:frame[@draw:name=IMAGE_IN_TABLE]")[0]
#
# img = frame.locate('*/draw:image')[0]
#
# img[:'xlink:href'] = "picture"
# frame[:'draw:name'] = "novo nome"
#
# puts Ox.dump(doc)
