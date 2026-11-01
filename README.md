# Automação de Ambiente e Mini Pipeline CI - ACZG

Conjunto de scripts em Bash para automação do fluxo de desenvolvimento em sistemas Linux (baseados em Debian/Ubuntu). O projeto abrange desde a criação padronizada de repositórios Git e gerenciamento de branches até um mini pipeline de Integração Contínua (CI) com execução agendada de testes unitários via Gradle, notificações visuais no desktop, commits diários automatizados e rastreamento de logs.

---

## Pré-requisitos e Dependências

Os scripts utilizam utilitários padrão do Linux e verificam/instalam automaticamente as dependências necessárias via `apt` caso não estejam presentes na máquina:
* **`git`**: Controle de versão e gerenciamento de branches.
* **`libnotify-bin` (`notify-send`)**: Emissão de alertas visuais na interface gráfica do usuário após a execução da bateria de testes.
* **`cron` (`crontab`)**: Agendamento em segundo plano para a execução periódica dos testes e commits automáticos.
* **Gradle / SDKMAN!**: Suporte nativo tanto ao Gradle Wrapper (`./gradlew`) do projeto quanto a instalações globais gerenciadas via SDKMAN! (`~/.sdkman`).

---

## Instalação e Configuração Inicial (Task 5)

Para configurar todas as ferramentas em qualquer máquina Linux sem necessidade de ajustes manuais, clone este repositório e execute o instalador `configure.sh`:

```bash
chmod +x configure.sh
./configure.sh
source ~/.bashrc
```

### O que o instalador faz automaticamente:
1. Verifica e instala os pacotes obrigatórios (`git`, `libnotify-bin` e `cron`).
2. Cria o diretório padrão do usuário em `~/.local/bin/aczg` e copia todos os scripts para lá.
3. Aplica permissão de execução (`chmod +x`) em todos os arquivos `.sh`.
4. Registra todos os aliases no arquivo `~/.bash_aliases` e garante seu carregamento automático pelo `~/.bashrc`.
5. Opcionalmente, caso você passe o caminho de um projeto como argumento (`./configure.sh /caminho/do/projeto`), ele já agenda as Cron Jobs da pipeline de CI para esse diretório.

---

## Arquitetura dos Scripts

* **`initialize_aczg.sh` (Task 1)**: Recebe um diretório base e o nome do projeto, cria a estrutura de pastas caso não exista, gera o arquivo `README.md` com o texto de inicialização, inicia o repositório Git local (`git init`) e realiza o commit inicial padronizado.
* **`aczg_init.sh` (Task 2)**: Automatiza a abertura de novas entregas. Exibe o status atual da árvore de trabalho (`git status`), cria e alterna para uma nova branch seguindo a convenção `feat-<nomeFeature>` e lista todas as branches locais e remotas (`git branch -a`).
* **`aczg_finish.sh` (Task 2)**: Automatiza a finalização e entrega de uma feature. Captura o nome da branch atual, retorna para a branch principal (`master` ou `main`), realiza o `merge` da feature e remove a branch de desenvolvimento tanto localmente quanto no repositório remoto (`origin`).
* **`ci_cron.sh` (Task 3 - Testes)**: Configura uma Cron Job para rodar os testes unitários do projeto com Gradle (`./gradlew test` ou `gradle test`). Exporta as variáveis de sessão gráfica (`DISPLAY` e `DBUS_SESSION_BUS_ADDRESS`) para disparar alertas na tela do usuário via `notify-send` informando se os testes passaram ou falharam, além de registrar o resultado demarcado no arquivo de log.
* **`commit_cron.sh` (Task 3 - Commits Diários)**: Configura uma Cron Job secundária para realizar commits diários automáticos no repositório do projeto, garantindo que o progresso só seja commitado caso a última execução da bateria de testes unitários tenha passado com sucesso.
* **`get_logs.sh` (Task 4)**: Utiliza expressões regulares com `grep` para filtrar o arquivo de log gerado pela pipeline de CI, exibindo no terminal apenas os registros demarcados de execução da Task 3 com destaque de cores.
* **`configure.sh` (Task 5)**: Script instalador que centraliza a implantação de todos os scripts acima, gerencia permissões e configura os aliases no ambiente do usuário.

---

## Guia de Uso dos Aliases

Após executar o `configure.sh` e recarregar o terminal (`source ~/.bashrc`), os seguintes comandos estarão disponíveis globalmente em qualquer diretório:

### 1. Inicializar um novo projeto (`init_aczg`)
Cria a pasta do projeto, o `README.md` inicial e configura o repositório Git com o primeiro commit.
* **Sintaxe:** `init_aczg <caminho_destino> <nome_do_projeto>`
* **Exemplo:**
  ```bash
  init_aczg ~/Documentos/projetos meu-novo-servico
  ```

### 2. Iniciar uma nova feature (`aczginit`)
Verifica o status do repositório, cria e muda para a branch `feat-<nomeFeature>` e lista todas as branches disponíveis.
* **Sintaxe:** `aczginit <nomeFeature>`
* **Exemplo:**
  ```bash
  aczginit autenticacao-jwt
  ```

### 3. Finalizar e integrar uma feature (`aczgfinish`)
Faz checkout para a branch principal (`master`/`main`), aplica o merge da branch atual e deleta a branch da feature local e remotamente.
* **Sintaxe:** `aczgfinish` (executado diretamente de dentro da branch `feat-*` que deseja encerrar)
* **Exemplo:**
  ```bash
  aczgfinish
  ```

### 4. Agendar Pipeline de Testes no Cron (`aczgci`)
Configura a execução periódica dos testes unitários do Gradle em segundo plano com alertas na tela e gravação de log.
* **Sintaxe:** `aczgci [caminho_do_projeto] ["periodicidade_cron"] [caminho_do_log]`
* **Valores padrão (caso omitidos):** Diretório atual (`.`), a cada 15 minutos (`*/15 * * * *`) e arquivo `./ci_tests.log`.
* **Exemplos:**
  ```bash
  # Usando valores padrão no diretório atual (roda a cada 15 min)
  aczgci

  # Definindo projeto específico e rodando a cada 5 minutos
  aczgci ~/Documentos/projetos/meu-app-gradle "*/5 * * * *"
  ```

### 5. Agendar Commits Diários Automáticos (`aczgcommit`)
Agenda commits automáticos condicionados ao sucesso dos testes da pipeline.
* **Sintaxe:** `aczgcommit [caminho_do_projeto] ["periodicidade_cron"] [caminho_do_log]`
* **Valores padrão (caso omitidos):** Diretório atual (`.`), todos os dias às 23:59 (`59 23 * * *`) e arquivo `./ci_tests.log`.
* **Exemplo:**
  ```bash
  aczgcommit ~/Documentos/projetos/meu-app-gradle "59 23 * * *"
  ```

### 6. Rastrear Logs da Pipeline (`aczglogs`)
Filtra e exibe no terminal os logs demarcados gerados pelas execuções da Task 3.
* **Sintaxe:** `aczglogs [caminho_do_projeto] [caminho_do_log]`
* **Exemplos:**
  ```bash
  # Visualizar logs do projeto na pasta atual
  aczglogs

  # Visualizar logs de um projeto em outro diretório
  aczglogs ~/Documentos/projetos/meu-app-gradle
  ```
