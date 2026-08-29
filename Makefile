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

## `bundle exec` não é opcional aqui. As entradas `source: rubygems` do
## rbs_collection.lock.yaml são pinadas na VERSÃO EXATA do gem instalado, e o
## `rbs` que roda é quem decide qual versão é essa. Rodado fora do bundle do app,
## o lock sai pinado nas versões do outro bundle e o `steep check` morre com
## `UnknownLibraryError: Cannot find type definitions for library: <gem> (<ver>)`.
rbs_collection_update:
	bundle exec rbs collection update

rbs_rails_generator:
	bundle exec rake rbs_rails:all

rbs_infer_rails_custom:
	bundle exec rake rbs_infer:rails_custom:all

rbs_infer_module_self_types:
	bundle exec rake rbs_infer:module_self_types:all

rbs_infer_ar_runtime:
	bundle exec rake rbs_infer:ar_runtime:all

## Pseudo-código do que a LINGUAGEM roda numa declaração, irmão dos
## `steep_*_runtime` que modelam o runtime de um FRAMEWORK. `include M` chama
## `M.included(self)`, e essa chamada é a única coisa que diz qual classe é o
## `base` de um hook — `Module#include` é escrito em C, então nenhuma fonte do
## projeto diz isso.
##
## Sem rake task de propósito: o gerador é CORE (`include` é Ruby puro, não
## Rails), então o railtie não o registra e a chamada é direta. Escreve em
## `sig/generated/steep_ruby_runtime/`, cujo RBS sai do `rbs_infer_all`.
rbs_infer_ruby_runtime:
	bundle exec ruby -e "require 'rbs_infer'; require 'rbs_infer/project/ruby_runtime_generator'; RbsInfer::Project::RubyRuntimeGenerator.new(app_dir: '.').generate"

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
	make rbs_infer_ruby_runtime
	make rbs_infer_controller_runtime
	make rbs_infer_current_runtime
	make rbs_infer_actionview_runtime
	make rbs_infer_all

## `-j` NÃO fica no default (= nº de CPUs, 10 nesta máquina). Cada worker do steep
## custa ~1 GiB neste projeto, então 10 workers levam o pico a 19,2 GiB e a máquina
## vai para swap. Com `-j 4` o pico mediu 8,8 GiB e o run ficou MAIS RÁPIDO por não
## trocar página (321s contra 344s). O número é limitado pela RAM, não pelos cores:
## ~1 GiB por worker mais ~1,7 GiB do master durante a inferência.
##
## As variáveis de GC limitam o crescimento do heap, que é o que domina o consumo:
## as passadas de inferência alocam ~148M de objetos e retêm 27 MB — o resto é
## high-water mark. `HEAP_GROWTH_MAX_SLOTS` corta 16% do pico sem custo de tempo;
## `MALLOC_ARENA_MAX` evita fragmentação entre as arenas do glibc.
steep:
	RUBY_GC_HEAP_GROWTH_MAX_SLOTS=100000 RUBY_GC_HEAP_GROWTH_FACTOR=1.1 MALLOC_ARENA_MAX=2 \
		bundle exec steep check -j 4

## `.steep_postconditions.yml` é SAÍDA do steep sobre o pseudo-código e ENTRADA
## do rbs_infer. Uma passada só mostra tipos nilable que são atraso, não
## regressão — repita até o `git diff` de sig/ parar de mudar (no dummy do
## rbs_infer leva de 2 a 4 voltas).
rbs_converge:
	make steep || true
	make rbs_infer_all
