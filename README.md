# Aura - Sistema de Gestão de Manutenção Predial e Ativos 🏢🛠️

O **Aura** é uma plataforma integrada desenvolvida para centralizar, automatizar e otimizar todas as operações de manutenção e controle patrimonial de uma organização. O sistema visa substituir controlos manuais por um fluxo eficiente que vai desde a abertura de chamados cotidianos até ao planejamento preventivo avançado da infraestrutura, garantindo alta disponibilidade dos ativos e controle rigoroso de custos, em conformidade com os requisitos da **ABNT NBR 5674** (Manutenção de edificações).

---

## 🚀 Escopo do Produto & Funcionalidades

### 📱 Portal de Chamados e Execução (Web/Mobile)
* **Abertura Simplificada:** Criação de chamados detalhando o problema, prioridade, tipo de manutenção (corretiva, preventiva ou preditiva) e localização exata.
* **Acompanhamento Real-Time:** Interface intuitiva para monitorar a evolução do status do chamado desde o recebimento até à conclusão.
* **Registro Técnico:** Os técnicos de campo podem registrar o tempo gasto, atividades executadas e insumos aplicados nas Ordens de Serviço (OS).
* **Mobilidade:** Consulta móvel da localização detalhada do ativo e do seu histórico prévio de intervenções.

### 💻 Painel Administrativo de Gestão Estratégica
* **Árvore de Ativos e Ambientes:** Cadastro estruturado de ativos físicos, responsáveis e mapeamento predial hierárquico (prédios, andares e salas).
* **Planos Preventivos:** Configuração de planos de manutenção preventiva automáticos baseados em tempo ou uso.
* **Almoxarifado & Estoque Integrado:** Controle de inventário de peças com baixa automatizada nas ordens de serviço, cálculo dinâmico de custos e alertas automáticos de nível mínimo de segurança.
* **Business Intelligence (BI):** Painel de indicadores com métricas críticas como Tempo Médio de Reparo (MTTR), taxa de falhas, custos por ativo e disponibilidade geral da infraestrutura.

---

## 🛠️ Especificações Técnicas

* **Framework Principal:** [Flutter](https://flutter.dev/) (Alvo principal: Desktop - Windows)
* **Linguagem de Programação:** [Dart](https://dart.dev/)
* **Arquitetura:** Princípios de *Clean Code*, padrões consolidados e arquitetura modularizada (Clean Architecture).
* **Injeção de Dependências:** [GetIt](https://pub.dev/packages/get_it) (Service Locator)
* **Persistência Local:** Banco de dados relacional / SQLite (`sqflite`)

---

## 📅 Plano de Liberações (Cronograma 2026)

O desenvolvimento do Aura está estruturado em quatro iterações bem definidas:

* **Iteração 1: Configuração Inicial e Inventário (01/03 a 15/03):** Modelação da base de dados relacional, estrutura de árvores de ambientes, cadastro centralizado de dados patrimoniais (garantias, vida útil e estado de conservação) e vínculo de equipes responsáveis.
* **Iteração 2: Núcleo Operacional — Chamados e OS (16/03 a 30/03):** Desenvolvimento do portal de solicitações de problemas, painel técnico de execução de OS com cronometragem e mecanismo de log imutável de histórico.
* **Iteração 3: Automatização Preventiva e Estoque (01/04 a 15/04):** Implementação do motor de regras para planos preventivos, módulo de almoxarifado por fornecedores e lógica de baixa automatizada de insumos com cálculo dinâmico de custos.
* **Iteração 4: Indicadores Gerenciais, Notificações e Implantação (16/04 a 30/04):** Construção de dashboards analíticos (MTTR, disponibilidade), motor de notificações automáticas (push/e-mail), rotinas de QA (testes de estresse e integração) e deploy final em produção.

---

## 📁 Estrutura de Pastas Recomendada

```text
lib/
 ├── core/          # Temas, utilitários globais, rotas e acessibilidade
 ├── data/          # Modelos, DataSources locais (SQLite) e implementações dos repositórios
 ├── domain/        # Entidades puras de negócio, contratos/interfaces e regras de uso
 ├── pages/         # Interface de usuário (UI) dividida por módulos (ambiente, ativos, chamados...)
 └── main.dart      # Inicialização do Service Locator (GetIt) e do App

🏁 Como Executar o Projeto Localmente
Clonar o repositório:

Bash
git clone [https://github.com/FontesSabrina/Gestao-Ativos-Predial.git](https://github.com/FontesSabrina/Gestao-Ativos-Predial.git)
Navegar até à pasta raiz do projeto:

Bash
cd Gestao-Ativos-Predial
Obter as dependências do projeto:

Bash
flutter pub get
Habilitar o suporte Windows (se necessário) e rodar:

Bash
flutter config --enable-windows-desktop
flutter run -d windows
🧑‍💻 Autores (IFSUDESTEMG - Campus Muriaé)
Trabalho desenvolvido para o curso de Gestão da Tecnologia da Informação:

Alexandre do Amaral Quintão — Desenvolvedor do Projeto

Sabrina Caetano Fontes — Desenvolvedora do Projeto

Developed as part of the GTI Academic Projects ecosystem. 🚀


Pode salvar esse arquivo por cima do outro. Para atualizar no GitHub sem esses códigos esquisitos, rode no terminal:

```bash
git add README.md
git commit -m "docs: remove tags de citacao do arquivo readme"
git push origin main
