<p align="center">
  <a href="../../README.md"><img alt="English" src="https://img.shields.io/badge/English-3A3A3C?style=for-the-badge"></a>
  <a href="./ar.md"><img alt="Arabic" src="https://img.shields.io/badge/%D8%A7%D9%84%D8%B9%D8%B1%D8%A8%D9%8A%D8%A9-3A3A3C?style=for-the-badge"></a>
  <a href="./es.md"><img alt="Spanish" src="https://img.shields.io/badge/Espa%C3%B1ol-3A3A3C?style=for-the-badge"></a>
  <a href="./fr.md"><img alt="French" src="https://img.shields.io/badge/Fran%C3%A7ais-3A3A3C?style=for-the-badge"></a>
  <a href="./de.md"><img alt="German" src="https://img.shields.io/badge/Deutsch-3A3A3C?style=for-the-badge"></a>
  <a href="./pt.md"><img alt="Portuguese" src="https://img.shields.io/badge/Portugu%C3%AAs-0A84FF?style=for-the-badge"></a>
  <a href="./tr.md"><img alt="Turkish" src="https://img.shields.io/badge/T%C3%BCrk%C3%A7e-3A3A3C?style=for-the-badge"></a>
  <a href="./zh.md"><img alt="Chinese" src="https://img.shields.io/badge/%E4%B8%AD%E6%96%87-3A3A3C?style=for-the-badge"></a>
  <a href="./ja.md"><img alt="Japanese" src="https://img.shields.io/badge/%E6%97%A5%E6%9C%AC%E8%AA%9E-3A3A3C?style=for-the-badge"></a>
  <a href="./ko.md"><img alt="Korean" src="https://img.shields.io/badge/%ED%95%9C%EA%B5%AD%EC%96%B4-3A3A3C?style=for-the-badge"></a>
</p>

# Banish

**O app, e tudo o que ele deixou para trás.**

Arrastar um app para o Lixo só remove o ícone. Preferências, caches, contêineres, registros e agentes de inicialização ficam na Biblioteca. Continuam ocupando espaço e voltam na próxima instalação.

O Banish encontra esses arquivos, mostra tudo antes de mover qualquer coisa e manda para o Lixo só o que você escolher. Cada item pode voltar. Nada é apagado de vez.

<p><img src="../images/library.png" alt="Apps instalados no Banish" width="920"></p>

## O que você vê

A barra lateral lista os apps instalados, com versão e tamanho. Um ponto verde significa que o app está em execução. A busca aceita um nome ou um identificador, como `com.google.Chrome`.

Três números aparecem: o tamanho do app, o dos arquivos relacionados e o do que está selecionado e irá para o Lixo.

**Arquivos relacionados** combinam com o identificador e já vêm marcados. **Correspondências de nome** só compartilham o nome, então ficam desmarcadas até você olhar o caminho.

<p><img src="../images/detail.png" alt="Chrome no Banish, com os arquivos relacionados" width="920"></p>

## Nada se move antes da confirmação

**Move to Trash** abre uma folha com a quantidade e o tamanho. O botão não é o padrão, então Return não confirma por engano.

Apps em `/Applications` pertencem ao macOS, e uma mudança comum é recusada. A folha avisa que a senha pode ser necessária. Depois da confirmação, o macOS pergunta uma vez e o Banish move a seleção para o Lixo.

<p><img src="../images/confirm.png" alt="Confirmação antes de enviar o Chrome ao Lixo" width="920"></p>

Cancelar a senha interrompe a mudança. O que não se moveu fica no lugar. O que chegou ao Lixo pode ser restaurado.

## Onde ele procura

O Banish não varre o disco inteiro. Olha as pastas conhecidas da Biblioteca, com pouca profundidade: preferências, Application Support, caches, registros, contêineres, dados da web quando o identificador combina, agentes de inicialização e o estado salvo.

Uma combinação forte usa o identificador. `com.foo.app` não recolhe `com.foo.application` nem `com.foo.app2`. `Google/Chrome` pode pertencer ao Chrome. `Google/Earth` não, só porque uma palavra coincide.

## O que ele não toca

Locais do sistema como `/System`, `/usr`, `/bin` e `/private`. Documentos, Mesa, Downloads, fotos e música. Mail, Mensagens, Fotos, Safari, chaves, Calendário e Notas. `~/.ssh`, e o próprio Lixo como origem de uma exclusão. Atalhos simbólicos. E a cópia do Banish que está rodando: o app não move a si mesmo.

Apps essenciais da Apple, como Finder, Safari e Mail, ficam bloqueados. Apps opcionais, como Keynote, Pages e Numbers, podem ser removidos com um aviso. Apps do sistema começam ocultos e aparecem no menu Visualizar ou nos Ajustes.

## Permissões

A **senha de administrador** só é pedida quando o macOS recusa tirar um app da pasta Aplicativos. O diálogo é o do sistema e cita o Banish.

**Acesso total ao disco** é opcional. Permite ler contêineres e caches que o macOS esconde. Sem ele, a lista continua funcionando e um aviso aparece se uma pasta não puder ser lida.

Ajustes do Sistema → Privacidade e Segurança → Acesso Total ao Disco

## Idioma no app

A janela segue o idioma do Mac, da direita para a esquerda em árabe. Nos Ajustes dá para fixar árabe ou inglês.

<p><img src="../images/settings.png" alt="Ajustes do Banish" width="540"></p>

## Compilar

macOS 14 ou mais recente, e Swift 6. Sem bibliotecas de terceiros.

```bash
./Scripts/build-app.sh
open build/Banish.app
```

Ou `make app` e `make run`. Os testes rodam com `make test`. O app assinado fica em `build/Banish.app`.
