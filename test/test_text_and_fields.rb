# coding: UTF-8
require '../lib/odf-report'
require 'ostruct'
require 'faker'

html = <<-HTML
  <p>Comunico-lhe que este Juízo, nos termos do artigo 120 do Código Eleitoral (CE), combinado com [EVENTO_TEXTO_CARTA], nomeia-o(a) para atuar como <strong>[FUNCAO]</strong> [EVENTO_NOME].</p>

  <p>Vossa Senhoria deverá comparecer à Seção nº <strong>[NUMERO_SECAO]</strong> do local <strong>[NOME_LOCAL]</strong>, situado na <strong>[ENDERECO_LOCAL]</strong> – bairro <strong>[NOME_BAIRRO]</strong> – <strong>[NOME_MUNICIPIO]</strong>, às <strong>7 horas</strong> do <strong>dia [EVENTO_DATA]</strong>.</p>

  <p>Esclareço-lhe que o serviço eleitoral prefere a qualquer outro e é obrigatório, nos termos do art. 365 do CE, e que recusar ou abandonar o serviço eleitoral sem justa causa configura crime previsto no art. 344 do mesmo Código.</p>

  <p>Fica Vossa Senhoria cientificado(a) de que não poderão atuar como mesários os cidadãos que se encontrem sujeitos aos impedimentos previstos no artigo 120, § 1º, incisos I a IV do Código Eleitoral, combinado com o artigo 63, § 2º da Lei nº 9.504/97, abaixo mencionados:</p>

  <p style="margin-left:1.76cm;"><em>Art. 120 - § 1º Não podem ser nomeados presidentes e mesários: I. os candidatos e seus parentes ainda que por afinidade, até o segundo grau, inclusive, e bem assim o cônjuge; II. os membros de diretórios de partidos desde que exerça função executiva; III. as autoridades e agentes policiais, bem como os funcionários no desempenho de cargos de confiança do Executivo; IV. os que pertencerem ao serviço eleitoral. </em></p>

  <p style="margin-left:1.76cm;"><em>Art. 63 - [...] § 2º Não podem ser nomeados presidentes e mesários os menores de dezoito anos. </em></p>

  <p>Os motivos que porventura impossibilitem a sua participação deverão ser encaminhados a este Juízo, até 5 dias a contar do recebimento desta, sendo que, por questão de saúde, dependerão de prévio exame procedido pelo serviço médico do Tribunal Regional Eleitoral ou, inexistindo este serviço oficial no município, poderá ser aceito atestado de médico particular, a critério deste(a) Juiz(a) Eleitoral.</p>

  <p>Outrossim, os membros das mesas receptoras serão dispensados do serviço pelo dobro dos dias de convocação, mediante declaração expedida pela Justiça Eleitoral, sem prejuízo do salário, vencimento ou qualquer outra vantagem, de acordo com o art. 98 da Lei n. 9.504/97.</p>
HTML


report = ODFReport::Report.new("carta_convocacao_em.odt") do |r|

  r.add_text(:corpo, html)

  r.add_field('EVENTO_TEXTO_CARTA', Faker::Lorem.sentence)
  r.add_field('FUNCAO', Faker::Lorem.word)
  r.add_field('EVENTO_NOME', Faker::Company.name)

  r.add_field('NUMERO_SECAO', Faker::Number.number(3))
  r.add_field('NOME_LOCAL', Faker::Company.name)
  r.add_field('ENDERECO_LOCAL', Faker::Address.street_address)
end

report.generate("./result/")