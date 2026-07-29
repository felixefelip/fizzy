## Inferência do app E do pseudo-código gerado.
##
## `sig/` na lista de entrada não é opcional: os sidecars de runtime (AR,
## controller, view, Current) são `.rb` comuns cujo RBS o analyzer infere, e é
## de lá que sai o tipo das classes ERB e dos runners de action. Sem `sig/` na
## entrada, nada do que os geradores abaixo emitem vira tipo.
##
## O destino é o padrão `sig/generated/<caminho-da-fonte>.rbs`, então o RBS do
## pseudo-código aninha (`sig/generated/sig/generated/steep_*_runtime/*.rbs`).
## Feio, mas correto: o Steepfile carrega `sig/` inteiro, e os geradores só
## apagam os próprios `steep_*_runtime/`, nunca o inferido.
rbs_infer_all:
	bundle exec rbs_infer app/ lib/ sig/ --output

rbs_collection_update:
	rbs collection update

rbs_rails_generator:
	bundle exec rake rbs_rails:all

rbs_infer_rails_custom:
	bundle exec rake rbs_infer:rails_custom:all

rbs_infer_module_self_types:
	bundle exec rake rbs_infer:module_self_types:all

rbs_infer_ar_runtime:
	bundle exec rake rbs_infer:ar_runtime:all

rbs_infer_controller_runtime:
	bundle exec rake rbs_infer:controller_runtime:all

rbs_infer_current_runtime:
	bundle exec rake rbs_infer:current_runtime:all

rbs_infer_actionview_runtime:
	bundle exec rake rbs_infer:actionview_runtime:all

## Diretórios órfãos, de geradores que não existem mais. Precisam sair ANTES da
## primeira execução dos geradores novos, senão declaram as mesmas classes duas
## vezes e envenenam o ambiente RBS inteiro:
##
##   sig/rbs_infer_erb/         -> substituído por sig/generated/steep_actionview_runtime/
##   sig/generated/.expanded/   -> dump de debug dos SourceExpanders; o de
##                                 app/models/current.rb é do expander que virou
##                                 o CurrentAttributesRuntimeGenerator
##
## Apagar `.expanded/` inteiro é seguro: é sidecar de debug (o Steep só carrega
## `*.rbs`, e um glob `sig/**/*.rb` não entra em diretório com ponto), e o que
## ainda for real volta na próxima execução do `rbs_infer_all`.
##
## `sig/generated/app/` e `sig/generated/lib/` NÃO entram aqui: são a saída viva
## da inferência.
##
## Alvo separado e fora do `rbs_generators_all` de propósito: apaga coisa, e a
## decisão é sua.
rbs_clean_stale:
	rm -rf sig/rbs_infer_erb sig/generated/.expanded

## Ordem importa: rbs_rails primeiro (é dele que vêm os markers `Validated` e as
## proxies de associação), depois os sidecars de pseudo-código, e o
## `rbs_infer_all` por último, porque ele lê tudo que os anteriores escreveram.
##
## Sem enumerize e sem carrierwave: nenhum dos dois está no Gemfile deste app, e
## os geradores correspondentes só varreriam `app/models` para não emitir nada.
## Sem devise: a autenticação aqui é própria (bcrypt + concern Authentication),
## e o gerador lê `devise_for` de config/routes.rb, que não existe.
rbs_generators_all:
	make rbs_rails_generator
	make rbs_infer_rails_custom
	make rbs_infer_module_self_types
	make rbs_infer_ar_runtime
	make rbs_infer_controller_runtime
	make rbs_infer_current_runtime
	make rbs_infer_actionview_runtime
	make rbs_infer_all

steep:
	bundle exec steep check

## `.steep_postconditions.yml` é SAÍDA do steep sobre o pseudo-código e ENTRADA
## do rbs_infer. Uma passada só mostra tipos nilable que são atraso, não
## regressão — repita até o `git diff` de sig/ parar de mudar (no dummy do
## rbs_infer leva de 2 a 4 voltas).
rbs_converge:
	make steep || true
	make rbs_infer_all
