RSpec.describe "Fields Inside Text" do
  before(:context) do
    @evento = "Annual Conference"
    @funcao = "Director"
    @nome = "Acme Corp"
    @numero = "42"
    @local = "Main Office"
    @endereco = "123 Main St"

    html = <<-HTML
      <p>Event details: <strong>[EVENTO_TEXTO_CARTA]</strong>, role <strong>[FUNCAO]</strong> [EVENTO_NOME].</p>
      <p>Section nº <strong>[NUMERO_SECAO]</strong> at <strong>[NOME_LOCAL]</strong>, located at <strong>[ENDERECO_LOCAL]</strong>.</p>
      <p>Additional paragraph with no placeholders.</p>
    HTML

    report = ODFReport::Report.new("test/templates/test_fields_inside_text.odt") do |r|
      r.add_text(:body, html)

      r.add_field("EVENTO_TEXTO_CARTA", @evento)
      r.add_field("FUNCAO", @funcao)
      r.add_field("EVENTO_NOME", @nome)
      r.add_field("NUMERO_SECAO", @numero)
      r.add_field("NOME_LOCAL", @local)
      r.add_field("ENDERECO_LOCAL", @endereco)
    end

    report.generate("spec/result/fields_inside_text.odt")

    @data = Inspector.new("spec/result/fields_inside_text.odt")
  end

  it "replaces field placeholders inside text content" do
    expect(@data.text).to include(@evento)
    expect(@data.text).to include(@funcao)
    expect(@data.text).to include(@nome)
    expect(@data.text).to include(@numero)
    expect(@data.text).to include(@local)
    expect(@data.text).to include(@endereco)
  end

  it "removes placeholder markers" do
    expect(@data.text).not_to include("[EVENTO_TEXTO_CARTA]")
    expect(@data.text).not_to include("[FUNCAO]")
    expect(@data.text).not_to include("[EVENTO_NOME]")
  end

  it "preserves non-placeholder text" do
    expect(@data.text).to include("Additional paragraph with no placeholders")
  end
end
